import argparse
import json
import os
import platform
import statistics
import sys
from datetime import datetime, timezone
from pathlib import Path

import torch

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT))

from mlstm_cpu.ops import KERNELS
from mlstm_cpu.reference import mlstm_core_sequence_reference
from benchmarks.kernels import thesis_protocol as protocol
from benchmarks.kernels.benchmark_utils import REPS, WARMUP, make_inputs, time_fn_ms
from benchmarks.kernels.official_backend import official_spec
from benchmarks.kernels.thesis_validation import validate_shape
from benchmarks.model.xlstm_model_constants import execution_metadata
from benchmarks.model.xlstm_model_execution import timed_execution


def configure_runtime(threads: int, torch_threads: int | None = None) -> None:
    os.environ["MLSTM_THREADS"] = str(threads)
    torch.set_num_threads(threads if torch_threads is None else torch_threads)


def max_error(a: torch.Tensor, b: torch.Tensor) -> float:
    return torch.max(torch.abs(a - b)).item()


@torch.inference_mode()
def bench_shape(
    B: int,
    T: int,
    H: int,
    Dk: int,
    Dv: int,
    kernel_names: list[str],
    warmup: int,
    reps: int,
    threads: int = 1,
    seed: int = 0,
    carry_state: bool = False,
    eps: float = 0.0,
    fp_probe=None,
    diagnostic: bool = False,
) -> list[dict]:
    """Validate kernels against the reference, then time the same calls.

    Use formulation-specific bounds from protocol.tolerance. Diagnostic runs make one
    unchecked call per configuration; the timing process validates later. Run every call
    in inference mode.
    """
    q, k, v, i, f, C0, n0, m0 = make_inputs(B, T, H, Dk, Dv, seed=seed)

    first_expected = None if diagnostic else mlstm_core_sequence_reference(
        q, k, v, i, f, C0, n0, m0, eps=eps
    )

    records = []
    for name in kernel_names:
        kernel = protocol.configure(name)
        official = kernel == protocol.OFFICIAL
        execution_mode = name.partition(":")[2] if official else "eager"
        spec = official_spec(execution_mode, eps) if official else KERNELS[kernel]
        path = protocol.predicted_path(kernel, (B, T, H, Dk, Dv), threads)
        if fp_probe:
            # Resetting the OpenMP team also resets the caller, which is thread 0.
            protocol.fp_state(fp_probe, path["team_threads"], reset=True)
        q_kernel, k_kernel, v_kernel, i_kernel, f_kernel = spec.to_kernel_inputs(q, k, v, i, f)
        C0_kernel = spec.to_kernel_state(C0)
        if official:
            # Keep the official backend's returned state after each call; retain the
            # initial tensors for resets.
            initial = (C0_kernel, n0, m0.unsqueeze(-1))
            state = initial

            def reset_state():
                nonlocal state
                state = initial

            def run_kernel() -> torch.Tensor:
                nonlocal state
                Y, state = spec.fn(q_kernel, k_kernel, v_kernel, i_kernel, f_kernel, *state)
                return Y
        else:
            C = torch.empty_like(C0_kernel)
            n = torch.empty_like(n0)
            m = torch.empty_like(m0)
            state = (C, n, m)

            def reset_state():
                C.copy_(C0_kernel)
                n.copy_(n0)
                m.copy_(m0)

            def run_kernel() -> torch.Tensor:
                return spec.fn(
                    q_kernel, k_kernel, v_kernel, i_kernel, f_kernel, C, n, m, eps=eps
                )

        if diagnostic:
            reset_state()
            print(f"BEGIN {name}", flush=True)
            run_kernel()
            print(f"END {name}", flush=True)
            records.append({"kernel": kernel, "configuration": name, "correctness": "not_checked",
                "path": path, "fp_after": protocol.fp_state(fp_probe, path["team_threads"]) if fp_probe else None})
            continue

        errors = dict.fromkeys(("max_err_Y", "max_err_C", "max_err_n", "max_err_m"))
        tolerance = protocol.tolerance(kernel)
        checked_calls = warmup + reps if carry_state else 1
        expected = first_expected
        # Validate the first call and every subsequent call carrying state.
        reset_state()
        for step in range(checked_calls):
            if step:
                expected = mlstm_core_sequence_reference(q, k, v, i, f, *expected[1:], eps=eps)
            Y = run_kernel()
            values = (spec.from_kernel_output(Y), spec.from_kernel_state(state[0]), state[1],
                      state[2].view_as(m0))
            for tensor_name, actual, reference in zip(("Y", "C", "n", "m"), values, expected):
                error = max_error(actual, reference)
                key = f"max_err_{tensor_name}"
                errors[key] = error if step == 0 else max(errors[key], error)
                if (
                    not torch.isfinite(actual).all()
                    or not torch.isfinite(reference).all()
                    or not torch.allclose(actual, reference, **tolerance)
                ):
                    call = f"carried call={step}, " if carry_state else ""
                    raise ValueError(
                        f"validation failed before timing {name}: {tensor_name}, "
                        f"{call}shape={(B, T, H, Dk, Dv)}, atol={tolerance['atol']}, "
                        f"rtol={tolerance['rtol']}, max_abs_error={errors[key]}"
                    )
        reset_state()
        setup = None if carry_state else reset_state
        fp_before = protocol.fp_state(fp_probe, path["team_threads"], reset=True) if fp_probe else None
        with timed_execution(execution_mode):
            samples = time_fn_ms(run_kernel, setup=setup, warmup=warmup, reps=reps)
        fp_after = protocol.fp_state(fp_probe, path["team_threads"]) if fp_probe else None
        # Compiled official calls shrink OpenMP teams, causing libgomp to replace
        # surplus threads. As in model runs, fp_state checks the full team, affinity,
        # and FP flags after timing; thread IDs may change.
        if fp_before and not official and fp_after["tids"] != fp_before["tids"]:
            raise RuntimeError("OpenMP team changed during timing; discard this batch and inspect FP state")

        records.append({
            "kernel": kernel,
            "configuration": name,
            "input_layout": spec.input_layout,
            "state_layout": "B,H,Dk,Dv" if spec.c_transposed else "B,H,Dv,Dk",
            "configuration_environment": {key: value for key, value in os.environ.items()
                if key in protocol.KERNEL_SETTINGS
                or key.startswith(("OMP_", "MKL_", "OPENBLAS_"))},
            "path": path,
            "fp_before": fp_before,
            "fp_after": fp_after,
            "validated_calls": checked_calls,
            "execution": execution_metadata(execution_mode),
            "eps": eps,
            "description": spec.description,
            "B": B,
            "T": T,
            "H": H,
            "Dk": Dk,
            "Dv": Dv,
            "median_ms": statistics.median(samples),
            "samples_ms": samples,
            **errors,
            "correctness": "passed",
            **tolerance,
        })
    return records


