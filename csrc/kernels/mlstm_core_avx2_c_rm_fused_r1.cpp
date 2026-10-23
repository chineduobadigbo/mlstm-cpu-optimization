#include "mlstm_kernels.h"
#include "avx2_recurrent.h"

namespace mlstm_cpu {

// Fuse C update and readout using one row-major value row per AVX2 tile.
void mlstm_core_sequence_avx2_c_rm_fused_r1(
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
  detail::sequence_rows_avx2<1>(
      q, k, v, i_tilde, f_tilde, C, n, m, Y, B, T, H, Dk, Dv, eps);
}

}  // namespace mlstm_cpu
