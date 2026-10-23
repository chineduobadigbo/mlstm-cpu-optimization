import pytest
import torch

from helpers import make_bhtd_case, reference_bhtd, run_on_copies
from mlstm_cpu.ops import KERNELS

R16 = KERNELS["avx2_c_t_fused_r16_bhtd"].fn
CHUNKWISE = KERNELS["chunkwise_avx2_bhtd"].fn


def assert_matches_reference(kernel, inputs, **tolerance):
    for got, want in zip(run_on_copies(kernel, inputs), reference_bhtd(*inputs), strict=True):
        torch.testing.assert_close(got, want, **tolerance)


@pytest.mark.parametrize("T", [1, 3, 65])
def test_col_tblock2_split_state_odd_lengths_match_reference(monkeypatch, T):
    # After token pairs, split-state execution handles the final odd token separately.
    monkeypatch.setenv("MLSTM_SPLIT", "1")
    monkeypatch.setenv("MLSTM_THREADS", "4")
    inputs = make_bhtd_case(1, 2, T, 33, 64, seed=1200 + T)
    expected = reference_bhtd(*inputs)
    for boundaries in ((0, T), tuple(sorted({0, T // 2, T}))):
        state = [t.clone() for t in inputs[5:]]
        outputs = [R16(*(t[:, :, a:b].contiguous() for t in inputs[:5]), *state)
                   for a, b in zip(boundaries, boundaries[1:])]
        for got, want in zip((torch.cat(outputs, dim=2), *state), expected, strict=True):
            torch.testing.assert_close(got, want, rtol=1e-4, atol=1e-4)


@pytest.mark.parametrize("threads", [3, 6])
def test_chunkwise_split_state_uneven_columns_match_reference(monkeypatch, threads):
    # Dv=100 spans seven column units, leaving uneven shares for three or six threads.
    monkeypatch.setenv("MLSTM_SPLIT", "1")
    monkeypatch.setenv("MLSTM_THREADS", str(threads))
    inputs = make_bhtd_case(1, 1, 19, 33, 100, seed=1300 + threads)
    assert_matches_reference(CHUNKWISE, inputs, rtol=1e-4, atol=1e-4)
