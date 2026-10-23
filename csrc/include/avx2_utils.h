#pragma once

#include <cstdint>
#include <immintrin.h>

// Preserve arithmetic order and SIMD tiles: both affect rounding. GCC may also
// fuse scalar a*b+c into FMA, so rearranging expressions can change results.
namespace mlstm_cpu {

constexpr int64_t kAvx2Width = 8;

// Both reductions use the same addition tree for bit-identical sums:
// ((x0+x4)+(x1+x5))+((x2+x6)+(x3+x7)). Keep the measured implementations:
// hsum256_ps for row-major and transposed R16; hsum256_ps_hadd for chunkwise,
// panelwise and BLAS.
static inline float hsum256_ps(__m256 v) {
  // Add corresponding lanes across 128-bit halves, then reduce the four sums.
  __m128 sum4 = _mm_add_ps(_mm256_castps256_ps128(v), _mm256_extractf128_ps(v, 1));
  __m128 shuf = _mm_movehdup_ps(sum4);  // Repeat odd lanes: [s1, s1, s3, s3].
  __m128 sums = _mm_add_ps(sum4, shuf);
  shuf = _mm_movehl_ps(shuf, sums);
  sums = _mm_add_ss(sums, shuf);
  return _mm_cvtss_f32(sums);
}

static inline float hsum256_ps_hadd(__m256 v) {
  __m128 sum = _mm_add_ps(_mm256_castps256_ps128(v), _mm256_extractf128_ps(v, 1));
  sum = _mm_hadd_ps(sum, sum);
  return _mm_cvtss_f32(_mm_hadd_ps(sum, sum));
}

}  // namespace mlstm_cpu
