// Shared validation and sequence dispatch for main and fast-math extensions.
#pragma once

#include <ATen/ATen.h>
#include <torch/library.h>

#include <cmath>
#include <limits>

#include "mlstm_kernels.h"

namespace {

using MlstmSequenceKernel = void (*)(
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
    float eps);

// Layouts: BTHD uses q/k/v/Y [B,T,H,D] and C [B,H,Dv,Dk];
// BHTD_C_T uses q/k/v/Y [B,H,T,D] and C_T [B,H,Dk,Dv].
enum class SequenceLayout { BTHD, BHTD_C_T };

float checked_eps(double eps) {
  TORCH_CHECK(std::isfinite(eps) && eps >= 0.0 &&
                  eps <= std::numeric_limits<float>::max(),
              "eps must be finite, nonnegative and within float32 range");
  return static_cast<float>(eps);
}

void check_float32(const at::Tensor& t, const char* name) {
  TORCH_CHECK(t.scalar_type() == at::kFloat, name, " must be float32");
}

// PyTorch dispatch ensures CPU inputs; check their dtype and contiguity here.
void check_tensor_contract(const at::Tensor& t, const char* name) {
  check_float32(t, name);
  TORCH_CHECK(t.is_contiguous(), name, " must be contiguous");
}

template <SequenceLayout Layout>
void check_sequence_shapes(
    const at::Tensor& q,
    const at::Tensor& k,
    const at::Tensor& v,
    const at::Tensor& i_tilde,
    const at::Tensor& f_tilde,
    const at::Tensor& C,
    const at::Tensor& n,
    const at::Tensor& m_state) {
  constexpr bool bhtd = Layout == SequenceLayout::BHTD_C_T;
  const char* const tokens = bhtd ? "[B,H,T" : "[B,T,H";
  const char* const C_shape =
      bhtd ? "C_T must have shape [B,H,Dk,Dv]" : "C must have shape [B,H,Dv,Dk]";
  // Infer dimensions from q/v; full-shape checks also verify tensor ranks.
  TORCH_CHECK(q.dim() == 4, "q must have shape ", tokens, ",Dk]");
  TORCH_CHECK(v.dim() == 4, "v must have shape ", tokens, ",Dv]");

  const int64_t B = q.size(0);
  const int64_t T = q.size(bhtd ? 2 : 1);
  const int64_t H = q.size(bhtd ? 1 : 2);
  const int64_t Dk = q.size(3);
  const int64_t Dv = v.size(3);
  TORCH_CHECK(B > 0 && T > 0 && H > 0 && Dk > 0 && Dv > 0,
              bhtd ? "B, H, T, Dk and Dv must be positive"
                   : "B, T, H, Dk and Dv must be positive");

  const at::IntArrayRef token_shape = q.sizes().slice(0, 3);
  TORCH_CHECK(k.sizes() == q.sizes(), "k must match q shape ", tokens, ",Dk]");
  TORCH_CHECK(v.sizes().slice(0, 3) == token_shape,
              "v must match q on ", tokens, "]");
  TORCH_CHECK(i_tilde.sizes() == token_shape,
              "i_tilde must have shape ", tokens, "]");
  TORCH_CHECK(f_tilde.sizes() == token_shape,
              "f_tilde must have shape ", tokens, "]");
  TORCH_CHECK(C.sizes() == (bhtd ? at::IntArrayRef({B, H, Dk, Dv})
                                 : at::IntArrayRef({B, H, Dv, Dk})),
              C_shape);
  TORCH_CHECK(n.sizes() == at::IntArrayRef({B, H, Dk}),
              "n must have shape [B,H,Dk]");
  TORCH_CHECK(m_state.sizes() == at::IntArrayRef({B, H}),
              "m must have shape [B,H]");
}

template <SequenceLayout Layout>
at::Tensor mlstm_core_sequence_dispatch(
    const at::Tensor& q,
    const at::Tensor& k,
    const at::Tensor& v,
    const at::Tensor& i_tilde,
    const at::Tensor& f_tilde,
    at::Tensor& C,
    at::Tensor& n,
    at::Tensor& m_state,
    double eps,
    MlstmSequenceKernel kernel,
    const char* op_name) {
  constexpr bool bhtd = Layout == SequenceLayout::BHTD_C_T;
  check_sequence_shapes<Layout>(q, k, v, i_tilde, f_tilde, C, n, m_state);
  check_tensor_contract(q, "q");
  check_tensor_contract(k, "k");
  check_tensor_contract(v, "v");
  check_tensor_contract(i_tilde, "i_tilde");
  check_tensor_contract(f_tilde, "f_tilde");
  check_tensor_contract(C, bhtd ? "C_T" : "C");
  check_tensor_contract(n, "n");
  check_tensor_contract(m_state, "m");
  TORCH_CHECK(!q.requires_grad() && !k.requires_grad() && !v.requires_grad() &&
                  !i_tilde.requires_grad() && !f_tilde.requires_grad() &&
                  !C.requires_grad() && !n.requires_grad() &&
                  !m_state.requires_grad(),
              op_name, " is inference-only; use the Python reference for ",
              "autograd experiments.");

  const int64_t B = q.size(0);
  const int64_t T = q.size(bhtd ? 2 : 1);
  const int64_t H = q.size(bhtd ? 1 : 2);
  const int64_t Dk = q.size(3);
  const int64_t Dv = v.size(3);

  const float kernel_eps = checked_eps(eps);
  at::Tensor Y = at::empty({q.size(0), q.size(1), q.size(2), Dv}, q.options());
  kernel(
      q.data_ptr<float>(),
      k.data_ptr<float>(),
      v.data_ptr<float>(),
      i_tilde.data_ptr<float>(),
      f_tilde.data_ptr<float>(),
      C.data_ptr<float>(),
      n.data_ptr<float>(),
      m_state.data_ptr<float>(),
      Y.data_ptr<float>(),
      B,
      T,
      H,
      Dk,
      Dv,
      kernel_eps);
  return Y;
}

template <SequenceLayout Layout>
at::Tensor mlstm_core_sequence_meta(
    const at::Tensor& q,
    const at::Tensor& k,
    const at::Tensor& v,
    const at::Tensor& i_tilde,
    const at::Tensor& f_tilde,
    at::Tensor& C,
    at::Tensor& n,
    at::Tensor& m_state,
    double eps) {
  check_sequence_shapes<Layout>(q, k, v, i_tilde, f_tilde, C, n, m_state);
  checked_eps(eps);
  check_float32(q, "q");
  return at::empty({q.size(0), q.size(1), q.size(2), v.size(3)},
                   q.options().device(at::kMeta));
}

template <MlstmSequenceKernel Kernel, SequenceLayout Layout>
void bind_sequence(torch::Library& m, const char* name) {
  m.impl(name, [name](
      const at::Tensor& q,
      const at::Tensor& k,
      const at::Tensor& v,
      const at::Tensor& i_tilde,
      const at::Tensor& f_tilde,
      at::Tensor& C,
      at::Tensor& n,
      at::Tensor& m_state,
      double eps) {
    return mlstm_core_sequence_dispatch<Layout>(
        q, k, v, i_tilde, f_tilde, C, n, m_state, eps, Kernel, name);
  });
}

constexpr SequenceLayout BTHD = SequenceLayout::BTHD;
constexpr SequenceLayout BHTD_C_T = SequenceLayout::BHTD_C_T;

}  // namespace
