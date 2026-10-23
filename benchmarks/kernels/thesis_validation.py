"""Check full sequences and continued state outside campaign timing."""
import torch

from mlstm_cpu.ops import KERNELS
from mlstm_cpu.reference import mlstm_core_sequence_reference as reference
from benchmarks.kernels import thesis_protocol as protocol
from benchmarks.kernels.benchmark_utils import make_inputs
from benchmarks.kernels.official_backend import official_spec


def errors(actual, expected, atol, rtol):
    details = {}
    for name, got, want in zip(("Y", "C", "n", "m"), actual, expected, strict=True):
        delta = (got.double() - want.double()).abs()
        bound = atol + rtol * want.double().abs()
        failed = (delta > bound) | ~torch.isfinite(delta)
        details[name] = dict(
            finite=bool(torch.isfinite(got).all() and torch.isfinite(want).all()),
            max_abs=float(delta.max()),
            mismatches=int((delta > bound).sum()),
            max_tolerance_ratio=float((delta / bound).max()),
            first_failure_coordinates=torch.nonzero(failed)[:8].tolist(),
        )
    passed = all(d["finite"] and d["mismatches"] == 0 for d in details.values())
    return dict(passed=passed, tensors=details)


@torch.inference_mode()
def validate_shape(shape, names, *, seed, threads, eps=0., fp_probe=None):
    t = shape[1]
    *inputs, c, n, m = make_inputs(*shape, seed=seed)
    generator = torch.Generator().manual_seed(seed + 10000)
    state = [torch.randn(x.shape, generator=generator) * .1 for x in (c, n, m)]
    records = []
    for nonzero in (False, True):
        initial = state if nonzero else [torch.zeros_like(x) for x in state]
        expected = reference(*inputs, *initial, eps=eps)
        for name in names:
            kernel = protocol.configure(name)
            official = kernel == protocol.OFFICIAL
            spec = official_spec(name.partition(":")[2], eps) if official else KERNELS[kernel]
            tolerance = protocol.tolerance(kernel)
            path = protocol.predicted_path(kernel, shape, threads)
            before = (protocol.fp_state(fp_probe, path["team_threads"], reset=True)
                      if fp_probe else None)
            checks = []
            for cut in [None, *sorted({t // 3, t - 1} - {0})]:
                current = [x.clone() for x in initial]
                current[0] = spec.to_kernel_state(current[0])
                if official:
                    current[2] = current[2].unsqueeze(-1)
                outputs = []
                for start, end in ([(0, t)] if cut is None else [(0, cut), (cut, t)]):
                    chunk = spec.to_kernel_inputs(*(x[:, start:end] for x in inputs))
                    if official:
                        # Reuse the official backend's returned state on the next call.
                        y, current = spec.fn(*chunk, *current)
                    else:
                        y = spec.fn(*chunk, *current, eps=eps)
                    outputs.append(spec.from_kernel_output(y))
                actual = (torch.cat(outputs, dim=1), spec.from_kernel_state(current[0]),
                          current[1], current[2].view_as(initial[2]))
                checks.append(dict(split=cut, fp32=errors(actual, expected, **tolerance)))
            passed = all(check["fp32"]["passed"] for check in checks)
            after = protocol.fp_state(fp_probe, path["team_threads"]) if fp_probe else None
            records.append(dict(
                kernel=kernel, configuration=name, shape=shape, threads=threads, seed=seed,
                nonzero_state=nonzero, generator="make_inputs; nonzero seed+10000",
                correctness="passed" if passed else "failed", **tolerance, eps=eps,
                path=path, fp_before=before, fp_after=after, checks=checks,
            ))
    return records
