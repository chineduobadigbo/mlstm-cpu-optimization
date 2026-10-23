import math

import torch
import torch.nn.functional as F


def _check_eps(eps: float) -> None:
    if not math.isfinite(eps) or eps < 0.0 or eps > torch.finfo(torch.float32).max:
        raise ValueError("eps must be finite, nonnegative and within float32 range")


def _check_sequence_shapes(
    q: torch.Tensor,
    k: torch.Tensor,
    v: torch.Tensor,
    i_tilde: torch.Tensor,
    f_tilde: torch.Tensor,
    C: torch.Tensor,
    n: torch.Tensor,
    m: torch.Tensor,
) -> tuple[int, int, int, int, int]:
    if q.dim() != 4 or k.dim() != 4 or v.dim() != 4:
        raise ValueError("sequence q, k and v must be rank-4 tensors")
    B, T, H, Dk = q.shape
    Dv = v.shape[3]
    expected = {
        "k": (B, T, H, Dk),
        "i_tilde": (B, T, H),
        "f_tilde": (B, T, H),
        "C": (B, H, Dv, Dk),
        "n": (B, H, Dk),
        "m": (B, H),
    }
    actual = {
        "k": tuple(k.shape),
        "i_tilde": tuple(i_tilde.shape),
        "f_tilde": tuple(f_tilde.shape),
        "C": tuple(C.shape),
        "n": tuple(n.shape),
        "m": tuple(m.shape),
    }
    for name, shape in expected.items():
        if actual[name] != shape:
            raise ValueError(f"{name} has shape {actual[name]}, expected {shape}")
    if B <= 0 or T <= 0 or H <= 0 or Dk <= 0 or Dv <= 0:
        raise ValueError("B, T, H, Dk and Dv must be positive")
    return B, T, H, Dk, Dv


def _step_reference(
    q: torch.Tensor,
    k: torch.Tensor,
    v: torch.Tensor,
    i_tilde: torch.Tensor,
    f_tilde: torch.Tensor,
    C: torch.Tensor,
    n: torch.Tensor,
    m: torch.Tensor,
    eps: float = 0.0,
) -> tuple[torch.Tensor, torch.Tensor, torch.Tensor, torch.Tensor]:
    """Evaluate a stabilized mLSTM step with PyTorch.

    Scale unscaled queries by 1/sqrt(Dk), matching native kernels. Return output and
    updated state while preserving inputs.
    """

    Dk = q.shape[-1]

    log_f = -F.softplus(-f_tilde)
    m_next = torch.maximum(log_f + m, i_tilde)
    f = torch.exp(log_f + m - m_next)
    i = torch.exp(i_tilde - m_next)

    C_next = (
        f[..., None, None] * C
        + (i[..., None, None] * v[..., :, None]) * k[..., None, :]
    )
    n_next = f[..., None] * n + i[..., None] * k

    q_scaled = q * (1.0 / math.sqrt(Dk))
    denom = (
        torch.maximum(
            torch.abs(torch.sum(n_next * q_scaled, dim=-1)),
            torch.exp(-m_next),
        )
        + eps
    )
    y_tilde = torch.sum(C_next * q_scaled[..., None, :], dim=-1) / denom[..., None]

    return y_tilde, C_next, n_next, m_next


def mlstm_core_sequence_reference(
    q: torch.Tensor,
    k: torch.Tensor,
    v: torch.Tensor,
    i_tilde: torch.Tensor,
    f_tilde: torch.Tensor,
    C: torch.Tensor,
    n: torch.Tensor,
    m: torch.Tensor,
    eps: float = 0.0,
) -> tuple[torch.Tensor, torch.Tensor, torch.Tensor, torch.Tensor]:
    """Compute all token outputs and final state without mutating the supplied state."""

    _check_eps(eps)
    _, T, _, _, _ = _check_sequence_shapes(q, k, v, i_tilde, f_tilde, C, n, m)
    C_next = C.clone()
    n_next = n.clone()
    m_next = m.clone()
    outputs = []
    for t in range(T):
        y_t, C_next, n_next, m_next = _step_reference(
            q[:, t],
            k[:, t],
            v[:, t],
            i_tilde[:, t],
            f_tilde[:, t],
            C_next,
            n_next,
            m_next,
            eps,
        )
        outputs.append(y_t)
    return torch.stack(outputs, dim=1), C_next, n_next, m_next
