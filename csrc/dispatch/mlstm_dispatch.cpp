#include "mlstm_dispatch.h"

TORCH_LIBRARY_IMPL(mlstm_cpu, CPU, m) {
  using namespace mlstm_cpu;
  bind_sequence<mlstm_core_sequence_scalar_c_rm_reference, BTHD>(
      m, "mlstm_core_sequence_scalar_c_rm_reference");
  bind_sequence<mlstm_core_sequence_compiler_c_rm, BTHD>(
      m, "mlstm_core_sequence_compiler_c_rm");
  bind_sequence<mlstm_core_sequence_avx2_c_rm_fused_r1, BTHD>(
      m, "mlstm_core_sequence_avx2_c_rm_fused_r1");
  bind_sequence<mlstm_core_sequence_avx2_c_rm_rowsplit_r1, BTHD>(
      m, "mlstm_core_sequence_avx2_c_rm_rowsplit_r1");
  bind_sequence<mlstm_core_sequence_avx2_c_rm_twopass_r1, BTHD>(
      m, "mlstm_core_sequence_avx2_c_rm_twopass_r1");
  bind_sequence<mlstm_core_sequence_avx2_c_rm_fused_r2, BTHD>(
      m, "mlstm_core_sequence_avx2_c_rm_fused_r2");
  bind_sequence<mlstm_core_sequence_avx2_c_rm_fused_r4, BTHD>(
      m, "mlstm_core_sequence_avx2_c_rm_fused_r4");
  bind_sequence<mlstm_core_sequence_avx2_c_rm_fused_r4_tb4, BTHD>(
      m, "mlstm_core_sequence_avx2_c_rm_fused_r4_tb4");
  bind_sequence<mlstm_core_sequence_avx2_c_t_fused_r16_bhtd, BHTD_C_T>(
      m, "mlstm_core_sequence_avx2_c_t_fused_r16_bhtd");
  bind_sequence<mlstm_core_sequence_recurrent_avx2_panelwise_bhtd, BHTD_C_T>(
      m, "mlstm_core_sequence_recurrent_avx2_panelwise_bhtd");
  bind_sequence<mlstm_core_sequence_chunkwise_blas_bhtd, BHTD_C_T>(
      m, "mlstm_core_sequence_chunkwise_blas_bhtd");
  bind_sequence<mlstm_core_sequence_chunkwise_avx2_bhtd, BHTD_C_T>(
      m, "mlstm_core_sequence_chunkwise_avx2_bhtd");
  bind_sequence<mlstm_core_sequence_avx2_c_t_fused_r16_bhtd_unblocked, BHTD_C_T>(
      m, "mlstm_core_sequence_avx2_c_t_fused_r16_bhtd_unblocked");
}

TORCH_LIBRARY_IMPL(mlstm_cpu, Meta, m) {
  constexpr auto bthd_meta = &mlstm_core_sequence_meta<BTHD>;
  constexpr auto bhtd_meta = &mlstm_core_sequence_meta<BHTD_C_T>;
  m.impl("mlstm_core_sequence_scalar_c_rm_reference", bthd_meta);
  m.impl("mlstm_core_sequence_compiler_c_rm", bthd_meta);
  m.impl("mlstm_core_sequence_avx2_c_rm_fused_r1", bthd_meta);
  m.impl("mlstm_core_sequence_avx2_c_rm_rowsplit_r1", bthd_meta);
  m.impl("mlstm_core_sequence_avx2_c_rm_twopass_r1", bthd_meta);
  m.impl("mlstm_core_sequence_avx2_c_rm_fused_r2", bthd_meta);
  m.impl("mlstm_core_sequence_avx2_c_rm_fused_r4", bthd_meta);
  m.impl("mlstm_core_sequence_avx2_c_rm_fused_r4_tb4", bthd_meta);
  m.impl("mlstm_core_sequence_avx2_c_t_fused_r16_bhtd", bhtd_meta);
  m.impl("mlstm_core_sequence_recurrent_avx2_panelwise_bhtd", bhtd_meta);
  m.impl("mlstm_core_sequence_chunkwise_blas_bhtd", bhtd_meta);
  m.impl("mlstm_core_sequence_chunkwise_avx2_bhtd", bhtd_meta);
  m.impl("mlstm_core_sequence_avx2_c_t_fused_r16_bhtd_unblocked", bhtd_meta);
}
