#include "mlstm_kernels.h"

#include <algorithm>
#include <cmath>

#include "stable_math.h"

// Compile CompilerVec separately with -ffast-math (setup.py), allowing GCC to
// reorder dot-product sums and vectorize.
#define MLSTM_SCALAR_SEQUENCE mlstm_core_sequence_compiler_fastmath_c_rm
#include "../mlstm_core_scalar_c_rm.inc"
