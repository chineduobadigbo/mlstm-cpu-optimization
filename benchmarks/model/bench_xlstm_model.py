"""Compare official and local kernels on a saved xLSTM checkpoint in fresh processes.

Set each process's environment and CPU affinity before importing the model runtime.
Importing this entry point leaves the runtime unloaded.
"""

import argparse
import json
import os
import sys
from pathlib import Path
from typing import Sequence

ROOT = Path(__file__).resolve().parents[2]
if not __package__ and str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

from benchmarks.kernels.thesis_protocol import FP_POLICIES, configure
from benchmarks.model.xlstm_model_campaign import (
    RunConfiguration,
    _write_json,
    run_campaign,
    worker_environment,
)
from benchmarks.model.xlstm_model_constants import (
    BACKENDS,
    EXECUTION_MODES,
    DEFAULT_PAIR_COUNT,
    PROMPT_LENGTHS,
    SCOPES,
)


def _parse_affinity(value: str) -> tuple[int, ...]:
    return tuple(int(token) for token in value.split(","))


def _set_affinity(affinity: Sequence[int]) -> tuple[int, ...]:
    """Set and verify affinity for CPUs already checked by the campaign."""
    requested = tuple(affinity)
    os.sched_setaffinity(0, set(requested))
    applied = set(os.sched_getaffinity(0))
    if applied != set(requested):
        raise RuntimeError(
            "process affinity readback does not match requested CPUs: "
            f"requested={','.join(map(str, requested))} "
            f"applied={','.join(map(str, sorted(applied)))}"
        )
    return requested


