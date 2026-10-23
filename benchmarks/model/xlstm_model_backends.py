"""Temporarily install xLSTM backends for benchmark calls."""

from collections.abc import Iterator
from contextlib import contextmanager

import torch
from torch import nn

from benchmarks.model.xlstm_model_constants import OFFICIAL_BACKEND
from mlstm_cpu.ops import KERNELS


class LocalKernelBackend(nn.Module):
    """Convert model inputs and state for a local BHTD kernel using C [B,H,Dk,Dv]."""

    def __init__(self, kernel: str, eps: float = 0.0) -> None:
        super().__init__()
        self.eps = eps
        spec = KERNELS[kernel]
        if spec.input_layout != "BHTD" or not spec.c_transposed:
            raise ValueError(f"{kernel} is not a BHTD kernel with transposed C state")
        self.kernel_spec = spec

    def forward(
        self,
        query: torch.Tensor,
        key: torch.Tensor,
        value: torch.Tensor,
        igate: torch.Tensor,
        fgate: torch.Tensor,
        c_initial: torch.Tensor | None = None,
        n_initial: torch.Tensor | None = None,
        m_initial: torch.Tensor | None = None,
        return_last_states: bool | None = None,
        mode: str | None = None,
    ) -> tuple[torch.Tensor, tuple[torch.Tensor, torch.Tensor, torch.Tensor]]:
        del return_last_states, mode
        hidden = self.kernel_spec.fn(
            *(tensor.contiguous() for tensor in (query, key, value, igate, fgate)),
            c_initial,
            n_initial,
            m_initial.squeeze(-1),
            eps=self.eps,
        )
        return hidden, (c_initial, n_initial, m_initial)


@contextmanager
def install_backend(model: nn.Module, backend: str, kernel: str) -> Iterator[nn.Module]:
    """Install a backend in every block and restore the originals on exit."""
    if backend == OFFICIAL_BACKEND:
        yield model
        return

    blocks = model.backbone.blocks
    original_backends = [block.mlstm_layer.mlstm_backend for block in blocks]
    try:
        for block in blocks:
            block.mlstm_layer.mlstm_backend = LocalKernelBackend(kernel, model.config.eps)
        yield model
    finally:
        for block, original in zip(blocks, original_backends, strict=True):
            block.mlstm_layer.mlstm_backend = original
