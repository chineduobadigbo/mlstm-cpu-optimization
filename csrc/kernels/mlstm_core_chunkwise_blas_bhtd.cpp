#include "mlstm_bhtd_utils.h"
#include "mlstm_kernels.h"
#include "stable_math.h"

#include <algorithm>
#include <vector>

namespace mlstm_cpu {
namespace {

// BLAS32 uses a fixed, untuned chunk length.
constexpr int64_t kBlasChunk = 32;

// Require PyTorch's exported LP64 sgemm_ (MKL in this build). Call it directly
// because ATen's non-template cpublas::gemm is private; no extra BLAS library
// is linked.
extern "C" void sgemm_(
    const char*, const char*, const int*, const int*, const int*,
    const float*, const float*, const int*, const float*, const int*,
    const float*, float*, const int*);

// Swap A and B to express row-major multiplication through column-major BLAS.
void gemm(
    bool transpose_a, bool transpose_b, int rows, int columns, int inner,
    float alpha, const float* a, int lda, const float* b, int ldb,
    float beta, float* c, int ldc) {
  const char ta = transpose_b ? 'T' : 'N';
  const char tb = transpose_a ? 'T' : 'N';
  sgemm_(&ta, &tb, &columns, &rows, &inner,
         &alpha, b, &ldb, a, &lda, &beta, c, &ldc);
}

float prepare_matrices(const float* Q, const float* K, const Gate* gates,
                       int length, int Dk,
                       float* scaled_q, float* scaled_k, float* scores) {
  gemm(false, true, length, length, Dk, 1, Q, Dk, K, Dk, 0, scores, length);

  float previous_weight = 1;
  for (int64_t t = 0; t < length; ++t) {
    const Gate& g = gates[t];
    previous_weight *= g.f;
    for (int64_t c = 0; c < Dk; ++c) {
      scaled_q[t * Dk + c] = (previous_weight * g.scale) * Q[t * Dk + c];
    }
    // Scale score (t,j) by scale[t]*i[j]*prod(f[j+1..t]); scale includes
    // 1/sqrt(Dk) and normalization. Stable gate factors are <=1, so multiply
    // directly, handling zero decay without division or approximation.
    float decay = 1;
    for (int64_t j = t; j >= 0; --j) {
      scores[t * length + j] *= g.scale * decay * gates[j].i;
      decay *= gates[j].f;
    }
    std::fill(scores + t * length + t + 1, scores + (t + 1) * length, 0);
  }

  float decay = 1;
  for (int64_t t = length; t-- > 0;) {
    const float weight = decay * gates[t].i;
    for (int64_t c = 0; c < Dk; ++c) {
      scaled_k[t * Dk + c] = weight * K[t * Dk + c];
    }
    decay *= gates[t].f;
  }
  return previous_weight;
}

void matrix_chunks(
    const float* q, const float* k, const float* v, const Gate* gates,
    float* C, float* y, int64_t T, int64_t Dk, int64_t Dv,
    int64_t r_begin, int64_t r_end) {
  const int64_t width = r_end - r_begin;
  C += r_begin;
  v += r_begin;
  y += r_begin;
  std::vector<float> workspace(kBlasChunk * kBlasChunk + 2 * kBlasChunk * Dk);
  float* scores = workspace.data();
  float* scaled_q = scores + kBlasChunk * kBlasChunk;
  float* scaled_k = scaled_q + kBlasChunk * Dk;

  for (int64_t start = 0; start < T; start += kBlasChunk) {
    const int64_t length = std::min(kBlasChunk, T - start);
    const float* Q = q + start * Dk;
    const float* K = k + start * Dk;
    const float* V = v + start * Dv;
    float* Y = y + start * Dv;
    const float previous_weight = prepare_matrices(Q,K,gates+start,length,Dk,
                                                   scaled_q,scaled_k,scores);

    // Compute Y = scaled_Q*C + scores*V before overwriting C.
    // Then form C_next = previous_weight*C + scaled_K^T*V.
    gemm(false, false, length, width, Dk, 1, scaled_q, Dk, C, Dv, 0, Y, Dv);
    gemm(false, false, length, width, length, 1, scores, length, V, Dv, 1, Y, Dv);
    gemm(true, false, Dk, width, length, 1, scaled_k, Dk, V, Dv, previous_weight, C, Dv);
  }
}

}  // namespace

void mlstm_core_sequence_chunkwise_blas_bhtd(
    const float* q, const float* k, const float* v,
    const float* i_tilde, const float* f_tilde, float* C, float* n, float* m, float* y,
    int64_t B, int64_t T, int64_t H, int64_t Dk, int64_t Dv,
    float eps) {
  const int64_t states = B * H;
  const int64_t value_tiles = (Dv + kColumnUnit - 1) / kColumnUnit;
  const int threads = static_cast<int>(std::min<int64_t>(
      requested_bhtd_threads(), states * value_tiles));
  const int64_t column_workers = std::min<int64_t>(
      value_tiles, (threads + states - 1) / states);
  const float q_scale = inv_sqrt_dim(Dk);
  std::vector<Gate> gates(states * T);
  run_threads(threads, [&] {
#pragma omp for schedule(static)
    for (int64_t state = 0; state < states; ++state) {
      for (int64_t t = 0; t < T; ++t) {
        const int64_t token = state * T + t;
        gates[token] = prepare_gate(q + token * Dk, k + token * Dk, i_tilde[token], f_tilde[token],
                                    n + state * Dk, m[state], Dk, q_scale, eps);
      }
    }
    // Assign each C/Y column range for the whole sequence. Recompute its small
    // QK product to keep scratch bounded by chunk size. Default non-nested MKL
    // threading runs each GEMM serially within a multi-thread team.
#pragma omp for collapse(2) schedule(static)
    for (int64_t state = 0; state < states; ++state) {
      for (int64_t worker = 0; worker < column_workers; ++worker) {
        const int64_t r_begin =
            std::min(Dv, kColumnUnit * (value_tiles * worker / column_workers));
        const int64_t r_end =
            std::min(Dv, kColumnUnit * (value_tiles * (worker + 1) / column_workers));
        matrix_chunks(q + state * T * Dk, k + state * T * Dk, v + state * T * Dv,
                      gates.data() + state * T, C + state * Dk * Dv, y + state * T * Dv,
                      T, Dk, Dv, r_begin, r_end);
      }
    }
  });
}

}  // namespace mlstm_cpu
