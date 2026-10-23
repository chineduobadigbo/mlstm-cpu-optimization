import torch

from mlstm_cpu.reference import mlstm_core_sequence_reference


def test_reference_matches_hand_calculated_nonzero_state_trajectory():
    # Dk=1, zero gate logits, and initial m=0 yield stable gates i_hat=1 and f_hat=0.5.
    q = torch.tensor([1., 2.]).reshape(1, 2, 1, 1)
    k = torch.tensor([2., 1.]).reshape(1, 2, 1, 1)
    v = torch.tensor([[3., 4.], [5., 6.]]).reshape(1, 2, 1, 2)
    gates = torch.zeros(1, 2, 1)
    C = torch.tensor([1., 2.]).reshape(1, 1, 2, 1)
    n = torch.ones(1, 1, 1)
    m = torch.zeros(1, 1)
    Y, final_C, final_n, final_m = mlstm_core_sequence_reference(q, k, v, gates, gates, C, n, m)
    # After token 1: C=(6.5,9), n=2.5. After token 2: C=(8.25,10.5), n=2.25,
    # denominator=4.5.
    expected_Y = torch.tensor([[2.6, 3.6], [11./3., 14./3.]]).reshape(1, 2, 1, 2)
    torch.testing.assert_close(Y, expected_Y)
    torch.testing.assert_close(final_C, torch.tensor([8.25, 10.5]).reshape_as(C))
    torch.testing.assert_close(final_n, torch.full_like(n, 2.25))
    torch.testing.assert_close(final_m, m)
