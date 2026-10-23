// Read or set MXCSR outside timing through the extension's OpenMP runtime.
// Negative set_flags reads only; otherwise replace each thread's FTZ/DAZ bits.
// Use 0 for gradual underflow or 0x8040 for flush-to-zero and
// denormals-as-zero.
#include <immintrin.h>
#include <omp.h>
#include <sched.h>
#include <sys/syscall.h>
#include <unistd.h>

extern "C" int fp_probe(int threads, int set_flags,
                        unsigned* csr, int* tids, int* cpus) {
  int actual = 0;
  #pragma omp parallel num_threads(threads)
  {
    const int worker = omp_get_thread_num();
    if (set_flags >= 0) _mm_setcsr((_mm_getcsr() & ~0x8040u) | unsigned(set_flags));
    csr[worker] = _mm_getcsr();
    tids[worker] = static_cast<int>(syscall(SYS_gettid));
    cpus[worker] = sched_getcpu();
    #pragma omp single
    actual = omp_get_num_threads();
  }
  return actual;
}
