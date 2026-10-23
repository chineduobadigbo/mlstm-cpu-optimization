import time

import torch
from collections.abc import Callable

WARMUP = 10
REPS = 30


def time_fn_ms(
    fn: Callable[[], object],
    setup: Callable[[], object] | None = None,
    warmup: int = WARMUP,
    reps: int = REPS,
) -> list[float]:
    for _ in range(warmup):
        if setup is not None:
            setup()
        fn()
    times = []
    for _ in range(reps):
        if setup is not None:
            setup()
        t0 = time.perf_counter_ns()
        fn()
        t1 = time.perf_counter_ns()
        times.append((t1 - t0) * 1e-6)
    return times


def make_inputs(
    B: int,
    T: int,
    H: int,
    Dk: int,
    Dv: int,
    seed: int = 0,
) -> tuple[torch.Tensor, ...]:
    generator = torch.Generator(device="cpu")
    generator.manual_seed(seed)
    q = torch.randn(B, T, H, Dk, dtype=torch.float32, generator=generator)
    k = torch.randn(B, T, H, Dk, dtype=torch.float32, generator=generator)
    v = torch.randn(B, T, H, Dv, dtype=torch.float32, generator=generator)
    i = torch.randn(B, T, H, dtype=torch.float32, generator=generator)
    f = torch.randn(B, T, H, dtype=torch.float32, generator=generator)
    C = torch.zeros(B, H, Dv, Dk, dtype=torch.float32)
    n = torch.zeros(B, H, Dk, dtype=torch.float32)
    m = torch.zeros(B, H, dtype=torch.float32)
    return q, k, v, i, f, C, n, m
