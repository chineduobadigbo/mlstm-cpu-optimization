#include <immintrin.h>
#include <omp.h>

#include <algorithm>
#include <cmath>
#include <memory>
#include <vector>

#include "mlstm_bhtd_utils.h"
#include "mlstm_kernels.h"
#include "stable_math.h"

// Chunk uses BHTD q/k/v/y and C [Dk,Dv] per (batch, head), with key rows and
// value columns. prepare_chunk combines gates, stabilization and query scaling:
// y = (scaled_q*C_old + scores*v) / denominator;
// C_new = previous_state_weight*C_old + scaled_k^T*v.
// Read each key block's contribution to y before overwriting C.

namespace mlstm_cpu {
namespace {

constexpr int64_t kDefaultChunkSize = 4;
// Limit chunk length to fit one output vector per token in
// update_state_and_output_chunk's registers.
constexpr int64_t kMaxChunkSize = 8;

inline float dot_avx2(const float* lhs, const float* rhs, int64_t size) {
  __m256 sum0 = _mm256_setzero_ps();
  __m256 sum1 = _mm256_setzero_ps();
  int64_t key_index = 0;
  for (; key_index + 2 * kAvx2Width <= size; key_index += 2 * kAvx2Width) {
    sum0 = _mm256_fmadd_ps(
        _mm256_loadu_ps(lhs + key_index), _mm256_loadu_ps(rhs + key_index), sum0);
    sum1 = _mm256_fmadd_ps(
        _mm256_loadu_ps(lhs + key_index + kAvx2Width),
        _mm256_loadu_ps(rhs + key_index + kAvx2Width), sum1);
  }
  for (; key_index + kAvx2Width <= size; key_index += kAvx2Width) {
    sum0 = _mm256_fmadd_ps(
        _mm256_loadu_ps(lhs + key_index), _mm256_loadu_ps(rhs + key_index), sum0);
  }

  float sum = hsum256_ps_hadd(_mm256_add_ps(sum0, sum1));
  for (; key_index < size; ++key_index) {
    sum += lhs[key_index] * rhs[key_index];
  }
  return sum;
}

// Start y with scores*v, add C_old by key block, then normalize. Keep up to
// four value vectors in registers; reload larger chunks to reduce spills.
template <int64_t ChunkSize>
void update_state_and_output_chunk(
    const float* scaled_q,
    const float* scaled_k,
    const float* v,
    float* C,
    float* y,
    const float* scores,
    const float* denominator,
    float previous_state_weight,
    int64_t Dk,
    int64_t Dv,
    int64_t key_block_size,
    int64_t value_begin,
    int64_t value_end) {
  const __m256 previous = _mm256_set1_ps(previous_state_weight);

  int64_t value_index = value_begin;
  for (; value_index + kAvx2Width <= value_end; value_index += kAvx2Width) {
    __m256 output[ChunkSize];
    for (int64_t query_token = 0; query_token < ChunkSize; ++query_token) {
      output[query_token] = _mm256_setzero_ps();
    }
    for (int64_t key_token = 0; key_token < ChunkSize; ++key_token) {
      const __m256 value = _mm256_loadu_ps(v + key_token * Dv + value_index);
      for (int64_t query_token = key_token; query_token < ChunkSize; ++query_token) {
        output[query_token] = _mm256_fmadd_ps(
            _mm256_set1_ps(scores[query_token * ChunkSize + key_token]), value,
            output[query_token]);
      }
    }
    for (int64_t query_token = 0; query_token < ChunkSize; ++query_token) {
      _mm256_storeu_ps(y + query_token * Dv + value_index, output[query_token]);
    }
  }
  for (; value_index < value_end; ++value_index) {
    for (int64_t query_token = 0; query_token < ChunkSize; ++query_token) {
      float output = 0.0f;
      for (int64_t key_token = 0; key_token <= query_token; ++key_token) {
        output += scores[query_token * ChunkSize + key_token] *
                  v[key_token * Dv + value_index];
      }
      y[query_token * Dv + value_index] = output;
    }
  }

  for (int64_t key_begin = 0; key_begin < Dk; key_begin += key_block_size) {
    const int64_t key_end = std::min(key_begin + key_block_size, Dk);
    value_index = value_begin;
    for (; value_index + kAvx2Width <= value_end; value_index += kAvx2Width) {
      __m256 output[ChunkSize];
      __m256 values[ChunkSize];
      for (int64_t query_token = 0; query_token < ChunkSize; ++query_token) {
        output[query_token] = _mm256_loadu_ps(y + query_token * Dv + value_index);
      }
      if constexpr (ChunkSize <= 4) {
        for (int64_t key_token = 0; key_token < ChunkSize; ++key_token) {
          values[key_token] = _mm256_loadu_ps(v + key_token * Dv + value_index);
        }
      }
      for (int64_t key_index = key_begin; key_index < key_end; ++key_index) {
        float* const state_row = C + key_index * Dv + value_index;
        const __m256 old_state = _mm256_loadu_ps(state_row);
        __m256 new_state = _mm256_mul_ps(previous, old_state);
        for (int64_t query_token = 0; query_token < ChunkSize; ++query_token) {
          output[query_token] = _mm256_fmadd_ps(
              _mm256_set1_ps(scaled_q[query_token * Dk + key_index]), old_state,
              output[query_token]);
        }
        for (int64_t key_token = 0; key_token < ChunkSize; ++key_token) {
          __m256 value;
          if constexpr (ChunkSize <= 4) {
            value = values[key_token];
          } else {
            value = _mm256_loadu_ps(v + key_token * Dv + value_index);
          }
          new_state = _mm256_fmadd_ps(
              _mm256_set1_ps(scaled_k[key_token * Dk + key_index]), value, new_state);
        }
        _mm256_storeu_ps(state_row, new_state);
      }
      for (int64_t query_token = 0; query_token < ChunkSize; ++query_token) {
        _mm256_storeu_ps(y + query_token * Dv + value_index, output[query_token]);
      }
    }
    for (; value_index < value_end; ++value_index) {
      float output[ChunkSize];
      for (int64_t query_token = 0; query_token < ChunkSize; ++query_token) {
        output[query_token] = y[query_token * Dv + value_index];
      }
      for (int64_t key_index = key_begin; key_index < key_end; ++key_index) {
        float* const state_element = C + key_index * Dv + value_index;
        const float old_state = *state_element;
        float new_state = previous_state_weight * old_state;
        for (int64_t query_token = 0; query_token < ChunkSize; ++query_token) {
          output[query_token] += scaled_q[query_token * Dk + key_index] * old_state;
        }
        for (int64_t key_token = 0; key_token < ChunkSize; ++key_token) {
          new_state +=
              scaled_k[key_token * Dk + key_index] * v[key_token * Dv + value_index];
        }
        *state_element = new_state;
      }
      for (int64_t query_token = 0; query_token < ChunkSize; ++query_token) {
        y[query_token * Dv + value_index] = output[query_token];
      }
    }
  }

  for (int64_t query_token = 0; query_token < ChunkSize; ++query_token) {
    const __m256 inverse_denominator =
        _mm256_set1_ps(1.0f / denominator[query_token]);
    value_index = value_begin;
    for (; value_index + kAvx2Width <= value_end; value_index += kAvx2Width) {
      _mm256_storeu_ps(
          y + query_token * Dv + value_index,
          _mm256_mul_ps(
              _mm256_loadu_ps(y + query_token * Dv + value_index),
              inverse_denominator));
    }
    for (; value_index < value_end; ++value_index) {
      y[query_token * Dv + value_index] /= denominator[query_token];
    }
  }
}

// Pack arrays using the actual chunk length, including short final chunks.
// process_chunk_values uses matching offsets.
struct ChunkWorkspace {
  float* log_forget;
  float* prefix_log_forget;
  float* final_input_log_weight;
  float* final_input_weight;
  float* state_query_scale;
  float* denominator;
  float* scores;    // [query_token, key_token]; upper triangle unused.
  float* scaled_q;  // Weights [token, key_index] for reading C_old.
  float* scaled_k;  // Weights [token, key_index] for updating C_new.