def runtime_metadata(args: argparse.Namespace) -> dict:
    return {
        "timestamp_utc": datetime.now(timezone.utc).isoformat(),
        "arguments": sys.argv[1:],
        "python": sys.version.split()[0],
        "platform": platform.platform(),
        "torch_version": torch.__version__,
        "torch_num_threads": torch.get_num_threads(),
        "bench_threads": args.threads,
        "torch_threads": args.torch_threads,
        "seed": args.seed,
        "shape": args.shape,
        "warmup": args.warmup,
        "reps": args.reps,
        "carry_state": args.carry_state,
        "kernels": args.kernels,
        "eps": args.eps,
        "fp_policy": args.fp_policy,
        "affinity": sorted(os.sched_getaffinity(0)),
        "torch_config": torch.__config__.show(),
        "parallel_info": torch.__config__.parallel_info(),
        "loaded_thread_libraries": sorted({Path(line.split()[-1]).name for line in Path('/proc/self/maps').read_text().splitlines()
            if any(name in line for name in ('libgomp', 'libiomp', 'libmkl', 'libopenblas'))}),
        "env": {
            key: os.environ.get(key)
            for key in [
                "OMP_DYNAMIC",
                "MKL_DYNAMIC",
                "OMP_PROC_BIND",
                "OMP_PLACES",
            ] + [k for k in os.environ if k.startswith(("MKL_", "OPENBLAS_", "OMP_"))]
        },
    }


