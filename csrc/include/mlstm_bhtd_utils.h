#pragma once

#include <algorithm>
#include <cerrno>
#include <cmath>
#include <cstdint>
#include <cstdlib>
#include <immintrin.h>

#include "avx2_utils.h"
#include "stable_math.h"

namespace mlstm_cpu {

// BHTD shapes: q/k [B,H,T,Dk], v/y [B,H,T,Dv], C [B,H,Dk,Dv].
// Each (batch, head) stores C[key*Dv+value], normalizer n [Dk] and scalar
// log stabilizer m.

// Split columns in 16-float units: two AVX2 vectors or one 64-byte cache line.
// With aligned C and Dv divisible by 16, threads write separate cache lines.
constexpr int64_t kColumnUnit = 16;

// Read an environment integer prefix, or default_value if missing, invalid, or
// out of range. Read settings once per kernel call.
inline int64_t get_env_int(const char* name, int64_t default_value) {
  const char* value = std::getenv(name);
  if (value == nullptr) {
    return default_value;
  }
  char* end = nullptr;
  errno = 0;
  const long long parsed = std::strtoll(value, &end, 10);
  return end == value || errno == ERANGE ? default_value : parsed;
}

inline int64_t requested_bhtd_threads() {
  return std::max<int64_t>(1, get_env_int("MLSTM_THREADS", 1));
}

// Run body on the requested OpenMP threads. With one thread, body runs directly
// without starting a team, like PyTorch parallel_for; omp-for loops then run
// entirely on the caller.
template <typename Body>
inline void run_threads(int threads, Body&& body) {
  if (threads == 1) {
    body();
    return;
  }
#pragma omp parallel num_threads(threads)
  body();
}

// Balance threads across states, giving extras to the first states. Threads
// within a state own separate value-column ranges.
struct StateWorker {
  int64_t state;
  int value_worker;
  int workers_for_state;
};

inline StateWorker assign_state_worker(
    int thread_id, int thread_count, int64_t state_count) {
  const int base_workers = thread_count / state_count;
  const int extra_states = thread_count % state_count;
  const int extra_workers = (base_workers + 1) * extra_states;
  if (thread_id < extra_workers) {
    return {thread_id / (base_workers + 1), thread_id % (base_workers + 1),
        base_workers + 1};
  }
  const int remaining_worker = thread_id - extra_workers;
  return {extra_states + remaining_worker / base_workers,
      remaining_worker % base_workers, base_workers};
}

// For MLSTM_SPLIT=1, cap the requested team at one thread per column unit.
// Return its size only if every state gets at least two threads; return 0 to
// use whole states otherwise.
inline int split_state_threads(int64_t threads, int64_t state_count, int64_t Dv) {
  if (get_env_int("MLSTM_SPLIT", 0) != 1) {
    return 0;
  }
  const int64_t team =
      std::min(threads, state_count * ((Dv + kColumnUnit - 1) / kColumnUnit));
  return team >= 2 * state_count ? static_cast<int>(team) : 0;
}

// Default to fixed eight-key blocks for whole states and all keys for
// split-state column slices. MLSTM_KEY_BLOCK overrides both.
inline int64_t choose_key_block_size(int64_t Dk, bool split_state) {
  const int64_t default_size = split_state ? Dk : std::min<int64_t>(8, Dk);
  return std::max<int64_t>(1, get_env_int("MLSTM_KEY_BLOCK", default_size));
}

struct Gate {
  float f, i, scale;
};

// Update n and m for one token; return stable gates and the readout scale.
// Recurrent n costs O(T*Dk) over a sequence and avoids score reductions or long
// log-prefix differences. q_scale=1/sqrt(Dk) scales readout and its
// denominator, leaving state updates unchanged.
static inline Gate prepare_gate(
    const float* q, const float* k, float i_tilde, float f_tilde,
    float* n, float& m, int64_t Dk, float q_scale, float eps) {
  const float log_f = log_sigmoid_stable(f_tilde);
  const float next_m = std::max(log_f + m, i_tilde);
  const float f = std::exp(log_f + m - next_m);
  const float i = std::exp(i_tilde - next_m);
  const __m256 fv = _mm256_set1_ps(f);
  const __m256 iv = _mm256_set1_ps(i);
  __m256 dot = _mm256_setzero_ps();
  int64_t c = 0;
  for (; c + kAvx2Width <= Dk; c += kAvx2Width) {
    const __m256 next_n = _mm256_add_ps(
        _mm256_mul_ps(fv, _mm256_loadu_ps(n + c)),
        _mm256_mul_ps(iv, _mm256_loadu_ps(k + c)));
    _mm256_storeu_ps(n + c, next_n);
    dot = _mm256_fmadd_ps(next_n, _mm256_loadu_ps(q + c), dot);
  }
  float d = hsum256_ps_hadd(dot);
  for (; c < Dk; ++c) {
    n[c] = f * n[c] + i * k[c];
    d += n[c] * q[c];
  }
  m = next_m;
  return {f, i,
          q_scale / (std::max(std::abs(q_scale * d), std::exp(-next_m)) + eps)};
}

}  // namespace mlstm_cpu
