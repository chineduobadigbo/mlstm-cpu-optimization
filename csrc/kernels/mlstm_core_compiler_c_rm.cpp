#include "mlstm_kernels.h"

#include <algorithm>
#include <cmath>

#include "stable_math.h"

// Enable GCC loop and SLP vectorization on the scalar source. State updates may
// vectorize; without -ffast-math, dot-product additions retain source order.
#define MLSTM_SCALAR_SEQUENCE mlstm_core_sequence_compiler_c_rm
#include "mlstm_core_scalar_c_rm.inc"