  static int64_t size(int64_t length, int64_t Dk) {
    return 6 * length + length * length + 2 * length * Dk;
  }

  ChunkWorkspace(float* storage, int64_t length, int64_t Dk)
      : log_forget(storage),
        prefix_log_forget(log_forget + length),
        final_input_log_weight(prefix_log_forget + length),
        final_input_weight(final_input_log_weight + length),
        state_query_scale(final_input_weight + length),
        denominator(state_query_scale + length),
        scores(denominator + length),
        scaled_q(scores + length * length),
        scaled_k(scaled_q + length * Dk) {}
};

// With F[t] = prefix sum of log(sigmoid(f_tilde)), key s has log weight
// i_tilde[s]+F[t]-F[s] at query t. output_m stabilizes each causal prefix;
// next_m stabilizes the full chunk's final state.
float prepare_chunk(
    const float* q,
    const float* k,
    const float* i_tilde,
    const float* f_tilde,
    float* n,
    float& m,
    int64_t length,
    int64_t Dk,
    float* storage,
    float eps) {
  const ChunkWorkspace workspace(storage, length, Dk);
  for (int64_t t = 0; t < length; ++t) {
    workspace.log_forget[t] = log_sigmoid_stable(f_tilde[t]);
    workspace.prefix_log_forget[t] =
        workspace.log_forget[t] + (t == 0 ? 0.0f : workspace.prefix_log_forget[t - 1]);
  }

  // Sum later log forget gates in reverse token order.
  float suffix_log_forget = 0.0f;
  for (int64_t t = length; t-- > 0;) {
    workspace.final_input_log_weight[t] = i_tilde[t] + suffix_log_forget;
    suffix_log_forget += workspace.log_forget[t];
  }

  const float previous_m = m;
  float next_m = suffix_log_forget + previous_m;
  for (int64_t t = 0; t < length; ++t) {
    next_m = std::max(next_m, workspace.final_input_log_weight[t]);
  }
  const float previous_state_weight = std::exp(suffix_log_forget + previous_m - next_m);
  for (int64_t t = 0; t < length; ++t) {
    workspace.final_input_weight[t] =
        std::exp(workspace.final_input_log_weight[t] - next_m);
  }

  // Form C_old weights and causal scores; all denominators use the incoming n.
  const float query_scale = inv_sqrt_dim(Dk);
  for (int64_t query_token = 0; query_token < length; ++query_token) {
    float output_m = workspace.prefix_log_forget[query_token] + previous_m;
    for (int64_t key_token = 0; key_token <= query_token; ++key_token) {
      output_m = std::max(
          output_m, i_tilde[key_token] +
                        workspace.prefix_log_forget[query_token] -
                        workspace.prefix_log_forget[key_token]);
    }

    workspace.state_query_scale[query_token] =
        query_scale *
        std::exp(workspace.prefix_log_forget[query_token] + previous_m - output_m);
    float normalizer = workspace.state_query_scale[query_token] *
                       dot_avx2(q + query_token * Dk, n, Dk);
    for (int64_t key_token = 0; key_token <= query_token; ++key_token) {
      const float gate = std::exp(
          i_tilde[key_token] + workspace.prefix_log_forget[query_token] -
          workspace.prefix_log_forget[key_token] - output_m);
      const float score =
          query_scale * gate * dot_avx2(q + query_token * Dk, k + key_token * Dk, Dk);
      workspace.scores[query_token * length + key_token] = score;
      normalizer += score;
    }
    workspace.denominator[query_token] =
        std::max(std::abs(normalizer), std::exp(-output_m)) + eps;
  }

  for (int64_t t = 0; t < length; ++t) {
    for (int64_t key_index = 0; key_index < Dk; ++key_index) {
      workspace.scaled_q[t * Dk + key_index] =
          workspace.state_query_scale[t] * q[t * Dk + key_index];
      workspace.scaled_k[t * Dk + key_index] =
          workspace.final_input_weight[t] * k[t * Dk + key_index];
    }
  }

  // Update n only after computing every denominator. Matrix helpers reuse these
  // final-state weights to update C.
  const __m256 previous = _mm256_set1_ps(previous_state_weight);
  int64_t key_index = 0;
  for (; key_index + kAvx2Width <= Dk; key_index += kAvx2Width) {
    __m256 next_n = _mm256_mul_ps(previous, _mm256_loadu_ps(n + key_index));
    for (int64_t t = 0; t < length; ++t) {
      next_n = _mm256_fmadd_ps(
          _mm256_set1_ps(workspace.final_input_weight[t]),
          _mm256_loadu_ps(k + t * Dk + key_index), next_n);
    }
    _mm256_storeu_ps(n + key_index, next_n);
  }
  for (; key_index < Dk; ++key_index) {
    float next_n = previous_state_weight * n[key_index];
    for (int64_t t = 0; t < length; ++t) {
      next_n += workspace.final_input_weight[t] * k[t * Dk + key_index];
    }
    n[key_index] = next_n;
  }
  m = next_m;
  return previous_state_weight;
}

void process_chunk_values(
    const float* v,
    float* C,
    float* y,
    int64_t length,
    int64_t Dk,
    int64_t Dv,
    int64_t key_block_size,
    int64_t value_begin,
    int64_t value_end,
    float previous_state_weight,
    const float* storage) {
  // Denominators follow five gate arrays; scores and scaled inputs follow them.
  const float* const denominator = storage + 5 * length;
  const float* const scores = denominator + length;
  const float* const scaled_q = scores + length * length;
  const float* const scaled_k = scaled_q + length * Dk;
  // Use compile-time chunk lengths to enable loop unrolling.
  switch (length) {
    case 1:
      update_state_and_output_chunk<1>(
          scaled_q, scaled_k, v, C, y, scores, denominator, previous_state_weight, Dk,
          Dv, key_block_size, value_begin, value_end);
      break;
    case 2:
      update_state_and_output_chunk<2>(
          scaled_q, scaled_k, v, C, y, scores, denominator, previous_state_weight, Dk,
          Dv, key_block_size, value_begin, value_end);
      break;
    case 3:
      update_state_and_output_chunk<3>(
          scaled_q, scaled_k, v, C, y, scores, denominator, previous_state_weight, Dk,
          Dv, key_block_size, value_begin, value_end);
      break;
    case 4:
      update_state_and_output_chunk<4>(
          scaled_q, scaled_k, v, C, y, scores, denominator, previous_state_weight, Dk,
          Dv, key_block_size, value_begin, value_end);
      break;
    case 5:
      update_state_and_output_chunk<5>(
          scaled_q, scaled_k, v, C, y, scores, denominator, previous_state_weight, Dk,
          Dv, key_block_size, value_begin, value_end);
      break;
    case 6:
      update_state_and_output_chunk<6>(
          scaled_q, scaled_k, v, C, y, scores, denominator, previous_state_weight, Dk,
          Dv, key_block_size, value_begin, value_end);
      break;
    case 7:
      update_state_and_output_chunk<7>(
          scaled_q, scaled_k, v, C, y, scores, denominator, previous_state_weight, Dk,
          Dv, key_block_size, value_begin, value_end);
      break;
    case 8:
      update_state_and_output_chunk<8>(
          scaled_q, scaled_k, v, C, y, scores, denominator, previous_state_weight, Dk,
          Dv, key_block_size, value_begin, value_end);
      break;
  }
}

// Prepare every state's gates and synchronize at the omp-for barrier before
// updating separate column-unit ranges.
void process_split_states(
    const float* q,
    const float* k,
    const float* v,
    const float* i_tilde,
    const float* f_tilde,
    float* C,
    float* n,
    float* m,
    float* y,
    int64_t T,
    int64_t Dk,
    int64_t Dv,
    int64_t state_count,
    int64_t chunk_size,
    int threads,
    int64_t key_block_size,
    float eps) {
  const int64_t chunk_count = (T + chunk_size - 1) / chunk_size;
  const int64_t workspace_size = ChunkWorkspace::size(chunk_size, Dk);
  const int64_t state_workspace_size = chunk_count * workspace_size;
  std::unique_ptr<float[]> workspaces(new float[state_count * state_workspace_size]);
  std::vector<float> previous_state_weights(state_count * chunk_count);

#pragma omp parallel num_threads(threads)
  {
#pragma omp for schedule(static)
    for (int64_t state = 0; state < state_count; ++state) {
      float* const n_state = n + state * Dk;
      float& m_state = m[state];
      float* const state_workspaces = workspaces.get() + state * state_workspace_size;
      float* const state_weights = previous_state_weights.data() + state * chunk_count;

      for (int64_t chunk = 0; chunk < chunk_count; ++chunk) {
        const int64_t t = chunk * chunk_size;
        const int64_t length = std::min(chunk_size, T - t);
        const int64_t token = state * T + t;
        state_weights[chunk] = prepare_chunk(
            q + token * Dk, k + token * Dk, i_tilde + token,
            f_tilde + token, n_state, m_state, length, Dk,
            state_workspaces + chunk * workspace_size, eps);
      }
    }

    // The completed omp-for barrier makes all chunk weights available.
    const int thread_id = omp_get_thread_num();
    const StateWorker worker =
        assign_state_worker(thread_id, threads, state_count);
    const int64_t state = worker.state;
    const int column_worker = worker.value_worker;
    const int workers_for_state = worker.workers_for_state;
    const int64_t tiles = (Dv + kColumnUnit - 1) / kColumnUnit;
    const int64_t value_begin =
        std::min(Dv, kColumnUnit * (tiles * column_worker / workers_for_state));
    const int64_t value_end =
        std::min(Dv, kColumnUnit * (tiles * (column_worker + 1) / workers_for_state));
    float* const C_state = C + state * Dk * Dv;
    float* const state_workspaces = workspaces.get() + state * state_workspace_size;
    const float* const state_weights =
        previous_state_weights.data() + state * chunk_count;

    for (int64_t chunk = 0; chunk < chunk_count; ++chunk) {
      const int64_t t = chunk * chunk_size;
      const int64_t length = std::min(chunk_size, T - t);
      const int64_t token = state * T + t;
      process_chunk_values(
          v + token * Dv, C_state, y + token * Dv, length, Dk, Dv, key_block_size,
          value_begin, value_end, state_weights[chunk],
          state_workspaces + chunk * workspace_size);
    }
  }
}

}  // namespace

void mlstm_core_sequence_chunkwise_avx2_bhtd(
    const float* q,
    const float* k,
    const float* v,
    const float* i_tilde,
    const float* f_tilde,
    float* C,
    float* n,
    float* m,
    float* y,
    int64_t B,
    int64_t T,
    int64_t H,
    int64_t Dk,
    int64_t Dv,
    float eps) {
  const int64_t chunk_size = std::min(
      T, std::clamp<int64_t>(
             get_env_int("MLSTM_CHUNK", kDefaultChunkSize), 1, kMaxChunkSize));
  const int64_t state_count = B * H;
  const int64_t threads = requested_bhtd_threads();
  // Honor MLSTM_SPLIT where possible; otherwise assign whole states to threads.
  const int split_threads = split_state_threads(threads, state_count, Dv);
  const int64_t key_block_size = choose_key_block_size(Dk, split_threads > 0);
  if (split_threads > 0) {
    process_split_states(
        q, k, v, i_tilde, f_tilde, C, n, m, y, T, Dk, Dv, state_count,
        chunk_size, split_threads, key_block_size, eps);
    return;
  }

  auto process_state = [&](int64_t state) {
    float* const C_state = C + state * Dk * Dv;
    float* const n_state = n + state * Dk;
    float& m_state = m[state];
    const int64_t workspace_size = ChunkWorkspace::size(chunk_size, Dk);

    std::vector<float> workspace(workspace_size);
    for (int64_t t = 0; t < T; t += chunk_size) {
      const int64_t length = std::min(chunk_size, T - t);
      const int64_t token = state * T + t;
      const float previous_state_weight = prepare_chunk(
          q + token * Dk, k + token * Dk, i_tilde + token,
          f_tilde + token, n_state, m_state, length, Dk, workspace.data(), eps);
      process_chunk_values(
          v + token * Dv, C_state, y + token * Dv, length, Dk, Dv, key_block_size, 0,
          Dv, previous_state_weight, workspace.data());
    }
  };

  run_threads(static_cast<int>(std::min(threads, state_count)), [&] {
    // nowait is safe: the parallel region's end synchronizes the team.
#pragma omp for schedule(static) nowait
    for (int64_t state = 0; state < state_count; ++state) {
      process_state(state);
    }
  });
}

}  // namespace mlstm_cpu
