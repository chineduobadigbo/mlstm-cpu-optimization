// Compare separate update/readout passes with fused Row1 using identical
// arithmetic and summation order. rowsplit reads back each updated row; twopass
// updates all of C before readout.
#include "mlstm_kernels.h"
#include "avx2_recurrent.h"

namespace mlstm_cpu {

namespace {

using detail::compute_denom_dot;

void update_c_row_avx2(float* C_row, const float* k, float f, float alpha, int64_t Dk) {
  const __m256 f_vec = _mm256_set1_ps(f);
  const __m256 alpha_vec = _mm256_set1_ps(alpha);
  int64_t c = 0;
  for (; c + kAvx2Width <= Dk; c += kAvx2Width) {
    _mm256_storeu_ps(C_row + c, _mm256_fmadd_ps(
        f_vec, _mm256_loadu_ps(C_row + c), _mm256_mul_ps(alpha_vec, _mm256_loadu_ps(k + c))));
  }
  for (; c < Dk; ++c) {
    C_row[c] = f * C_row[c] + alpha * k[c];
  }
}

// Row1 sum order: accumulate eight lanes, reduce, then add scalar tails.
float dot_c_row_avx2(const float* C_row, const float* q, int64_t Dk) {
  __m256 acc = _mm256_setzero_ps();
  int64_t c = 0;
  for (; c + kAvx2Width <= Dk; c += kAvx2Width) {
    acc = _mm256_fmadd_ps(_mm256_loadu_ps(C_row + c), _mm256_loadu_ps(q + c), acc);
  }
  float dot = hsum256_ps(acc);
  for (; c < Dk; ++c) {
    dot += C_row[c] * q[c];
  }
  return dot;
}

// Keep the step uninlined, as in Row1, to preserve the loops under comparison.
template <bool TwoPass>
__attribute__((noinline)) float step_state_unfused_r1(
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

  if (TwoPass) {
    for (int64_t r = 0; r < Dv; ++r) {
      update_c_row_avx2(C + r * Dk, k, f, i * v[r], Dk);
    }
    for (int64_t r = 0; r < Dv; ++r) {
      y[r] = dot_c_row_avx2(C + r * Dk, q, Dk) * output_scale;
    }
  } else {
    for (int64_t r = 0; r < Dv; ++r) {
      update_c_row_avx2(C + r * Dk, k, f, i * v[r], Dk);
      y[r] = dot_c_row_avx2(C + r * Dk, q, Dk) * output_scale;
    }
  }
  return m_new;
}

template <bool TwoPass>
void sequence_unfused_r1(
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
        m[state] = step_state_unfused_r1<TwoPass>(
            q + token * Dk, k + token * Dk, v + token * Dv, i_tilde[token],
            f_tilde[token], C + state * Dv * Dk, n + state * Dk, m[state],
            Y + token * Dv, Dk, Dv, eps);
      }
    }
  }
}

}  // namespace

void mlstm_core_sequence_avx2_c_rm_rowsplit_r1(
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
  sequence_unfused_r1<false>(q, k, v, i_tilde, f_tilde, C, n, m, Y, B, T, H, Dk, Dv, eps);
}

void mlstm_core_sequence_avx2_c_rm_twopass_r1(
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
  sequence_unfused_r1<true>(q, k, v, i_tilde, f_tilde, C, n, m, Y, B, T, H, Dk, Dv, eps);
}

}  // namespace mlstm_cpu
