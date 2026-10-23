// ColPanel uses BHTD q/k/v/y and C [Dk,Dv] per (batch, head). Prepare all token
// gates and scales per state, then advance each 16-column panel through T
// tokens. Pack once and reuse each C load for two tokens. At T=1, update dense
// C directly and mask partial panels.

#include "mlstm_bhtd_utils.h"
#include "mlstm_kernels.h"
#include "stable_math.h"

#include <algorithm>
#include <cstddef>
#include <cstdint>
#include <memory>
#include <vector>

#include <immintrin.h>
#include <omp.h>

namespace mlstm_cpu {
namespace {

// Mask incomplete panels. For eight or fewer columns, never form a pointer to
// the second vector, which may lie beyond storage.
struct PanelIO {
  int columns;
  __m256i low_mask, high_mask;

  explicit PanelIO(int width) : columns(width) {
    const __m256i lanes = _mm256_setr_epi32(0, 1, 2, 3, 4, 5, 6, 7);
    low_mask = _mm256_cmpgt_epi32(_mm256_set1_epi32(width), lanes);
    high_mask = _mm256_cmpgt_epi32(_mm256_set1_epi32(width - 8), lanes);
  }

  template<bool Full>
  inline void load(const float* p, __m256& low, __m256& high) const {
    if constexpr (Full) {
      low = _mm256_loadu_ps(p);
      high = _mm256_loadu_ps(p + 8);
    } else {
      low = _mm256_maskload_ps(p, low_mask);
      high = columns > 8 ? _mm256_maskload_ps(p + 8, high_mask)
                         : _mm256_setzero_ps();
    }
  }

