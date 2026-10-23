import pytest
import torch

from mlstm_cpu.reference import mlstm_core_sequence_reference
from mlstm_cpu.ops import KERNELS


@pytest.mark.parametrize("kernel_name", KERNELS.keys())
def test_sequence_kernel_matches_reference_and_preserves_inputs(kernel_name):
    torch.manual_seed(3)
    B, T, H, Dk, Dv = 2, 5, 3, 9, 7
    q = torch.randn(B, T, H, Dk)
    k = torch.randn(B, T, H, Dk)
    v = torch.randn(B, T, H, Dv)
    i = torch.randn(B, T, H)
    f = torch.randn(B, T, H)
    state = (torch.randn(B, H, Dv, Dk) * 0.1, torch.randn(B, H, Dk) * 0.1, torch.randn(B, H) * 0.1)
    C, n, m = state
    expected = mlstm_core_sequence_reference(q, k, v, i, f, C, n, m)

    spec = KERNELS[kernel_name]
    inputs = spec.to_kernel_inputs(q, k, v, i, f)
    snapshots = [t.clone() for t in inputs]
    C_kernel, n_kernel, m_kernel = spec.to_kernel_state(C.clone()), n.clone(), m.clone()
    Y = spec.fn(*inputs, C_kernel, n_kernel, m_kernel)

    actual = (spec.from_kernel_output(Y), spec.from_kernel_state(C_kernel), n_kernel, m_kernel)
    for got, want in zip(actual, expected, strict=True):
        torch.testing.assert_close(got, want, rtol=1e-5, atol=1e-5)
    for got, want in zip(inputs, snapshots, strict=True):
        torch.testing.assert_close(got, want)


@pytest.mark.parametrize("kernel_name", KERNELS.keys())
def test_sequence_kernel_prefill_then_decode_carries_state(kernel_name, monkeypatch):
    monkeypatch.setenv("MLSTM_THREADS", "2")
    generator = torch.Generator().manual_seed(23)
    B, H, Dk, Dv = 2, 3, 17, 19  # Odd widths exercise SIMD tails in both state layouts.
    prefill, decode = 17, 32
    T = prefill + decode
    inputs = tuple(
        torch.randn(*shape, generator=generator)
        for shape in (
            (B, T, H, Dk), (B, T, H, Dk), (B, T, H, Dv),
            (B, T, H), (B, T, H),
        )
    )
    reference_state = tuple(
        torch.randn(*shape, generator=generator) * 0.1
        for shape in ((B, H, Dv, Dk), (B, H, Dk), (B, H))
    )
    spec = KERNELS[kernel_name]
    C, n, m = (tensor.clone() for tensor in reference_state)
    C = spec.to_kernel_state(C)

    # Keep the same state buffers for prefill and every decode step.
    boundaries = [0, *range(prefill, T + 1)]
    for start, end in zip(boundaries, boundaries[1:]):
        step_inputs = tuple(tensor[:, start:end].contiguous() for tensor in inputs)
        Y_ref, *reference_state = mlstm_core_sequence_reference(
            *step_inputs, *reference_state
        )
        Y = spec.fn(*spec.to_kernel_inputs(*step_inputs), C, n, m)

        for name, actual, expected in zip(
            ("Y", "C", "n", "m"),
            (spec.from_kernel_output(Y), spec.from_kernel_state(C), n, m),
            (Y_ref, *reference_state),
            strict=True,
        ):
            context = f"{kernel_name}, tokens [{start}:{end}], {name}"
            assert torch.isfinite(actual).all(), context
            torch.testing.assert_close(
                actual, expected, rtol=1e-5, atol=1e-5,
                msg=lambda message: f"{context}\n{message}",
            )
