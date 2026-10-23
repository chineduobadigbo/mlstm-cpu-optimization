#pragma once

#include <cstdint>

namespace mlstm_cpu {

void mlstm_core_sequence_scalar_c_rm_reference(
    const float* q, const float* k, const float* v,
    const float* i_tilde, const float* f_tilde, float* C, float* n, float* m, float* Y,
    int64_t B, int64_t T, int64_t H, int64_t Dk, int64_t Dv,
    float eps);

void mlstm_core_sequence_compiler_c_rm(
    const float* q, const float* k, const float* v,
    const float* i_tilde, const float* f_tilde, float* C, float* n, float* m, float* Y,
    int64_t B, int64_t T, int64_t H, int64_t Dk, int64_t Dv,
    float eps);

// Shared-source fast-math variant built into mlstm_cpu._C_fastmath.
void mlstm_core_sequence_compiler_fastmath_c_rm(
    const float* q, const float* k, const float* v,
    const float* i_tilde, const float* f_tilde, float* C, float* n, float* m, float* Y,
    int64_t B, int64_t T, int64_t H, int64_t Dk, int64_t Dv,
    float eps);

void mlstm_core_sequence_avx2_c_rm_fused_r1(
    const float* q, const float* k, const float* v,
    const float* i_tilde, const float* f_tilde, float* C, float* n, float* m, float* Y,
    int64_t B, int64_t T, int64_t H, int64_t Dk, int64_t Dv,
    float eps);

// Fusion controls reuse fused_r1 arithmetic but read back each row or the full
// matrix.
void mlstm_core_sequence_avx2_c_rm_rowsplit_r1(
    const float* q, const float* k, const float* v,
    const float* i_tilde, const float* f_tilde, float* C, float* n, float* m, float* Y,
    int64_t B, int64_t T, int64_t H, int64_t Dk, int64_t Dv,
    float eps);

void mlstm_core_sequence_avx2_c_rm_twopass_r1(
    const float* q, const float* k, const float* v,
    const float* i_tilde, const float* f_tilde, float* C, float* n, float* m, float* Y,
    int64_t B, int64_t T, int64_t H, int64_t Dk, int64_t Dv,
    float eps);

void mlstm_core_sequence_avx2_c_rm_fused_r2(
    const float* q, const float* k, const float* v,
    const float* i_tilde, const float* f_tilde, float* C, float* n, float* m, float* Y,
    int64_t B, int64_t T, int64_t H, int64_t Dk, int64_t Dv,
    float eps);

void mlstm_core_sequence_avx2_c_t_fused_r16_bhtd(
    const float* q, const float* k, const float* v,
    const float* i_tilde, const float* f_tilde, float* C, float* n, float* m, float* Y,
    int64_t B, int64_t T, int64_t H, int64_t Dk, int64_t Dv,
    float eps);

void mlstm_core_sequence_recurrent_avx2_panelwise_bhtd(
    const float* q, const float* k, const float* v,
    const float* i_tilde, const float* f_tilde, float* C, float* n, float* m, float* Y,
    int64_t B, int64_t T, int64_t H, int64_t Dk, int64_t Dv,
    float eps);

void mlstm_core_sequence_chunkwise_blas_bhtd(
    const float* q, const float* k, const float* v,
    const float* i_tilde, const float* f_tilde, float* C, float* n, float* m, float* Y,
    int64_t B, int64_t T, int64_t H, int64_t Dk, int64_t Dv,
    float eps);

void mlstm_core_sequence_chunkwise_avx2_bhtd(
    const float* q, const float* k, const float* v,
    const float* i_tilde, const float* f_tilde, float* C, float* n, float* m, float* Y,
    int64_t B, int64_t T, int64_t H, int64_t Dk, int64_t Dv,
    float eps);

void mlstm_core_sequence_avx2_c_t_fused_r16_bhtd_unblocked(
    const float* q, const float* k, const float* v,
    const float* i_tilde, const float* f_tilde, float* C, float* n, float* m, float* Y,
    int64_t B, int64_t T, int64_t H, int64_t Dk, int64_t Dv,
    float eps);

void mlstm_core_sequence_avx2_c_rm_fused_r4(
    const float* q, const float* k, const float* v,
    const float* i_tilde, const float* f_tilde, float* C, float* n, float* m, float* Y,
    int64_t B, int64_t T, int64_t H, int64_t Dk, int64_t Dv,
    float eps);

void mlstm_core_sequence_avx2_c_rm_fused_r4_tb4(
    const float* q, const float* k, const float* v,
    const float* i_tilde, const float* f_tilde, float* C, float* n, float* m, float* Y,
    int64_t B, int64_t T, int64_t H, int64_t Dk, int64_t Dv,
    float eps);

}  // namespace mlstm_cpu
