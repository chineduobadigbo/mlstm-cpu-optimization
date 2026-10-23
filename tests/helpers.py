"""Share test inputs and BHTD reference adapters."""
import torch

from mlstm_cpu.reference import mlstm_core_sequence_reference


def make_bhtd_case(B, H, T, Dk, Dv, seed=0):
    """Create BHTD projections and gates with small nonzero C_T [B,H,Dk,Dv], n, and m."""
    generator = torch.Generator(device="cpu")
    generator.manual_seed(seed)
    q = torch.randn(B, H, T, Dk, generator=generator)
    k = torch.randn(B, H, T, Dk, generator=generator)
    v = torch.randn(B, H, T, Dv, generator=generator)
    i = torch.randn(B, H, T, generator=generator)
    f = torch.randn(B, H, T, generator=generator)
    C_t = torch.randn(B, H, Dk, Dv, generator=generator) * 0.1
    n = torch.randn(B, H, Dk, generator=generator) * 0.1
    m = torch.randn(B, H, generator=generator) * 0.1
    return q, k, v, i, f, C_t, n, m


def reference_bhtd(q, k, v, i, f, C_t, n, m, eps=0.0):
    """Adapt BHTD inputs to the reference and return BHTD output with transposed C."""
    Y, C, n, m = mlstm_core_sequence_reference(
        *(t.transpose(1, 2) for t in (q, k, v, i, f)), C_t.transpose(-1, -2), n, m, eps=eps)
    return Y.transpose(1, 2), C.transpose(-1, -2), n, m


def run_on_copies(kernel, inputs, **kwargs):
    """Copy the input state, run the kernel, and return output plus updated C/n/m."""
    state = [t.clone() for t in inputs[5:]]
    return (kernel(*inputs[:5], *state, **kwargs), *state)