def save_json(payload: dict, path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")


def main() -> None:
    parser = argparse.ArgumentParser(description="Benchmark mLSTM memory-core kernels")
    parser.add_argument(
        "--shape",
        nargs=5,
        type=int,
        required=True,
        metavar=("B", "T", "H", "Dk", "Dv"),
        help="the B,T,H,Dk,Dv workload to benchmark",
    )
    parser.add_argument(
        "--kernels",
        nargs="+",
        required=True,
        help="kernel variants or thesis configurations to benchmark",
    )
    parser.add_argument("--warmup", type=int, default=WARMUP)
    parser.add_argument("--reps", type=int, default=REPS)
    parser.add_argument(
        "--carry-state",
        action="store_true",
        help="carry mutable state between timed calls instead of resetting each call",
    )
    parser.add_argument("--seed", type=int, default=0)
    parser.add_argument("--threads", type=int, default=1)
    parser.add_argument(
        "--torch-threads",
        type=int,
        default=None,
        help=(
            "override torch.set_num_threads while leaving "
            "MLSTM_THREADS controlled by --threads"
        ),
    )
    parser.add_argument(
        "--eps",
        type=float,
        default=0.0,
        help="denominator epsilon for all mLSTM backends and their reference (default: 0)",
    )
    parser.add_argument("--output", type=Path, default=None)
    parser.add_argument("--fp-probe", type=Path, help="untimed OpenMP FP probe built by the final campaign")
    parser.add_argument("--fp-policy", choices=protocol.FP_POLICIES, default="default",
                        help="default: FTZ/DAZ off (gradual underflow); ftz_daz: FTZ and DAZ on. "
                             "The FP probe applies it to every OpenMP thread and checks it")
    parser.add_argument("--diagnostic", action="store_true", help="untimed labeled calls for BLAS/thread verification")
    parser.add_argument("--validate-only", action="store_true", help="zero/nonzero state and two independent splits; no timings")
    args = parser.parse_args()
    if args.validate_only and args.diagnostic:
        parser.error("--validate-only and --diagnostic are separate operations")

    if args.threads <= 0:
        parser.error("--threads must be positive")
    if args.torch_threads is not None and args.torch_threads <= 0:
        parser.error("--torch-threads must be positive")
    if min(args.shape) <= 0:
        parser.error("--shape values must be positive")

    missing = [name for name in args.kernels if name not in KERNELS and name not in protocol.CONFIGURATIONS]
    if missing:
        parser.error(f"unknown kernel(s): {', '.join(missing)}. "
                     f"Available: {', '.join([*KERNELS, *protocol.CONFIGURATIONS])}")

    configure_runtime(args.threads, torch_threads=args.torch_threads)
    torch.set_num_interop_threads(1)
    torch.set_flush_denormal(args.fp_policy == "ftz_daz")
    fp_probe = protocol.load_fp_probe(args.fp_probe, args.fp_policy) if args.fp_probe else None
    shape = tuple(args.shape)

    print(
        f"threads={args.threads} torch_threads={torch.get_num_threads()} "
        f"warmup={args.warmup} reps={args.reps}"
    )

    if args.validate_only:
        records = validate_shape(shape, args.kernels, seed=args.seed,
            threads=args.threads, eps=args.eps, fp_probe=fp_probe)
        passed = all(row['correctness'] == 'passed' for row in records)
        payload = dict(metadata=runtime_metadata(args), status="passed" if passed else "failed", records=records)
        if args.output is not None:
            save_json(payload, args.output)
        print(f"validation {'passed' if passed else 'failed'}: {len(records)} configuration/state checks")
        raise SystemExit(0 if passed else 1)
    try:
        records = bench_shape(
            *shape, kernel_names=args.kernels,
            warmup=args.warmup, reps=args.reps, threads=args.threads, seed=args.seed,
            carry_state=args.carry_state, eps=args.eps,
            fp_probe=fp_probe, diagnostic=args.diagnostic,
        )
    except (ValueError, RuntimeError) as error:
        if args.output is not None:
            save_json({"metadata": runtime_metadata(args), "status": "failed",
                       "error": str(error), "records": []}, args.output)
        raise
    if not args.diagnostic:
        for record in records:
            print(f"{record['configuration']:<40} median={record['median_ms']:.4f} ms")

    payload = {
        "metadata": runtime_metadata(args),
        "records": records,
    }
    if args.output is not None:
        save_json(payload, args.output)


if __name__ == "__main__":
    main()
