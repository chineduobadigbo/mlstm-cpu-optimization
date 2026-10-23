"""Register operators and convert their tensor layouts.

Operators mutate C, n and m; native entries call registered PyTorch ops.
"""

from collections.abc import Callable
from dataclasses import dataclass
from typing import Literal

import torch

from . import _C, _C_fastmath  # Register native ops on import.

MlstmCoreFn = Callable[..., torch.Tensor]


@dataclass(frozen=True)
class KernelSpec:
    fn: MlstmCoreFn
    description: str
    c_transposed: bool = False
    input_layout: Literal["BTHD", "BHTD"] = "BTHD"

    def to_kernel_inputs(self, *tensors: torch.Tensor) -> tuple[torch.Tensor, ...]:
        """Convert BTHD projections and gates to contiguous tensors in the kernel layout."""
        if self.input_layout == "BHTD":
            tensors = tuple(t.transpose(1, 2) for t in tensors)
        return tuple(t.contiguous() for t in tensors)

    def to_kernel_state(self, C: torch.Tensor) -> torch.Tensor:
        """Convert C [B,H,Dv,Dk] to contiguous storage in the kernel layout."""
        return (C.transpose(-1, -2) if self.c_transposed else C).contiguous()

    def from_kernel_output(self, Y: torch.Tensor) -> torch.Tensor:
        """View kernel output in BTHD order without copying data."""
        return Y.transpose(1, 2) if self.input_layout == "BHTD" else Y

    def from_kernel_state(self, C: torch.Tensor) -> torch.Tensor:
        """View C as [B,H,Dv,Dk] without copying data."""
        return C.transpose(-1, -2) if self.c_transposed else C


KERNELS: dict[str, KernelSpec] = {
    "scalar_c_rm_reference": KernelSpec(
        torch.ops.mlstm_cpu.mlstm_core_sequence_scalar_c_rm_reference,
        "Scalar: row-major C++ baseline without automatic loop or SLP vectorization",
    ),
    "compiler_c_rm": KernelSpec(
        torch.ops.mlstm_cpu.mlstm_core_sequence_compiler_c_rm,
        "CompilerVec: the Scalar source with GCC vectorization",
    ),
    "compiler_fastmath_c_rm": KernelSpec(
        torch.ops.mlstm_cpu.mlstm_core_sequence_compiler_fastmath_c_rm,
        "CompilerVec fast-math: the Scalar source with GCC vectorization and -ffast-math",
    ),
    "avx2_c_rm_fused_r1": KernelSpec(
        torch.ops.mlstm_cpu.mlstm_core_sequence_avx2_c_rm_fused_r1,
        "Row1: AVX2 update of one row of C fused with its output dot product",
    ),
    "avx2_c_rm_rowsplit_r1": KernelSpec(
        torch.ops.mlstm_cpu.mlstm_core_sequence_avx2_c_rm_rowsplit_r1,
        "Row1 row-split: Row1 arithmetic, each row updated, then read back",
    ),
    "avx2_c_rm_twopass_r1": KernelSpec(
        torch.ops.mlstm_cpu.mlstm_core_sequence_avx2_c_rm_twopass_r1,
        "Row1 two-pass: Row1 arithmetic, the whole matrix updated, then read back",
    ),
    "avx2_c_rm_fused_r2": KernelSpec(
        torch.ops.mlstm_cpu.mlstm_core_sequence_avx2_c_rm_fused_r2,
        "Row2: fused AVX2 update and output dot over two rows of C",
    ),
    "avx2_c_rm_fused_r4": KernelSpec(
        torch.ops.mlstm_cpu.mlstm_core_sequence_avx2_c_rm_fused_r4,
        "Row4: fused AVX2 update and output dot over four rows of C",
    ),
    "avx2_c_rm_fused_r4_tb4": KernelSpec(
        torch.ops.mlstm_cpu.mlstm_core_sequence_avx2_c_rm_fused_r4_tb4,
        "Row-TBlock4: blocks of up to four tokens with one-row tiles; r4 is the four-row "
        "step that handles a single remaining token",
    ),
    "avx2_c_t_fused_r16_bhtd": KernelSpec(
        torch.ops.mlstm_cpu.mlstm_core_sequence_avx2_c_t_fused_r16_bhtd,
        "Col-TBlock2: column kernel on C [Dk,Dv] with two-token blocks from T>=2",
        c_transposed=True,
        input_layout="BHTD",
    ),
    "recurrent_avx2_panelwise_bhtd": KernelSpec(
        torch.ops.mlstm_cpu.mlstm_core_sequence_recurrent_avx2_panelwise_bhtd,
        "ColPanel: 16-column state panels carried through all tokens of a call",
        c_transposed=True,
        input_layout="BHTD",
    ),
    "chunkwise_avx2_bhtd": KernelSpec(
        torch.ops.mlstm_cpu.mlstm_core_sequence_chunkwise_avx2_bhtd,
        "Chunk4/Chunk8: AVX2 chunkwise kernel with at most eight tokens per chunk",
        c_transposed=True,
        input_layout="BHTD",
    ),
    "avx2_c_t_fused_r16_bhtd_unblocked": KernelSpec(
        torch.ops.mlstm_cpu.mlstm_core_sequence_avx2_c_t_fused_r16_bhtd_unblocked,
        "Col: column kernel on C [Dk,Dv] with one-token steps",
        c_transposed=True,
        input_layout="BHTD",
    ),
    "chunkwise_blas_bhtd": KernelSpec(
        torch.ops.mlstm_cpu.mlstm_core_sequence_chunkwise_blas_bhtd,
        "BLAS32: chunkwise kernel with SGEMM and 32-token chunks",
        c_transposed=True,
        input_layout="BHTD",
    ),
}
