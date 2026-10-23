"""Verify epsilon changes only readout."""

import pytest
import torch

from benchmarks.kernels.benchmark_utils import make_inputs
from mlstm_cpu.ops import KERNELS
from mlstm_cpu.reference import mlstm_core_sequence_reference


def _run(spec, inputs, **kwargs):
    """Clone state, adapt BTHD inputs to the kernel, and restore output layouts."""
    C, n, m = (t.clone() for t in inputs[5:])
    C = spec.to_kernel_state(C)
    Y = spec.fn(*spec.to_kernel_inputs(*inputs[:5]), C, n, m, **kwargs)
    return spec.from_kernel_output(Y), spec.from_kernel_state(C), n, m


@pytest.mark.parametrize("kernel", KERNELS)
@pytest.mark.parametrize("eps", [1e-6])
@pytest.mark.parametrize("T,Dk,Dv,threads", [(8, 257, 256, 4)])
def test_epsilon_matches_reference_and_changes_only_readout(monkeypatch, kernel, eps, T, Dk, Dv, threads):
    monkeypatch.setenv("MLSTM_THREADS", str(threads))
    monkeypatch.setenv("MLSTM_CHUNK", "4")
    inputs = make_inputs(1, T, 1, Dk, Dv, seed=31)
    for state in inputs[5:]:
        state.fill_(0.1)
    spec = KERNELS[kernel]
    expected = mlstm_core_sequence_reference(*inputs, eps=eps)
    actual = _run(spec, inputs, eps=eps)
    zero = _run(spec, inputs)
    for got, want in zip(actual, expected):
        torch.testing.assert_close(got, want, atol=1e-4, rtol=1e-4)
    for got, want in zip(actual[1:], zero[1:]):
        torch.testing.assert_close(got, want, atol=0, rtol=0)
    assert not torch.equal(actual[0], zero[0])
    # Follow prefill with two single-token calls to exercise decode fallbacks.
    state = inputs[5:]
    outputs = []
    for start, end in ((0, T - 2), (T - 2, T - 1), (T - 1, T)):
        chunk = tuple(t[:, start:end].contiguous() for t in inputs[:5])
        Y, *state = _run(spec, (*chunk, *state), eps=eps)
        outputs.append(Y)
    for got, want in zip((torch.cat(outputs, dim=1), *state), expected):
        torch.testing.assert_close(got, want, atol=1e-4, rtol=1e-4)