  template<bool Full>
  inline void store(float* p, __m256 low, __m256 high) const {
    if constexpr (Full) {
      _mm256_storeu_ps(p, low);
      _mm256_storeu_ps(p + 8, high);
    } else {
      _mm256_maskstore_ps(p, low_mask, low);
      if (columns > 8) _mm256_maskstore_ps(p + 8, high_mask, high);
    }
  }
};

// Packed rows have 16 floats with zero padding. The T=1 path uses dense,
// unpadded C, so mask partial rows to stay within caller storage.
template<bool Packed, bool Full>
void advance_panel(
    const float* q, const float* k, const float* v, const Gate* gates,
    float* state, float* y, int64_t T, int64_t Dk, int64_t Dv,
    const PanelIO& io) {
  const int64_t stride = Packed ? kColumnUnit : Dv;
  int64_t t = 0;
  for (; t + 1 < T; t += 2) {
    const Gate& g0 = gates[t];
    const Gate& g1 = gates[t + 1];
    const __m256 f0 = _mm256_set1_ps(g0.f);
    const __m256 f1 = _mm256_set1_ps(g1.f);
    __m256 v00, v01, v10, v11;
    io.load<Full>(v + t * Dv, v00, v01);
    io.load<Full>(v + (t + 1) * Dv, v10, v11);
    const float* q0 = q + t * Dk;
    const float* q1 = q0 + Dk;
    const float* k0 = k + t * Dk;
    const float* k1 = k0 + Dk;
    __m256 y00 = _mm256_setzero_ps(), y01 = _mm256_setzero_ps();
    __m256 y10 = _mm256_setzero_ps(), y11 = _mm256_setzero_ps();

    for (int64_t c = 0; c < Dk; ++c) {
      float* row = state + c * stride;
      __m256 c0, c1;
      io.load<Packed || Full>(row, c0, c1);

      // Update C and accumulate token t's readout before the next state update.
      const __m256 ik0 = _mm256_set1_ps(g0.i * k0[c]);
      c0 = _mm256_fmadd_ps(ik0, v00, _mm256_mul_ps(f0, c0));
      c1 = _mm256_fmadd_ps(ik0, v01, _mm256_mul_ps(f0, c1));
      const __m256 query0 = _mm256_set1_ps(q0[c]);
      y00 = _mm256_fmadd_ps(query0, c0, y00);
      y01 = _mm256_fmadd_ps(query0, c1, y01);

      // Advance the updated C to token t+1 in the same registers.
      const __m256 ik1 = _mm256_set1_ps(g1.i * k1[c]);
      c0 = _mm256_fmadd_ps(ik1, v10, _mm256_mul_ps(f1, c0));
      c1 = _mm256_fmadd_ps(ik1, v11, _mm256_mul_ps(f1, c1));
      const __m256 query1 = _mm256_set1_ps(q1[c]);
      y10 = _mm256_fmadd_ps(query1, c0, y10);
      y11 = _mm256_fmadd_ps(query1, c1, y11);
      io.store<Packed || Full>(row, c0, c1);
    }

    const __m256 scale0 = _mm256_set1_ps(g0.scale);
    const __m256 scale1 = _mm256_set1_ps(g1.scale);
    io.store<Full>(y + t * Dv,
                  _mm256_mul_ps(y00, scale0), _mm256_mul_ps(y01, scale0));
    io.store<Full>(y + (t + 1) * Dv,
                  _mm256_mul_ps(y10, scale1), _mm256_mul_ps(y11, scale1));
  }

  if (t < T) {
    const Gate& g = gates[t];
    const __m256 fv = _mm256_set1_ps(g.f);
    __m256 v0, v1;
    io.load<Full>(v + t * Dv, v0, v1);
    const float* qt = q + t * Dk;
    const float* kt = k + t * Dk;
    __m256 y0 = _mm256_setzero_ps(), y1 = _mm256_setzero_ps();
    for (int64_t c = 0; c < Dk; ++c) {
      float* row = state + c * stride;
      __m256 c0, c1;
      io.load<Packed || Full>(row, c0, c1);
      const __m256 ik = _mm256_set1_ps(g.i * kt[c]);
      c0 = _mm256_fmadd_ps(ik, v0, _mm256_mul_ps(fv, c0));
      c1 = _mm256_fmadd_ps(ik, v1, _mm256_mul_ps(fv, c1));
      const __m256 query = _mm256_set1_ps(qt[c]);
      y0 = _mm256_fmadd_ps(query, c0, y0);
      y1 = _mm256_fmadd_ps(query, c1, y1);
      io.store<Packed || Full>(row, c0, c1);
    }
    const __m256 scale = _mm256_set1_ps(g.scale);
    io.store<Full>(y + t * Dv,
                  _mm256_mul_ps(y0, scale), _mm256_mul_ps(y1, scale));
  }
}

template<bool Full>
void process_panel(
    const float* q, const float* k, const float* v, const Gate* gates,
    float* C, float* y, float* packed, int64_t T, int64_t Dk, int64_t Dv,
    int columns) {
  const PanelIO io(columns);
  if (T == 1) {
    advance_panel<false, Full>(q, k, v, gates, C, y, T, Dk, Dv, io);
    return;
  }

  for (int64_t c = 0; c < Dk; ++c) {
    __m256 low, high;
    io.load<Full>(C + c * Dv, low, high);
    io.store<true>(packed + c * kColumnUnit, low, high);
  }

  advance_panel<true, Full>(q, k, v, gates, packed, y, T, Dk, Dv, io);

  for (int64_t c = 0; c < Dk; ++c) {
    __m256 low, high;
    io.load<true>(packed + c * kColumnUnit, low, high);
    io.store<Full>(C + c * Dv, low, high);
  }
}

}  // namespace

void mlstm_core_sequence_recurrent_avx2_panelwise_bhtd(
    const float* q, const float* k, const float* v,
    const float* i_tilde, const float* f_tilde, float* C, float* n, float* m, float* y,
    int64_t B, int64_t T, int64_t H, int64_t Dk, int64_t Dv,
    float eps) {
  const int64_t states = B * H;
  const int64_t panels = (Dv + kColumnUnit - 1) / kColumnUnit;
  const int64_t tasks = states * panels;
  const int threads = static_cast<int>(
      std::min<int64_t>(requested_bhtd_threads(), tasks));
  const float q_scale = inv_sqrt_dim(Dk);

  // Allocate scratch before OpenMP to avoid per-panel allocation or allocation
  // failure after state mutation.
  std::vector<Gate> gates(static_cast<size_t>(states * T));
  const size_t panel_floats = static_cast<size_t>(Dk) * kColumnUnit;
  std::unique_ptr<float[]> scratch;
  float* scratch_base = nullptr;
  if (T > 1) {
    // Align the base to 64 bytes so every thread slice starts on a cache line.
    scratch.reset(new float[static_cast<size_t>(threads) * panel_floats + 15]);
    const uintptr_t raw = reinterpret_cast<uintptr_t>(scratch.get());
    scratch_base = reinterpret_cast<float*>((raw + 63) & ~uintptr_t(63));
  }

  run_threads(threads, [&] {
    const int worker = omp_get_thread_num();
#pragma omp for schedule(static)
    for (int64_t state = 0; state < states; ++state) {
      float* ns = n + state * Dk;
      float& ms = m[state];
      for (int64_t t = 0; t < T; ++t) {
        const int64_t token = state * T + t;
        gates[token] = prepare_gate(
            q + token * Dk, k + token * Dk, i_tilde[token], f_tilde[token],
            ns, ms, Dk, q_scale, eps);
      }
    }
    // The preceding omp-for's implicit barrier makes all gates visible here.
    float* packed = scratch_base ? scratch_base + worker * panel_floats : nullptr;
#pragma omp for schedule(static)
    for (int64_t task = 0; task < tasks; ++task) {
      const int64_t state = task / panels;
      const int64_t r = (task % panels) * kColumnUnit;
      const int columns = static_cast<int>(std::min(kColumnUnit, Dv - r));
      const int64_t token = state * T;
      const float* qs = q + token * Dk;
      const float* ks = k + token * Dk;
      const float* vs = v + token * Dv + r;
      const Gate* gs = gates.data() + token;
      float* cs = C + state * Dk * Dv + r;
      float* ys = y + token * Dv + r;
      if (columns == kColumnUnit) {
        process_panel<true>(qs, ks, vs, gs, cs, ys, packed, T, Dk, Dv, columns);
      } else {
        process_panel<false>(qs, ks, vs, gs, cs, ys, packed, T, Dk, Dv, columns);
      }
    }
  });
}

}  // namespace mlstm_cpu
