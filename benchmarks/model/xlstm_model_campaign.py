"""Start isolated xLSTM benchmark processes with standard-library dependencies."""

import json
import os
import subprocess
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Sequence

from benchmarks.kernels.thesis_protocol import KERNEL_SETTINGS
from benchmarks.model.xlstm_model_constants import (
    BACKENDS, LOCAL_KERNEL_BACKEND, SCOPES, pair_execution,
)


ROOT = Path(__file__).resolve().parents[2]
WORKER_ENVIRONMENT = {
    "OMP_DYNAMIC": "FALSE",
    "MKL_DYNAMIC": "FALSE",
    "OMP_PROC_BIND": "close",
    "OMP_MAX_ACTIVE_LEVELS": "1",
}


@dataclass(frozen=True)
class RunConfiguration:
    checkpoint: Path
    scopes: tuple[str, ...]
    kernel: str
    pair_count: int
    thread_counts: tuple[int, ...]
    output_dir: Path
    physical_cpus: tuple[int, ...]
    # Execution modes follow BACKENDS: official, then local.
    execution_modes: tuple[str, str] = ("eager", "eager")
    prefill_only: int | None = None
    native_threads: int | None = None
    fp_policy: str = "default"
    in_model_cells: bool = False


def worker_environment(
    base_environment: dict[str, str], threads: int, native_threads: int | None = None
) -> dict[str, str]:
    """Configure thread pools, optionally overriding the native kernel's thread count."""
    environment = {key: value for key, value in base_environment.items()
                   if key not in KERNEL_SETTINGS
                   and not key.startswith(("OMP_", "MKL_", "OPENBLAS_", "KMP_", "GOMP_"))}
    environment.update(
        {
            "OMP_NUM_THREADS": str(threads),
            "MKL_NUM_THREADS": str(threads),
            "OPENBLAS_NUM_THREADS": str(threads),
            "MLSTM_THREADS": str(native_threads or threads),
            **WORKER_ENVIRONMENT,
        }
    )
    return environment


def allowed_logical_cpus() -> tuple[int, ...]:
    return tuple(sorted(os.sched_getaffinity(0)))


def affinity_for_threads(selected: Sequence[int], threads: int) -> tuple[int, ...]:
    if threads == 1:
        return (selected[0],)
    if threads == len(selected):
        return tuple(selected)
    raise ValueError("thread count must be 1 or all selected physical CPUs")


def backends_for_pair(pair_index: int) -> tuple[str, str]:
    """Alternate process order between pairs without swapping baseline and candidate roles."""
    return BACKENDS if pair_index % 2 == 0 else BACKENDS[::-1]


def raw_worker_filename(pair_index: int, backend: str, threads: int) -> str:
    return f"pair-{pair_index:02d}-{backend}-{threads}.json"


def worker_command(
    *,
    config: RunConfiguration,
    fixture_path: Path,
    backend: str,
    threads: int,
    pair_index: int,
    affinity: Sequence[int],
    output_path: Path,
) -> list[str]:
    command = [
        sys.executable,
        "-m",
        "benchmarks.model.bench_xlstm_model",
        "worker",
        "--checkpoint-dir",
        str(config.checkpoint.resolve()),
        "--fixture-path",
        str(fixture_path),
        "--scopes",
        *config.scopes,
        "--kernel",
        config.kernel,
    ]
    if config.prefill_only is not None:
        command.extend(("--prefill-only", str(config.prefill_only)))
    if config.native_threads is not None:
        command.extend(("--native-threads", str(config.native_threads)))
    if config.in_model_cells:
        command.append("--in-model-cells")
    command.extend(
        (
            "--official-execution-mode",
            config.execution_modes[0],
            "--local-execution-mode",
            config.execution_modes[1],
            "--fp-policy",
            config.fp_policy,
            "--backend",
            backend,
            "--threads",
            str(threads),
            "--pair-index",
            str(pair_index),
            "--affinity",
            ",".join(str(cpu) for cpu in affinity),
            "--output",
            str(output_path),
        )
    )
    return command


def _write_json(path: Path, payload: dict[str, object]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(payload, indent=2, sort_keys=True) + "\n", encoding="utf-8")


def run_validation(
    checkpoint: Path, fixture_path: Path, kernel: str,
    execution_modes: Sequence[str] = ("eager", "eager"), scopes: Sequence[str] = SCOPES,
    prefill_only: int | None = None,
) -> dict[str, object]:
    """Return validation results, retaining completed checks that fail tolerances."""
    from benchmarks.model.xlstm_model_validate import validate_model

    try:
        return validate_model(checkpoint, fixture_path, kernel, execution_modes, scopes, prefill_only)
    except Exception as error:
        return {
            "status": "failed", "backends": list(BACKENDS),
            "execution": pair_execution(execution_modes), "error": str(error),
            "failure_kind": "execution",
            "validation_complete": False,
            "prefill_only": prefill_only,
        }


def run_worker_process(
    command: Sequence[str], environment: dict[str, str], raw_path: Path
) -> dict[str, object]:
    subprocess.run(command, cwd=ROOT, env=environment, check=True)
    return json.loads(raw_path.read_text(encoding="utf-8"))