def run_worker(args: argparse.Namespace) -> int:
    environment = worker_environment(dict(os.environ), args.threads, args.native_threads)
    for key in os.environ.keys() - environment.keys():
        del os.environ[key]
    os.environ.update(environment)
    os.environ["OMP_PLACES"] = ','.join('{'+str(cpu)+'}' for cpu in args.affinity)
    os.environ["MLSTM_BENCH_CPUS"] = ','.join(map(str, args.affinity))
    os.environ["MLSTM_FP_POLICY"] = args.fp_policy
    if args.diagnostic:
        # Set before the model runtime loads MKL.
        os.environ["MKL_VERBOSE"] = "1"
    kernel = configure(args.kernel)
    selected_affinity = _set_affinity(args.affinity)
    execution_modes = (args.official_execution_mode, args.local_execution_mode)
    from benchmarks.model.xlstm_model_measure import run_worker as measure_worker

    if args.diagnostic:
        from benchmarks.model.xlstm_model_measure import print_marked_cell_calls
        print_marked_cell_calls(args.checkpoint_dir, args.fixture_path, kernel, args.threads,
                                args.prefill_only)
        return 0
    if args.validate_only:
        import torch
        from benchmarks.model.xlstm_model_measure import fp_checkpoint
        from benchmarks.model.xlstm_model_campaign import run_validation
        torch.set_num_threads(args.threads)
        torch.set_num_interop_threads(1)
        before = fp_checkpoint(reset=True)
        record = run_validation(args.checkpoint_dir, args.fixture_path, kernel,
                                execution_modes, args.scopes, args.prefill_only)
        record.update(configuration=args.kernel, threads=args.threads,
                      affinity=list(selected_affinity), fp_before=before, fp_after=fp_checkpoint())
        _write_json(args.output, record)
        return 0 if record['status'] == 'passed' else 1

    record = measure_worker(
        checkpoint_dir=args.checkpoint_dir,
        fixture_path=args.fixture_path,
        backend=args.backend,
        scopes=tuple(args.scopes),
        kernel=kernel,
        threads=args.threads,
        pair_index=args.pair_index,
        selected_affinity=selected_affinity,
        execution_mode=execution_modes[BACKENDS.index(args.backend)],
        prefill_only=args.prefill_only,
        fp_policy=args.fp_policy,
        in_model_cells=args.in_model_cells,
    )
    record["identity"]["configuration"] = args.kernel
    record["numerical_acceptance"] = args.numerical_acceptance
    _write_json(args.output, record)
    print(json.dumps(record, sort_keys=True))
    return 0


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description=__doc__)
    commands = parser.add_subparsers(dest="command", required=True)

    run = commands.add_parser("run", help="Compare official with local_kernel in paired fresh processes.")
    run.add_argument("--checkpoint", type=Path, required=True)
    run.add_argument("--scopes", nargs="+", choices=SCOPES, default=SCOPES)
    run.add_argument("--kernel", required=True,
                     help="local kernel ID (a BHTD kernel with transposed C) or an operator "
                          "campaign configuration name from thesis_protocol.CONFIGURATIONS")
    run.add_argument("--pairs", type=int, default=DEFAULT_PAIR_COUNT)
    run.add_argument("--threads", nargs="+", choices=("1", "all"), default=("1", "all"))
    run.add_argument(
        "--physical-cpus",
        type=_parse_affinity,
        required=True,
        help="comma-separated CPU IDs, used in the given order: thread count 1 uses the first, "
             "thread count all uses all of them",
    )
    run.add_argument("--output", type=Path, required=True)

    worker = commands.add_parser("worker", help="Private measurement command.")
    worker.add_argument("--checkpoint-dir", type=Path, required=True)
    worker.add_argument("--fixture-path", type=Path, required=True)
    worker.add_argument("--backend", choices=BACKENDS, required=True)
    worker.add_argument("--scopes", nargs="+", choices=SCOPES, required=True)
    worker.add_argument("--kernel", required=True)
    worker.add_argument("--threads", type=int, required=True)
    worker.add_argument("--pair-index", type=int, required=True)
    worker.add_argument("--affinity", type=_parse_affinity, required=True)
    worker.add_argument("--output", type=Path, required=True)
    worker.add_argument("--validate-only", action="store_true")
    worker.add_argument("--diagnostic", action="store_true",
                        help="untimed local-kernel calls between BEGIN/END lines for MKL_VERBOSE")
    worker.add_argument("--numerical-acceptance", choices=("passed", "failed", "not_checked"), default="not_checked")
    for command in (run, worker):
        for backend in ("official", "local"):
            command.add_argument(f"--{backend}-execution-mode", choices=EXECUTION_MODES, default="eager",
                                 help=f"execution mode of the {backend} backend (default: eager)")
        command.add_argument(
            "--fp-policy", choices=FP_POLICIES, default="default",
            help="default: FTZ/DAZ off (gradual underflow); ftz_daz: FTZ and DAZ on. "
                 "Applies to both backends; set and checked on every OpenMP thread.",
        )
        command.add_argument(
            "--prefill-only", type=int, choices=PROMPT_LENGTHS,
            help="Validate and time only this prompt length, without decode (default: full campaign).",
        )
        command.add_argument(
            "--native-threads", type=int,
            help="Diagnostic: set only the local kernel's OpenMP threads (default: the thread count).",
        )
        command.add_argument(
            "--in-model-cells", action="store_true",
            help="After the full-model timings, run one untimed pass that times each block's "
                 "cell inside the model (eager execution only).",
        )
    return parser


def _run_configuration(args: argparse.Namespace) -> RunConfiguration:
    # The campaign checks available CPUs; validation checks that local kernels support
    # BHTD inputs and transposed C.
    physical_cpus = args.physical_cpus
    thread_counts = tuple(
        dict.fromkeys(1 if value == "1" else len(physical_cpus) for value in args.threads)
    )
    return RunConfiguration(
        checkpoint=args.checkpoint,
        scopes=tuple(args.scopes),
        kernel=args.kernel,
        pair_count=args.pairs,
        thread_counts=thread_counts,
        output_dir=args.output,
        physical_cpus=physical_cpus,
        execution_modes=(args.official_execution_mode, args.local_execution_mode),
        prefill_only=args.prefill_only,
        native_threads=args.native_threads,
        fp_policy=args.fp_policy,
        in_model_cells=args.in_model_cells,
    )


def main(argv: Sequence[str] | None = None) -> int:
    parser = build_parser()
    args = parser.parse_args(argv)
    if args.command == "run":
        return run_campaign(_run_configuration(args))
    try:
        return run_worker(args)
    except Exception as error:
        _write_json(args.output, {"status": "failed", "error": str(error)})
        raise


if __name__ == "__main__":
    raise SystemExit(main())
