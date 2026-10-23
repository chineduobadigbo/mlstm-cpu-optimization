// Register CompilerVec fast-math separately to confine -ffast-math to this
// extension. schemas.cpp declares its operator with the other sequence
// operators.
#include <torch/extension.h>

#include "../mlstm_dispatch.h"

TORCH_LIBRARY_IMPL(mlstm_cpu, CPU, m) {
  bind_sequence<mlstm_cpu::mlstm_core_sequence_compiler_fastmath_c_rm, BTHD>(
      m, "mlstm_core_sequence_compiler_fastmath_c_rm");
}

TORCH_LIBRARY_IMPL(mlstm_cpu, Meta, m) {
  m.impl("mlstm_core_sequence_compiler_fastmath_c_rm", &mlstm_core_sequence_meta<BTHD>);
}

// Load this extension to register its fast-math kernel with PyTorch.
PYBIND11_MODULE(TORCH_EXTENSION_NAME, m) {}