def write_results(
    validation: dict[str, object],
    records: list[dict[str, object]],
    config: RunConfiguration,
    output_dir: Path,
) -> None:
    from benchmarks.model.xlstm_model_report import merge_results

    results = merge_results(
        validation,
        records,
        checkpoint=config.checkpoint.resolve().name,
        scopes=config.scopes,
        kernel=config.kernel,
        pair_count=config.pair_count,
        thread_counts=config.thread_counts,
        execution_modes=config.execution_modes,
        fp_policy=config.fp_policy,
        prefill_only=config.prefill_only,
    )
    if config.native_threads is not None:
        results["run"]["native_threads"] = config.native_threads
    results["run"]["in_model_cells"] = config.in_model_cells
    _write_json(output_dir / "results.json", results)


def record_mkl_threads(
    config: RunConfiguration, fixture_path: Path, base_environment: dict[str, str],
    output_dir: Path,
) -> dict[str, dict[str, object]]:
    """Run one untimed MKL_VERBOSE=1 process per thread count.

    Return NThr values from local cell calls. MKL may use multiple threads when the
    native thread count is below the total allocation.
    """
    from benchmarks.kernels import thesis_protocol as protocol

    observed = {}
    for threads in config.thread_counts:
        command = worker_command(
            config=config,
            fixture_path=fixture_path,
            backend=LOCAL_KERNEL_BACKEND,
            threads=threads,
            pair_index=0,
            affinity=affinity_for_threads(config.physical_cpus, threads),
            output_path=output_dir / f"mkl-{threads}.json",
        )
        process = subprocess.run(
            [*command, "--diagnostic"],
            cwd=ROOT,
            env=base_environment,
            capture_output=True,
            text=True,
        )
        log = f"mkl-{threads}.log"
        (output_dir / log).write_text(process.stdout + process.stderr)
        observed[str(threads)] = {
            "log": log,
            "returncode": process.returncode,
            "nthr": protocol.marked_mkl_threads(process.stdout, LOCAL_KERNEL_BACKEND),
        }
    return observed


def run_campaign(config: RunConfiguration) -> int:
    from benchmarks.kernels import thesis_protocol as protocol

    fixture_path = ROOT / "benchmarks" / "fixtures" / "xlstm_prompts.json"
    physical_cpus = config.physical_cpus
    unavailable = set(physical_cpus) - set(allowed_logical_cpus())
    if unavailable:
        raise ValueError(
            "physical CPU selection includes CPUs outside the process affinity mask: "
            + ",".join(map(str, sorted(unavailable)))
        )
    output_dir = config.output_dir.resolve()
    output_dir.mkdir(parents=True, exist_ok=False)
    raw_dir = output_dir / "raw"
    raw_dir.mkdir()

    base_environment = dict(os.environ)
    probe = output_dir / "fp_probe.so"
    probe_build = protocol.build_fp_probe(probe)
    base_environment["MLSTM_FP_PROBE"] = str(probe)
    validations = []
    for threads in config.thread_counts:
        affinity = affinity_for_threads(physical_cpus, threads)
        path = output_dir / f"validation-{threads}.json"
        command = worker_command(
            config=config,
            fixture_path=fixture_path,
            backend=BACKENDS[0],
            threads=threads,
            pair_index=0,
            affinity=affinity,
            output_path=path,
        )
        process = subprocess.run(
            [*command, "--validate-only"],
            cwd=ROOT,
            env=base_environment,
            capture_output=True,
            text=True,
        )
        path.with_suffix(".log").write_text(process.stdout + process.stderr)
        if path.exists():
            validations.append(json.loads(path.read_text()))
        else:
            validations.append(
                {"status": "failed", "error": "validation process failed; see log"}
            )
    # Record BLAS cell thread counts without imposing an expected value.
    mkl_threads = (record_mkl_threads(config, fixture_path, base_environment, output_dir)
                   if protocol.base_kernel(config.kernel) == protocol.BLAS else None)
    all_passed = all(check.get("status") == "passed" for check in validations)
    validation = {
        "status": "passed" if all_passed else "failed",
        "execution": pair_execution(config.execution_modes),
        "fp_policy": config.fp_policy,
        "backends": list(BACKENDS),
        "thread_checks": validations,
        "fp_probe": probe_build,
        "checkpoint": config.checkpoint.resolve().name,
        "prefill_only": config.prefill_only,
        "topology": protocol.cpu_topology(physical_cpus),
        **({"mkl_threads": mkl_threads} if mkl_threads else {}),
    }
    if not all_passed:
        validation["failure_kind"] = (
            "numerical" if all(check.get("status") == "passed" or
                               check.get("failure_kind") == "numerical"
                               for check in validations) else "execution"
        )
    # Retain timings with failed numerical acceptance; abort only on execution failure.
    validation["timing_permitted"] = validation.get("failure_kind") != "execution"
    _write_json(output_dir / "validation.json", validation)
    if not validation["timing_permitted"]:
        return 1
    records: list[dict[str, object]] = []
    for threads in config.thread_counts:
        affinity = affinity_for_threads(physical_cpus, threads)
        for pair_index in range(config.pair_count):
            for backend in backends_for_pair(pair_index):
                raw_path = raw_dir / raw_worker_filename(pair_index, backend, threads)
                command = worker_command(
                    config=config,
                    fixture_path=fixture_path,
                    backend=backend,
                    threads=threads,
                    pair_index=pair_index,
                    affinity=affinity,
                    output_path=raw_path,
                )
                command.extend(("--numerical-acceptance", validation["status"]))
                records.append(run_worker_process(command, base_environment, raw_path))
    write_results(validation, records, config, output_dir)
    return 0
