#include "mlstm_kernels.h"

#include <algorithm>
#include <cmath>

#include "stable_math.h"

// Disable vectorization only for this scalar baseline, retaining -O3 and scalar
// FMA. Other files keep their own flags.
#if defined(__GNUC__) && !defined(__clang__)
#pragma GCC optimize("no-tree-loop-vectorize", "no-tree-slp-vectorize")
#else
#error "The non-vectorized scalar baseline currently requires GCC."
#endif

#define MLSTM_SCALAR_SEQUENCE mlstm_core_sequence_scalar_c_rm_reference
#include "mlstm_core_scalar_c_rm.inc"
