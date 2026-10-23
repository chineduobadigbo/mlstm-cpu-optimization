#pragma once

#include <algorithm>
#include <cmath>
#include <cstdint>
#include <immintrin.h>

#include "avx2_utils.h"
#include "stable_math.h"

namespace mlstm_cpu::detail {

// Share row-major arithmetic across Row1, its unfused controls, Row2, Row4 and
// TokenBlock4. Sum dot products in eight lanes, reduce, then add scalar tails.
// Row1/2/4 differ only in the number of value rows processed together.

// Update n = f*n + i*k in place and return q dot n.
static inline float compute_denom_dot(
    const float* q,
    const float* k,
    float* n,
    float i,
    float f,
    int64_t Dk) {
  const __m256 i_vec = _mm256_set1_ps(i);
  const __m256 f_vec = _mm256_set1_ps(f);
  __m256 acc = _mm256_setzero_ps();
  int64_t c = 0;
  for (; c + kAvx2Width <= Dk; c += kAvx2Width) {
    const __m256 n_new = _mm256_add_ps(
        _mm256_mul_ps(f_vec, _mm256_loadu_ps(n + c)),
        _mm256_mul_ps(i_vec, _mm256_loadu_ps(k + c)));
    acc = _mm256_fmadd_ps(n_new, _mm256_loadu_ps(q + c), acc);
    _mm256_storeu_ps(n + c, n_new);
  }
  float dot = hsum256_ps(acc);
  for (; c < Dk; ++c) {
    n[c] = f * n[c] + i * k[c];
    dot += n[c] * q[c];
  }
  return dot;
}

// Update R adjacent Dk-wide rows: C[r] = f*C[r] + alpha[r]*k, then dot each
// with q. Share q/k loads across rows; load every row in a vector step before
// storing.
template <int R>
static inline void update_c_rows_and_dot_avx2(
    float* C,
    const float* k,
    const float* q,
    float f,
    const float* alpha,
    int64_t Dk,
    float* dot) {
  const __m256 f_vec = _mm256_set1_ps(f);
  __m256 alpha_vec[R];
  __m256 acc[R];
  for (int r = 0; r < R; ++r) {
    alpha_vec[r] = _mm256_set1_ps(alpha[r]);
    acc[r] = _mm256_setzero_ps();
  }
  int64_t c = 0;
  for (; c + kAvx2Width <= Dk; c += kAvx2Width) {
    const __m256 k_vec = _mm256_loadu_ps(k + c);
    const __m256 q_vec = _mm256_loadu_ps(q + c);
    __m256 c_new[R];
    for (int r = 0; r < R; ++r) {
      c_new[r] = _mm256_fmadd_ps(
          f_vec, _mm256_loadu_ps(C + r * Dk + c), _mm256_mul_ps(alpha_vec[r], k_vec));
      acc[r] = _mm256_fmadd_ps(c_new[r], q_vec, acc[r]);
    }
    for (int r = 0; r < R; ++r) {
      _mm256_storeu_ps(C + r * Dk + c, c_new[r]);
    }
  }
  for (int r = 0; r < R; ++r) {
    dot[r] = hsum256_ps(acc[r]);
  }
  for (; c < Dk; ++c) {
    for (int r = 0; r < R; ++r) {
      const float c_new = f * C[r * Dk + c] + alpha[r] * k[c];
      C[r * Dk + c] = c_new;
      dot[r] += c_new * q[c];
    }
  }
}

// Advance a token with R value rows per register tile and return updated m.
template <int R>
__attribute__((noinline)) static float step_state_rows_avx2(
    const float* q,
    const float* k,
    const float* v,
    float i_tilde,
    float f_tilde,
    float* C,
    float* n,
    float m,
    float* y,
    int64_t Dk,
    int64_t Dv,
    float eps) {
  const float log_f = log_sigmoid_stable(f_tilde);
  const float m_new = std::max(log_f + m, i_tilde);
  const float f = std::exp(log_f + m - m_new);
  const float i = std::exp(i_tilde - m_new);
  const float q_scale = inv_sqrt_dim(Dk);
  const float dot_n_q_scaled = q_scale * compute_denom_dot(q, k, n, i, f, Dk);
  const float denom = std::max(std::abs(dot_n_q_scaled), std::exp(-m_new)) + eps;
  const float output_scale = q_scale / denom;

  int64_t r = 0;
  for (; r + R <= Dv; r += R) {
    float alpha[R];
    float dot[R];
    for (int j = 0; j < R; ++j) {
      alpha[j] = i * v[r + j];
    }
    update_c_rows_and_dot_avx2<R>(C + r * Dk, k, q, f, alpha, Dk, dot);
    for (int j = 0; j < R; ++j) {
      y[r + j] = dot[j] * output_scale;
    }
  }
  for (; r < Dv; ++r) {
    const float alpha = i * v[r];
    float dot;
    update_c_rows_and_dot_avx2<1>(C + r * Dk, k, q, f, &alpha, Dk, &dot);
    y[r] = dot * output_scale;
  }
  return m_new;
}

// Advance each row-major (batch, head) state through the BTHD token sequence.
template <int R>
static inline void sequence_rows_avx2(
    const float* q,
    const float* k,
    const float* v,
    const float* i_tilde,
    const float* f_tilde,
    float* C,
    float* n,
    float* m,
    float* Y,
    int64_t B,
    int64_t T,
    int64_t H,
    int64_t Dk,
    int64_t Dv,
    float eps) {
  for (int64_t b = 0; b < B; ++b) {
    for (int64_t h = 0; h < H; ++h) {
      const int64_t state = b * H + h;
      for (int64_t t = 0; t < T; ++t) {
        const int64_t token = (b * T + t) * H + h;
        m[state] = step_state_rows_avx2<R>(
            q + token * Dk, k + token * Dk, v + token * Dv, i_tilde[token],
            f_tilde[token], C + state * Dv * Dk, n + state * Dk, m[state],
            Y + token * Dv, Dk, Dv, eps);
      }
    }
  }
}

}  // namespace mlstm_cpu::detail
