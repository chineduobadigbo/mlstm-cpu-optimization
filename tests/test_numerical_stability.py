import torch

from mlstm_cpu.ops import KERNELS
from mlstm_cpu.reference import mlstm_core_sequence_reference

scalar_kernel = KERNELS["scalar_c_rm_reference"].fn


def test_extreme_gate_values_are_finite_and_match_reference():
    B, T, H, Dk, Dv = 1, 1, 1, 8, 4
    q = torch.randn(B, T, H, Dk)
    k = torch.randn(B, T, H, Dk)
    v = torch.randn(B, T, H, Dv)
    C = torch.zeros(B, H, Dv, Dk)
    n = torch.zeros(B, H, Dk)
    m = torch.zeros(B, H)

    for value in [-80.0, -20.0, 0.0, 20.0, 80.0]:
        i = torch.full((B, T, H), value)
        f = torch.full((B, T, H), -value)
        C_mut, n_mut, m_mut = C.clone(), n.clone(), m.clone()
        got = (scalar_kernel(q, k, v, i, f, C_mut, n_mut, m_mut), C_mut, n_mut, m_mut)
        ref = mlstm_core_sequence_reference(q, k, v, i, f, C, n, m)

        for got_t, ref_t in zip(got, ref):
            assert torch.isfinite(got_t).all()
            torch.testing.assert_close(got_t, ref_t, rtol=1e-5, atol=1e-5)
