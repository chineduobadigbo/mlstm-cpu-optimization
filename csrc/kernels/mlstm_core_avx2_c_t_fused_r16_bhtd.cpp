#include <immintrin.h>
#include <omp.h>

#include <algorithm>
#include <cmath>
#include <vector>

#include "mlstm_bhtd_utils.h"
#include "mlstm_kernels.h"
#include "stable_math.h"

// Col/Col-TBlock2 use BHTD q/k/v/y and C [Dk,Dv] per (batch, head):
// keys are rows, values are columns. Stable gates update n = f*n + i*k and
// C = f*C + i*k*v^T before normalized readout from q^T*C. Temporal blocks keep
// state in registers; each token reads its own updated state.

namespace mlstm_cpu {

namespace {

// Update n and accumulate q^T*n together, using two accumulators to overlap FMA
// latency. Preserve the scalar-tail and lane-reduction order.
inline float update_normalizer_and_dot(
    const float* q,
    const float* k,
    float* n,
    float input_weight,
    float forget_weight,
    int64_t Dk) {
  constexpr int64_t kernel_width = kAvx2Width * 2;
  float dot = 0.0f;
  __m256 input_vec = _mm256_broadcast_ss(&input_weight);
  __m256 forget_vec = _mm256_broadcast_ss(&forget_weight);
  __m256 sum0 = _mm256_setzero_ps();
  __m256 sum1 = _mm256_setzero_ps();
  int64_t key_index = 0;
  for (; key_index + kernel_width <= Dk; key_index += kernel_width) {
    __m256 n_vec0 = _mm256_loadu_ps(n + key_index);
    __m256 k_vec0 = _mm256_loadu_ps(k + key_index);
    __m256 q_vec0 = _mm256_loadu_ps(q + key_index);
    __m256 retained_n0 = _mm256_mul_ps(forget_vec, n_vec0);
    __m256 input_k0 = _mm256_mul_ps(input_vec, k_vec0);
    __m256 n_new0 = _mm256_add_ps(retained_n0, input_k0);
    sum0 = _mm256_fmadd_ps(n_new0, q_vec0, sum0);
    _mm256_storeu_ps(n + key_index, n_new0);

    __m256 n_vec1 = _mm256_loadu_ps(n + key_index + kAvx2Width);
    __m256 k_vec1 = _mm256_loadu_ps(k + key_index + kAvx2Width);
    __m256 q_vec1 = _mm256_loadu_ps(q + key_index + kAvx2Width);
    __m256 retained_n1 = _mm256_mul_ps(forget_vec, n_vec1);
    __m256 input_k1 = _mm256_mul_ps(input_vec, k_vec1);
    __m256 n_new1 = _mm256_add_ps(retained_n1, input_k1);
    sum1 = _mm256_fmadd_ps(n_new1, q_vec1, sum1);
    _mm256_storeu_ps(n + key_index + kAvx2Width, n_new1);
  }

  for (; key_index + kAvx2Width <= Dk; key_index += kAvx2Width) {
    __m256 n_vec0 = _mm256_loadu_ps(n + key_index);
    __m256 k_vec0 = _mm256_loadu_ps(k + key_index);
    __m256 q_vec0 = _mm256_loadu_ps(q + key_index);
    __m256 retained_n0 = _mm256_mul_ps(forget_vec, n_vec0);
    __m256 input_k0 = _mm256_mul_ps(input_vec, k_vec0);
    __m256 n_new0 = _mm256_add_ps(retained_n0, input_k0);
    sum0 = _mm256_fmadd_ps(n_new0, q_vec0, sum0);
    _mm256_storeu_ps(n + key_index, n_new0);
  }
  __m256 sum = _mm256_add_ps(sum0, sum1);

  for (; key_index < Dk; key_index++) {
    n[key_index] = forget_weight * n[key_index] + input_weight * k[key_index];
    dot += n[key_index] * q[key_index];
  }

  dot += hsum256_ps(sum);
  return dot;
}

template <int64_t BlockSize>
struct TokenBlock {
  const float* q[BlockSize];
  const float* k[BlockSize];
  const float* v[BlockSize];
  float* y[BlockSize];

  TokenBlock() = default;

