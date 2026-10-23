#include <torch/extension.h>
#include <torch/library.h>

#define MLSTM_CORE_SEQUENCE_SCHEMA(name) \
  name "(Tensor q, Tensor k, Tensor v, " \
  "Tensor i_tilde, Tensor f_tilde, " \
  "Tensor(a!) C, Tensor(b!) n, Tensor(c!) m_state, float eps=0.0) -> Tensor"

TORCH_LIBRARY(mlstm_cpu, m) {
  m.def(MLSTM_CORE_SEQUENCE_SCHEMA("mlstm_core_sequence_scalar_c_rm_reference"));
  m.def(MLSTM_CORE_SEQUENCE_SCHEMA("mlstm_core_sequence_compiler_c_rm"));
  // Implemented by the separate mlstm_cpu._C_fastmath extension.
  m.def(MLSTM_CORE_SEQUENCE_SCHEMA("mlstm_core_sequence_compiler_fastmath_c_rm"));
  m.def(MLSTM_CORE_SEQUENCE_SCHEMA("mlstm_core_sequence_avx2_c_rm_fused_r1"));
  m.def(MLSTM_CORE_SEQUENCE_SCHEMA("mlstm_core_sequence_avx2_c_rm_rowsplit_r1"));
  m.def(MLSTM_CORE_SEQUENCE_SCHEMA("mlstm_core_sequence_avx2_c_rm_twopass_r1"));
  m.def(MLSTM_CORE_SEQUENCE_SCHEMA("mlstm_core_sequence_avx2_c_rm_fused_r2"));
  m.def(MLSTM_CORE_SEQUENCE_SCHEMA("mlstm_core_sequence_avx2_c_rm_fused_r4"));
  m.def(MLSTM_CORE_SEQUENCE_SCHEMA("mlstm_core_sequence_avx2_c_rm_fused_r4_tb4"));
  m.def(MLSTM_CORE_SEQUENCE_SCHEMA("mlstm_core_sequence_avx2_c_t_fused_r16_bhtd"));
  m.def(MLSTM_CORE_SEQUENCE_SCHEMA("mlstm_core_sequence_recurrent_avx2_panelwise_bhtd"));
  m.def(MLSTM_CORE_SEQUENCE_SCHEMA("mlstm_core_sequence_chunkwise_blas_bhtd"));
  m.def(MLSTM_CORE_SEQUENCE_SCHEMA("mlstm_core_sequence_chunkwise_avx2_bhtd"));
  m.def(MLSTM_CORE_SEQUENCE_SCHEMA("mlstm_core_sequence_avx2_c_t_fused_r16_bhtd_unblocked"));
}

#undef MLSTM_CORE_SEQUENCE_SCHEMA

// Load mlstm_cpu._C to register these PyTorch operators.
PYBIND11_MODULE(TORCH_EXTENSION_NAME, m) {}
