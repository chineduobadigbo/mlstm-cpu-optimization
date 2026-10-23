// Share recurrence loops between scalar and compiler-vectorized builds. The
// including file chooses GCC vectorization settings and names the entry point
// with MLSTM_SCALAR_SEQUENCE.
namespace mlstm_cpu {

namespace {

void step_state(
    const float* q,
    const float* k,
    const float* v,
    float i_tilde,
    float f_tilde,
    const float* C,
    const float* n,
    float m,
    float* y,
    float* C_next,
    float* n_next,
    float* m_next,
    int64_t Dk,
    int64_t Dv,
    float eps) {
  const float log_f = log_sigmoid_stable(f_tilde);
  const float m_new = std::max(log_f + m, i_tilde);
  const float f = std::exp(log_f + m - m_new);
  const float i = std::exp(i_tilde - m_new);
  const float q_scale = inv_sqrt_dim(Dk);

  float dot_n_q_scaled = 0.0f;
  for (int64_t c = 0; c < Dk; ++c) {
    const float n_val = f * n[c] + i * k[c];
    n_next[c] = n_val;
    dot_n_q_scaled += n_val * (q[c] * q_scale);
  }

  const float denom =
      std::max(std::abs(dot_n_q_scaled), std::exp(-m_new)) + eps;

  for (int64_t r = 0; r < Dv; ++r) {
    const float alpha = i * v[r];
    const int64_t row_offset = r * Dk;
    float dot_c_q = 0.0f;
    for (int64_t c = 0; c < Dk; ++c) {
      const float c_new = f * C[row_offset + c] + alpha * k[c];
      C_next[row_offset + c] = c_new;
      dot_c_q += c_new * q[c];
    }
    y[r] = (dot_c_q * q_scale) / denom;
  }

  *m_next = m_new;
}

}  // namespace

void MLSTM_SCALAR_SEQUENCE(
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
  for (int64_t b = 0; b < B; ++b) {
    for (int64_t h = 0; h < H; ++h) {
      const int64_t state = b * H + h;
      for (int64_t t = 0; t < T; ++t) {
        const int64_t token_state = (b * T + t) * H + h;
        step_state(
            q + token_state * Dk,
            k + token_state * Dk,
            v + token_state * Dv,
            i_tilde[token_state],
            f_tilde[token_state],
            C + state * C_stride,
            n + state * Dk,
            m[state],
            Y + token_state * Dv,
            C + state * C_stride,
            n + state * Dk,
            m + state,
            Dk,
            Dv, eps);
      }
    }
  }
}

}  // namespace mlstm_cpu