  TokenBlock(
      const float* q_base,
      const float* k_base,
      const float* v_base,
      float* y_base,
      int64_t Dk,
      int64_t Dv) {
    for (int64_t t = 0; t < BlockSize; ++t) {
      q[t] = q_base + t * Dk;
      k[t] = k_base + t * Dk;
      v[t] = v_base + t * Dv;
      y[t] = y_base + t * Dv;
    }
  }
};

// Retain only gates and output scales per token block. Parallel column updates
// reconstruct token pointers instead of storing them for the whole sequence.
template <int64_t BlockSize>
struct PreparedGates {
  float forget_weight[BlockSize];
  float input_weight[BlockSize];
  float output_scale[BlockSize];
};

// Prepare n, m and denominators separately from C for reuse by value-column
// threads.
template <int64_t BlockSize>
float prepare_temporal_block(
    const float* q_base,
    const float* k_base,
    const float* v_base,
    const float* i_tilde,
    const float* f_tilde,
    float* n,
    float m,
    int64_t Dk,
    int64_t Dv,
    float query_scale,
    TokenBlock<BlockSize>& tokens,
    float* y_base,
    PreparedGates<BlockSize>& gates,
    float eps) {
  for (int64_t t = 0; t < BlockSize; ++t) {
    tokens.q[t] = q_base + t * Dk;
    tokens.k[t] = k_base + t * Dk;
    tokens.v[t] = v_base + t * Dv;
    tokens.y[t] = y_base + t * Dv;

    const float log_forget = log_sigmoid_stable(f_tilde[t]);
    const float next_m = std::max(log_forget + m, i_tilde[t]);
    gates.forget_weight[t] = std::exp(log_forget + m - next_m);
    gates.input_weight[t] = std::exp(i_tilde[t] - next_m);
    const float normalizer =
        query_scale * update_normalizer_and_dot(
                          tokens.q[t], tokens.k[t], n, gates.input_weight[t],
                          gates.forget_weight[t], Dk);
    const float denominator = std::max(std::abs(normalizer), std::exp(-next_m)) + eps;
    gates.output_scale[t] = query_scale / denominator;
    m = next_m;
  }
  return m;
}

// Visit C in key blocks for cache reuse. Accumulate q^T*C_new in y across
// blocks, then normalize after the final key.
template <int64_t BlockSize>
void update_state_and_output_key_blocks(
    float* C,
    const float* const (&k)[BlockSize],
    const float* const (&q)[BlockSize],
    const float* const (&v)[BlockSize],
    const float (&forget_weight)[BlockSize],
    const float (&input_weight)[BlockSize],
    const float (&output_scale)[BlockSize],
    int64_t Dk,
    int64_t Dv,
    int64_t key_block_size,
    int64_t value_begin,
    int64_t value_end,
    float* const (&y)[BlockSize]) {
  constexpr int64_t value_vectors = kColumnUnit / kAvx2Width;
  const int64_t tiled_end =
      value_begin + (value_end - value_begin) / kColumnUnit * kColumnUnit;
  __m256 forget_vec[BlockSize];

  for (int64_t t = 0; t < BlockSize; ++t) {
    forget_vec[t] = _mm256_set1_ps(forget_weight[t]);
    std::fill(y[t] + value_begin, y[t] + value_end, 0.0f);
  }

  for (int64_t key_begin = 0; key_begin < Dk; key_begin += key_block_size) {
    const int64_t key_end = std::min(key_begin + key_block_size, Dk);
    for (int64_t value_index = value_begin; value_index < tiled_end;
        value_index += kColumnUnit) {
      __m256 output[BlockSize][value_vectors];
      __m256 weighted_values[BlockSize][value_vectors];
      for (int64_t t = 0; t < BlockSize; ++t) {
        const __m256 input_vec = _mm256_set1_ps(input_weight[t]);
        for (int64_t value_vector = 0; value_vector < value_vectors; ++value_vector) {
          const int64_t offset = value_index + value_vector * kAvx2Width;
          output[t][value_vector] = _mm256_loadu_ps(y[t] + offset);
          weighted_values[t][value_vector] =
              _mm256_mul_ps(input_vec, _mm256_loadu_ps(v[t] + offset));
        }
      }

      for (int64_t key_index = key_begin; key_index < key_end; ++key_index) {
        float* state_row = C + key_index * Dv + value_index;
        __m256 state_values[value_vectors];
        for (int64_t value_vector = 0; value_vector < value_vectors; ++value_vector) {
          state_values[value_vector] =
              _mm256_loadu_ps(state_row + value_vector * kAvx2Width);
        }
        for (int64_t t = 0; t < BlockSize; ++t) {
          const __m256 k_vec = _mm256_set1_ps(k[t][key_index]);
          const __m256 q_vec = _mm256_set1_ps(q[t][key_index]);
          for (int64_t value_vector = 0; value_vector < value_vectors; ++value_vector) {
            state_values[value_vector] = _mm256_fmadd_ps(
                forget_vec[t], state_values[value_vector],
                _mm256_mul_ps(k_vec, weighted_values[t][value_vector]));
            output[t][value_vector] = _mm256_fmadd_ps(
                state_values[value_vector], q_vec, output[t][value_vector]);
          }
        }
        for (int64_t value_vector = 0; value_vector < value_vectors; ++value_vector) {
          _mm256_storeu_ps(
              state_row + value_vector * kAvx2Width, state_values[value_vector]);
        }
      }

      for (int64_t t = 0; t < BlockSize; ++t) {
        for (int64_t value_vector = 0; value_vector < value_vectors; ++value_vector) {
          _mm256_storeu_ps(
              y[t] + value_index + value_vector * kAvx2Width, output[t][value_vector]);
        }
      }
    }
    for (int64_t value_index = tiled_end; value_index < value_end; ++value_index) {
      float output[BlockSize];
      float weighted_value[BlockSize];
      for (int64_t t = 0; t < BlockSize; ++t) {
        output[t] = y[t][value_index];
        weighted_value[t] = input_weight[t] * v[t][value_index];
      }
      for (int64_t key_index = key_begin; key_index < key_end; ++key_index) {
        float state = C[key_index * Dv + value_index];
        for (int64_t t = 0; t < BlockSize; ++t) {
          state = forget_weight[t] * state + k[t][key_index] * weighted_value[t];
          output[t] += state * q[t][key_index];
        }
        C[key_index * Dv + value_index] = state;
      }
      for (int64_t t = 0; t < BlockSize; ++t) {
        y[t][value_index] = output[t];
      }
    }
  }

  for (int64_t t = 0; t < BlockSize; ++t) {
    const __m256 scale = _mm256_set1_ps(output_scale[t]);
    int64_t value_index = value_begin;
    for (; value_index + kAvx2Width <= value_end; value_index += kAvx2Width) {
      _mm256_storeu_ps(
          y[t] + value_index,
          _mm256_mul_ps(_mm256_loadu_ps(y[t] + value_index), scale));
    }
    for (; value_index < value_end; ++value_index) {
      y[t][value_index] *= output_scale[t];
    }
  }
}

template <int64_t BlockSize>
float process_temporal_block(
    const float* q,
    const float* k,
    const float* v,
    const float* i_tilde,
    const float* f_tilde,
    float* C,
    float* n,
    float m,
    float* y,
    int64_t Dk,
    int64_t Dv,
    int64_t key_block_size,
    float query_scale,
    float eps) {
  TokenBlock<BlockSize> tokens;
  PreparedGates<BlockSize> gates;
  const float next_m = prepare_temporal_block<BlockSize>(
      q, k, v, i_tilde, f_tilde, n, m, Dk, Dv, query_scale, tokens, y,
      gates, eps);
  update_state_and_output_key_blocks<BlockSize>(
      C, tokens.k, tokens.q, tokens.v, gates.forget_weight, gates.input_weight,
      gates.output_scale, Dk, Dv, key_block_size, 0, Dv, tokens.y);
  return next_m;
}

// Give each thread whole states, advancing BlockSize tokens at a time. Use the
// single-token path for any remainder.
template <int64_t BlockSize>
void process_whole_states(
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
    int threads,
    int64_t key_block_size,
    float eps) {
  const float query_scale = inv_sqrt_dim(Dk);

  auto process_state = [&](int64_t state) {
    float* const C_state = C + state * Dk * Dv;
    float* const n_state = n + state * Dk;
    float m_state = m[state];
    int64_t t = 0;
    for (; t + BlockSize <= T; t += BlockSize) {
      const int64_t token = state * T + t;
      m_state = process_temporal_block<BlockSize>(
          q + token * Dk, k + token * Dk, v + token * Dv, i_tilde + token,
          f_tilde + token, C_state, n_state, m_state, y + token * Dv, Dk, Dv,
          key_block_size, query_scale, eps);
    }
    for (; t < T; ++t) {
      const int64_t token = state * T + t;
      m_state = process_temporal_block<1>(
          q + token * Dk, k + token * Dk, v + token * Dv, i_tilde + token,
          f_tilde + token, C_state, n_state, m_state, y + token * Dv, Dk, Dv,
          key_block_size, query_scale, eps);
    }
    m[state] = m_state;
  };

  const int64_t state_count = B * H;
  run_threads(threads, [&] {
    // nowait is safe: the parallel region's end synchronizes the team.
#pragma omp for schedule(static) nowait
    for (int64_t state = 0; state < state_count; ++state) {
      process_state(state);
    }
  });
}

// Prepare all states' gates and normalizers, then synchronize at the omp-for
// barrier. Each thread advances its own C columns through the token blocks,
// using the single-token path for a remainder.
template <int64_t BlockSize>
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
    int threads,
    int64_t key_block_size,
    float eps) {
  const int64_t block_count = T / BlockSize;
  const int64_t remainder = T % BlockSize;
  std::vector<PreparedGates<BlockSize>> prepared(state_count * block_count);
  std::vector<PreparedGates<1>> prepared_remainder(state_count * remainder);
  const float query_scale = inv_sqrt_dim(Dk);

#pragma omp parallel num_threads(threads)
  {
#pragma omp for schedule(static)
    for (int64_t state = 0; state < state_count; ++state) {
      float* const n_state = n + state * Dk;
      float state_m = m[state];
      for (int64_t block = 0; block < block_count; ++block) {
        const int64_t token = state * T + block * BlockSize;
        TokenBlock<BlockSize> tokens;
        state_m = prepare_temporal_block<BlockSize>(
            q + token * Dk, k + token * Dk, v + token * Dv, i_tilde + token,
            f_tilde + token, n_state, state_m, Dk, Dv, query_scale, tokens,
            y + token * Dv, prepared[state * block_count + block], eps);
      }
      for (int64_t r = 0; r < remainder; ++r) {
        const int64_t token = state * T + block_count * BlockSize + r;
        TokenBlock<1> tokens;
        state_m = prepare_temporal_block<1>(
            q + token * Dk, k + token * Dk, v + token * Dv, i_tilde + token,
            f_tilde + token, n_state, state_m, Dk, Dv, query_scale, tokens,
            y + token * Dv, prepared_remainder[state * remainder + r], eps);
      }
      m[state] = state_m;
    }

    const StateWorker worker =
        assign_state_worker(omp_get_thread_num(), threads, state_count);
    const int64_t tiles = Dv / kColumnUnit;
    const int64_t value_begin =
        kColumnUnit * (tiles * worker.value_worker / worker.workers_for_state);
    const int64_t value_end =
        kColumnUnit * (tiles * (worker.value_worker + 1) / worker.workers_for_state);
    float* const C_state = C + worker.state * Dk * Dv;

    for (int64_t block = 0; block < block_count; ++block) {
      const int64_t token = worker.state * T + block * BlockSize;
      const TokenBlock<BlockSize> tokens(
          q + token * Dk, k + token * Dk, v + token * Dv, y + token * Dv, Dk, Dv);
      const PreparedGates<BlockSize>& gates = prepared[worker.state * block_count + block];
      update_state_and_output_key_blocks<BlockSize>(
          C_state, tokens.k, tokens.q, tokens.v, gates.forget_weight,
          gates.input_weight, gates.output_scale, Dk, Dv, key_block_size,
          value_begin, value_end, tokens.y);
    }
    for (int64_t r = 0; r < remainder; ++r) {
      const int64_t token = worker.state * T + block_count * BlockSize + r;
      const TokenBlock<1> tokens(
          q + token * Dk, k + token * Dk, v + token * Dv, y + token * Dv, Dk, Dv);
      const PreparedGates<1>& gates = prepared_remainder[worker.state * remainder + r];
      update_state_and_output_key_blocks<1>(
          C_state, tokens.k, tokens.q, tokens.v, gates.forget_weight,
          gates.input_weight, gates.output_scale, Dk, Dv, key_block_size,
          value_begin, value_end, tokens.y);
    }
  }
}

// Honor MLSTM_SPLIT with value-column splitting when Dv fills column units;
// otherwise assign whole states.
template <int64_t BlockSize>
void process_sequence(
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
  const int64_t state_count = B * H;
  const int64_t threads = requested_bhtd_threads();
  const int split_threads =
      Dv % kColumnUnit == 0 ? split_state_threads(threads, state_count, Dv) : 0;
  const int64_t key_block_size = choose_key_block_size(Dk, split_threads > 0);
  if (split_threads > 0) {
    process_split_states<BlockSize>(
        q, k, v, i_tilde, f_tilde, C, n, m, y, T, Dk, Dv, state_count,
        split_threads, key_block_size, eps);
    return;
  }
  process_whole_states<BlockSize>(
      q, k, v, i_tilde, f_tilde, C, n, m, y, B, T, H, Dk, Dv,
      static_cast<int>(std::min(threads, state_count)), key_block_size, eps);
}

}  // namespace

// Use single-token updates for all sequence lengths.
void mlstm_core_sequence_avx2_c_t_fused_r16_bhtd_unblocked(
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
  process_sequence<1>(q, k, v, i_tilde, f_tilde, C, n, m, y, B, T, H, Dk, Dv, eps);
}

// Process token pairs when T>=2, then one trailing token if needed; T=1 uses a
// single step.
void mlstm_core_sequence_avx2_c_t_fused_r16_bhtd(
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
  if (T >= 2) {
    process_sequence<2>(q, k, v, i_tilde, f_tilde, C, n, m, y, B, T, H, Dk, Dv, eps);
  } else {
    process_sequence<1>(q, k, v, i_tilde, f_tilde, C, n, m, y, B, T, H, Dk, Dv, eps);
  }
}

}  // namespace mlstm_cpu
