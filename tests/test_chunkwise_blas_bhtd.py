"""Validate BLAS chunk output and dense state against recurrent results."""
import pytest
import torch

from helpers import reference_bhtd, run_on_copies
from mlstm_cpu.ops import KERNELS

kernel = KERNELS["chunkwise_blas_bhtd"].fn


@pytest.mark.parametrize("Dv,threads", [(3, 4), (35, 3), (512, 4)])
def test_blas_column_threads(monkeypatch, Dv, threads):
    torch.manual_seed(312)
    T, Dk = 65, 128
    q, k = (torch.randn(1, 1, T, Dk) for _ in range(2))
    v = torch.randn(1, 1, T, Dv)
    i, f = (torch.randn(1, 1, T) for _ in range(2))
    state = [torch.randn(1, 1, Dk, Dv) * .1,
             torch.randn(1, 1, Dk) * .1, torch.zeros(1, 1)]
    expected = reference_bhtd(q, k, v, i, f, *state)
    monkeypatch.setenv("MLSTM_THREADS", str(threads))
    for got, want in zip(run_on_copies(kernel, (q, k, v, i, f, *state)), expected, strict=True):
        torch.testing.assert_close(got, want, rtol=1e-4, atol=1e-4)
