#include "mlstm_kernels.h"
#include "avx2_recurrent.h"

namespace mlstm_cpu {

namespace {

using detail::compute_denom_dot;
using detail::step_state_rows_avx2;

// Keep C slices in registers across the token block; load and store each once.
template <int BlockSize>
inline float step_state_block_avx2_c_rm_fused_r4_tb4(
    const float* q,
    const float* k,
    const float* v,
    const float* i_tilde,
    const float* f_tilde,
    float* C,
    float* n,
    float m,
    float* y,
    int64_t token_stride,
    int64_t qk_stride,
    int64_t v_stride,
    int64_t Dk,
    int64_t Dv,
    const float q_scale,
    float eps) {
  static_assert(BlockSize >= 2 && BlockSize <= 4);

  float f[BlockSize];
  float i[BlockSize];
  float output_scale[BlockSize];
  const float* q_block[BlockSize];
  const float* k_block[BlockSize];
  const float* v_block[BlockSize];
  float* y_block[BlockSize];

  for (int t = 0; t < BlockSize; ++t) {
    q_block[t] = q + t * qk_stride;
    k_block[t] = k + t * qk_stride;
    v_block[t] = v + t * v_stride;
    y_block[t] = y + t * v_stride;

    const float log_f = log_sigmoid_stable(f_tilde[t * token_stride]);
    const float m_new = std::max(log_f + m, i_tilde[t * token_stride]);
    f[t] = std::exp(log_f + m - m_new);
    i[t] = std::exp(i_tilde[t * token_stride] - m_new);

    const float dot_n_q_scaled =
        q_scale * compute_denom_dot(
            q_block[t], k_block[t], n, i[t], f[t], Dk);
    const float denom =
        std::max(std::abs(dot_n_q_scaled), std::exp(-m_new)) + eps;
    output_scale[t] = q_scale / denom;
    m = m_new;
  }

  for (int64_t r = 0; r < Dv; ++r) {
    float* C_row = C + r * Dk;
    float alpha[BlockSize];
    __m256 acc[BlockSize];
    for (int t = 0; t < BlockSize; ++t) {
      alpha[t] = i[t] * v_block[t][r];
      acc[t] = _mm256_setzero_ps();
    }

    int64_t c = 0;
    for (; c + kAvx2Width <= Dk; c += kAvx2Width) {
      __m256 C_vec = _mm256_loadu_ps(C_row + c);
      for (int t = 0; t < BlockSize; ++t) {
        const __m256 k_vec = _mm256_loadu_ps(k_block[t] + c);
        const __m256 q_vec = _mm256_loadu_ps(q_block[t] + c);
        C_vec = _mm256_fmadd_ps(
            _mm256_set1_ps(f[t]),
            C_vec,
            _mm256_mul_ps(_mm256_set1_ps(alpha[t]), k_vec));
        acc[t] = _mm256_fmadd_ps(C_vec, q_vec, acc[t]);
      }
      _mm256_storeu_ps(C_row + c, C_vec);
    }

    float dot[BlockSize];
    for (int t = 0; t < BlockSize; ++t) {
      dot[t] = hsum256_ps(acc[t]);
    }
    for (; c < Dk; ++c) {
      float C_value = C_row[c];
      for (int t = 0; t < BlockSize; ++t) {
        C_value = f[t] * C_value + alpha[t] * k_block[t][c];
        dot[t] += C_value * q_block[t][c];
      }
      C_row[c] = C_value;
    }
    for (int t = 0; t < BlockSize; ++t) {
      y_block[t][r] = dot[t] * output_scale[t];
    }
  }

  return m;
}

}  // namespace

void mlstm_core_sequence_avx2_c_rm_fused_r4_tb4(
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
  const int64_t C_stride = Dv * Dk;
  const float q_scale = inv_sqrt_dim(Dk);
  const bool use_temporal_blocking = T >= 2;
  for (int64_t b = 0; b < B; ++b) {
    for (int64_t h = 0; h < H; ++h) {
      const int64_t state = b * H + h;
      float* C_state = C + state * C_stride;
      float* n_state = n + state * Dk;
      float m_local = m[state];
      int64_t t = 0;
      if (use_temporal_blocking) {
        const int64_t token_stride = H;
        const int64_t qk_stride = H * Dk;
        const int64_t v_stride = H * Dv;
        for (; t + 4 <= T; t += 4) {
          const int64_t token_state = (b * T + t) * H + h;
          m_local = step_state_block_avx2_c_rm_fused_r4_tb4<4>(
              q + token_state * Dk,
              k + token_state * Dk,
              v + token_state * Dv,
              i_tilde + token_state,
              f_tilde + token_state,
              C_state,
              n_state,
              m_local,
              Y + token_state * Dv,
              token_stride,
              qk_stride,
              v_stride,
              Dk,
              Dv,
              q_scale, eps);
        }
        if (t + 3 <= T) {
          const int64_t token_state = (b * T + t) * H + h;
          m_local = step_state_block_avx2_c_rm_fused_r4_tb4<3>(
              q + token_state * Dk,
              k + token_state * Dk,
              v + token_state * Dv,
              i_tilde + token_state,
              f_tilde + token_state,
              C_state,
              n_state,
              m_local,
              Y + token_state * Dv,
              token_stride,
              qk_stride,
              v_stride,
              Dk,
              Dv,
              q_scale, eps);
          t += 3;
        } else if (t + 2 <= T) {
          const int64_t token_state = (b * T + t) * H + h;
          m_local = step_state_block_avx2_c_rm_fused_r4_tb4<2>(
              q + token_state * Dk,
              k + token_state * Dk,
              v + token_state * Dv,
              i_tilde + token_state,
              f_tilde + token_state,
              C_state,
              n_state,
              m_local,
              Y + token_state * Dv,
              token_stride,
              qk_stride,
              v_stride,
              Dk,
              Dv,
              q_scale, eps);
          t += 2;
        }
      }
      for (; t < T; ++t) {
        const int64_t token_state = (b * T + t) * H + h;
        m_local = step_state_rows_avx2<4>(
            q + token_state * Dk,
            k + token_state * Dk,
            v + token_state * Dv,
            i_tilde[token_state],
            f_tilde[token_state],
            C_state,
            n_state,
            m_local,
            Y + token_state * Dv,
            Dk,
            Dv,
            eps);
      }
      m[state] = m_local;
    }
  }
}

}  // namespace mlstm_cpu
