"""Run paired operator timings or correctness checks for the fixed campaign."""

import argparse
from dataclasses import dataclass, replace
from datetime import datetime, timezone
import json
import os
from pathlib import Path
import platform
import random
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[2]
if __package__ in (None, ""):
    sys.path.insert(0, str(ROOT))
from benchmarks.kernels import thesis_protocol as protocol

WORKER = ROOT / "benchmarks/kernels/bench_mlstm_core.py"

# Share seeds and sample counts across runs; use one PyTorch thread for native kernels.
CAMPAIGN = "final"
SEED = 0
WARMUP = 10
REPS = 30
TORCH_THREADS = 1

# Thesis geometries G1-G9 as (Dk, Dv).
G1 = (64, 64)
G2 = (64, 128)  # 164M model dimensions.
G3 = (128, 128)
G4 = (128, 256)
G5 = (192, 384)  # 841M model dimensions.
G6 = (256, 256)
G7 = (256, 512)  # 1.42B model dimensions.
G8 = (512, 512)  # 1 MiB matrix state in FP32.
G9 = (512, 1024)
GEOMETRIES = (G1, G2, G3, G4, G5, G6, G7, G8, G9)

# Time eager and compiled baselines in separate processes.
OFFICIAL_KERNELS = (f"{protocol.OFFICIAL}:eager", f"{protocol.OFFICIAL}:compiled")
# Use Chunk4 for decode: Chunk4 and Chunk8 both process one token at T=1.
DECODE_KERNELS = (
    protocol.COL_TBLOCK2,
    protocol.COL_PANEL,
    protocol.CHUNK4,
    protocol.BLAS32,
)
PREFILL_KERNELS = (
    protocol.COL_TBLOCK2,
    protocol.COL_PANEL,
    protocol.CHUNK4,
    protocol.CHUNK8,
    protocol.BLAS32,
)
# Include split-state variants in S where the workload permits splitting.
SPLIT_KERNELS = (protocol.COL_TBLOCK2, protocol.CHUNK4, protocol.CHUNK8)
# A compares optimization stages, fast-math and Row1 fusion controls.
# Native variants share processes; official runs supply absolute latencies.
FINAL_ABLATION_KERNELS = (
    protocol.SCALAR,
    protocol.COMPILER_VEC,
    protocol.COMPILER_VEC_FASTMATH,
    protocol.ROW1,
    protocol.ROW1_ROWSPLIT,
    protocol.ROW1_TWOPASS,
    protocol.ROW2,
    protocol.ROW4,
    protocol.ROW_TBLOCK4,
    *OFFICIAL_KERNELS,
)
# L adds transposed storage, key blocking, then two-token reuse.
LAYOUT_KERNELS = (protocol.ROW1, protocol.COL_FULL, protocol.COL, protocol.COL_TBLOCK2)
# KB compares key-block sizes with the eight-key default.
KEY_BLOCK_KERNELS = tuple(
    f"{label}{suffix}"
    for label in (protocol.COL_TBLOCK2, protocol.CHUNK4)
    for suffix in ("", ":kb4", ":kb16", ":kb32", ":nokb")
)

# S repeats each (batch, heads, geometry) workload across thread counts.
SCALING_WORKLOADS = (
    (1, 1, G7),
    (1, 4, G7),
    (1, 16, G7),
    (1, 4, G5),
)
# S includes 1.42B prefill at 1024 tokens and the maximum thread count.
LONG_PREFILL_SHAPE = (1, 1024, 4, *G7)


@dataclass(frozen=True)
class FinalPoint:
    shape: tuple[int, int, int, int, int]
    threads: int
    kernels: tuple[str, ...]
    comparison_roles: tuple
    fp_policy: str = "default"

    @property
    def carry_state(self):
        # Preserve state across decode calls; reset it for each prefill.
        return self.shape[1] == 1

    @property
    def official(self):
        # Run official backends separately with the requested PyTorch, OpenMP and MKL
        # thread counts.
        return self.kernels[0].startswith(protocol.OFFICIAL)


def shape_label(shape):
    B, T, H, Dk, Dv = shape
    return f"B{B}_T{T}_H{H}_Dk{Dk}_Dv{Dv}"


def read_json(path):
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError):
        return None


def write_json(payload, path):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")


def split_variants(kernels, shape, threads):
    """Return split-state variant names for kernels that can split this workload."""
    return tuple(
        f"{label}:split"
        for label in kernels
        if label in SPLIT_KERNELS
        and protocol.split_threads(protocol.base_kernel(label), shape, threads)
    )


def final_workloads(threads):
    """List workloads as (comparison, B/T/H/Dk/Dv, thread counts, kernels, FP policy).

    Covers A/L/D/P/S/KB/F; final_points merges duplicate measurements. Preserve this
    order because it sets the repeat schedule.
    """
    workloads = []

    def add(
        comparison,
        *,
        geometry,
        lengths,
        thread_counts,
        kernels,
        batch=1,
        heads=1,
        fp_policy="default",
    ):
        for length in lengths:
            shape = (batch, length, heads, *geometry)
            workloads.append((comparison, shape, thread_counts, kernels, fp_policy))

    # Alternate A and L comparisons within each geometry.
    for geometry in (G2, G5, G7, G9):
        add(
            "A",
            geometry=geometry,
            lengths=(1, 256),
            thread_counts=(1,),
            kernels=FINAL_ABLATION_KERNELS,
        )
        add(
            "L",
            geometry=geometry,
            lengths=(1, 256),
            thread_counts=(1,),
            kernels=LAYOUT_KERNELS,
        )

    # D measures single-token decode across all state shapes.
    for geometry in GEOMETRIES:
        add(
            "D",
            geometry=geometry,
            lengths=(1,),
            thread_counts=(1,),
            kernels=(*DECODE_KERNELS, *OFFICIAL_KERNELS),
        )

    # P varies state size and prompt length. Skip official runs at T=4096 to limit
    # runtime.
    for geometry in (G2, G4, G5, G7, G8, G9):
        for length in (16, 64, 256, 1024, 4096):
            official = OFFICIAL_KERNELS if length <= 1024 else ()
            add(
                "P",
                geometry=geometry,
                lengths=(length,),
                thread_counts=(1,),
                kernels=(*PREFILL_KERNELS, *official),
            )

    # S varies decode and prefill thread counts, adding supported split-state variants.
    # Include official runs for 841M and for 1.42B prefill at the maximum thread count.
    def add_scaling(shape, thread_count, kernels, official):
        workloads.append(
            (
                "S",
                shape,
                (thread_count,),
                (
                    *kernels,
                    *split_variants(kernels, shape, thread_count),
                    *(OFFICIAL_KERNELS if official else ()),
                ),
                "default",
            )
        )

    for batch, heads, geometry in SCALING_WORKLOADS:
        for length, kernels in ((1, DECODE_KERNELS), (256, PREFILL_KERNELS)):
            for thread_count in threads:
                official = (batch, heads, geometry) == (1, 4, G5)
                add_scaling(
                    (batch, length, heads, *geometry), thread_count, kernels, official
                )
    add_scaling(LONG_PREFILL_SHAPE, max(threads), PREFILL_KERNELS, True)

    # KB measures key-block sizes using one core.
    for geometry in (G2, G5, G7, G9):
        add(
            "KB",
            geometry=geometry,
            lengths=(1, 256),
            thread_counts=(1,),
            kernels=KEY_BLOCK_KERNELS,
        )

    # F measures official FTZ/DAZ sensitivity on one core, sharing repeat blocks with
    # default-policy D and P runs.
    for geometry in (G2, G5, G9):
        add(
            "F",
            geometry=geometry,
            lengths=(1, 16, 256, 1024),
            thread_counts=(1,),
            kernels=OFFICIAL_KERNELS,
            fp_policy="ftz_daz",
        )

    return workloads


def final_points(threads):
    """Expand thread counts and merge measurements shared by comparisons.

    Keep official backends and FP policies separate, even at matching shapes and thread
    counts.
    """
    groups = {}
    for comparison, shape, thread_counts, kernels, fp_policy in final_workloads(threads):
        for thread_count in thread_counts:
            for label in kernels:
                roles = groups.setdefault(
                    (shape, thread_count, label.startswith(protocol.OFFICIAL), fp_policy), []
                )
                if (comparison, label) not in roles:
                    roles.append((comparison, label))

    points = []
    for (shape, thread_count, _, fp_policy), roles in groups.items():
        kernels = tuple(dict.fromkeys(label for _, label in roles))
        points.append(FinalPoint(shape, thread_count, kernels, tuple(roles), fp_policy))
    return points


def schedule(points, repeats):
    """Group thread counts by workload and rotate launch order across repeats."""
    groups = {}
    for point in points:
        groups.setdefault(point.shape, []).append(point)
    rng = random.Random(SEED)
    ordinal = 0
    for repeat in range(repeats):
        blocks = list(groups.items())
        rng.shuffle(blocks)
        for shape, group in blocks:
            ordered = list(group)
            rng.shuffle(ordered)
            carry = int(group[0].carry_state)
            block_id = f"{CAMPAIGN}_{shape_label(shape)}_carry{carry}_repeat{repeat}"
            for point in ordered:
                shift = ordinal % len(point.kernels)
                yield replace(
                    point, kernels=point.kernels[shift:] + point.kernels[:shift]
                ), repeat, block_id
                ordinal += 1


def provenance(cpus):
    cpu = platform.processor()
    try:
        cpu = next(
            line.split(":", 1)[1].strip()
            for line in Path("/proc/cpuinfo").read_text().splitlines()
            if line.startswith("model name")
        )
    except (OSError, StopIteration):
        pass
    return {
        "cpu_model": cpu,
        "logical_cpus": os.cpu_count(),
        "memory_gib": round(
            os.sysconf("SC_PAGE_SIZE") * os.sysconf("SC_PHYS_PAGES") / 2**30, 1
        ),
        "platform": platform.platform(),
        "python": sys.version,
        "topology": protocol.cpu_topology(cpus),
    }


def run_campaign(args):
    if args.repeats < 1:
        raise ValueError("--repeats must be positive")
    repeats = 1 if args.validate_only else args.repeats
    cpus = args.physical_cpus
    if len(set(cpus)) != len(cpus) or not set(cpus) <= os.sched_getaffinity(0):
        raise ValueError(
            "physical CPUs must be distinct and inside the allowed affinity"
        )
    threads = sorted({p for p in (1, 2, 4, 8, len(cpus)) if p <= len(cpus)})
    output = args.output_dir.resolve()
    output.mkdir(parents=True, exist_ok=True)
    if (output / "campaign.json").exists():
        raise ValueError(
            "output directory already contains campaign.json; choose a fresh directory"
        )
    points = final_points(threads)
    manifest = {
        "metadata": {
            "timestamp_utc": datetime.now(timezone.utc).isoformat(),
            "dry_run": args.dry_run,
            "validation_only": args.validate_only,
            "correctness_gate": {
                "recurrent": protocol.RECURRENT_TOLERANCE,
                "chunkwise": protocol.CHUNKWISE_TOLERANCE,
                "assignment": "chunkwise_* and official configurations use the chunkwise pair, all others the recurrent pair",
                "source": "NX-AI/mlstm_kernels FP32 forward tests at commit 99b3677",
                "rule": "finite Y,C,n,m and abs(actual-reference) <= atol + rtol*abs(reference)",
                "scope": "whole call and complete carried warmup/timing trajectory",
            },
            "seed": SEED,
            "repeats": repeats,
            "threads": threads,
            "environment": dict(protocol.OPERATOR_ENV),
            "provenance": provenance(cpus),
            "physical_cpus": cpus,
            "configuration_cells": sum(len(point.kernels) for point in points),
            "comparison_cells": sum(len(point.comparison_roles) for point in points),
        },
        "runs": [],
        "records": [],
    }
    env = {
        key: value
        for key, value in os.environ.items()
        if key not in protocol.KERNEL_SETTINGS
        and not key.startswith(("OMP_", "MKL_", "OPENBLAS_", "KMP_", "GOMP_"))
    }
    env.update(protocol.OPERATOR_ENV, OMP_PROC_BIND="close")
    if not args.dry_run:
        manifest["metadata"]["fp_probe"] = protocol.build_fp_probe(
            output / "fp_probe.so"
        )
    failed = False
    for ordinal, (point, repeat, block_id) in enumerate(schedule(points, repeats)):
        workload = shape_label(point.shape)
        backend = "_official" if point.official else ""
        policy = "" if point.fp_policy == "default" else f"_{point.fp_policy}"
        identity = (
            f"{CAMPAIGN}_{workload}_threads{point.threads}{backend}{policy}"
            f"_repeat{repeat}"
        )
        torch_threads = point.threads if point.official else TORCH_THREADS
        # Record paths relative to the campaign directory used by each process.
        raw = f"raw/{identity}.json"
        log = f"logs/{identity}"
        affinity = cpus[: point.threads]
        affinity_list = ",".join(map(str, affinity))
        arguments = [
            "--shape",
            *map(str, point.shape),
            "--threads",
            str(point.threads),
            "--torch-threads",
            str(torch_threads),
            *(["--carry-state"] if point.carry_state else []),
            "--warmup",
            str(WARMUP),
            "--reps",
            str(REPS),
            "--seed",
            str(SEED),
            "--kernels",
            *point.kernels,
            "--output",
            raw,
            *(["--validate-only"] if args.validate_only else []),
            "--fp-probe",
            "fp_probe.so",
            "--fp-policy",
            point.fp_policy,
        ]
        command = [
            "taskset",
            "-c",
            affinity_list,
            sys.executable,
            str(WORKER),
            *arguments,
        ]
        worker_env = env.copy()
        worker_env.update(
            OMP_PLACES=",".join(f"{{{cpu}}}" for cpu in affinity),
            MLSTM_BENCH_CPUS=affinity_list,
        )
        if point.official:
            worker_env.update(
                dict.fromkeys(
                    ("OMP_NUM_THREADS", "MKL_NUM_THREADS", "OPENBLAS_NUM_THREADS"),
                    str(point.threads),
                ),
                MKL_DOMAIN_NUM_THREADS=f"MKL_BLAS={point.threads}",
            )
        context = {
            "run_id": identity,
            "block_id": block_id,
            "campaign": CAMPAIGN,
            "label": workload,
            "shape": list(point.shape),
            "threads": point.threads,
            "torch_threads": torch_threads,
            "carry_state": point.carry_state,
            "fp_policy": point.fp_policy,
            "repeat": repeat,
            "seed": SEED,
            "warmup": WARMUP,
            "reps": REPS,
        }
        run = {
            **context,
            "order": ordinal,
            "kernels": list(point.kernels),
            "arguments": arguments,
            "raw_output": raw,
            "stdout": log + ".stdout.txt",
            "stderr": log + ".stderr.txt",
            "status": "planned",
            "returncode": None,
            "affinity": affinity,
            "environment": {
                key: value
                for key, value in worker_env.items()
                if key.startswith(("OMP_", "MKL_", "OPENBLAS_", "MLSTM_BENCH_"))
            },
            "comparison_roles": point.comparison_roles,
        }
        manifest["runs"].append(run)
        write_json(manifest, output / "campaign.json")
        if args.dry_run:
            print("planned " + " ".join(command))
            continue
        (output / "raw").mkdir(exist_ok=True)
        (output / "logs").mkdir(exist_ok=True)
        blas = [config for config in point.kernels if config.startswith(protocol.BLAS)]
        try:
            if repeat == 0 and blas and not args.validate_only:
                diagnostic = subprocess.run(
                    [*command, "--diagnostic"],
                    cwd=output,
                    env={**worker_env, "MKL_VERBOSE": "1"},
                    capture_output=True,
                    text=True,
                )
                diagnostic_text = diagnostic.stdout + diagnostic.stderr
                (output / (log + ".diagnostic.txt")).write_text(diagnostic_text)
                if diagnostic.returncode:
                    raise OSError(
                        "untimed runtime diagnostic failed; see .diagnostic.txt"
                    )
                for config in blas:
                    observed = protocol.marked_mkl_threads(diagnostic.stdout, config)
                    if observed is None:
                        raise OSError(f"BLAS diagnostic markers missing for {config}")
                    if observed != [1]:
                        raise OSError(
                            f"BLAS diagnostic for {config}: expected NThr:1, observed {observed}"
                        )
                run["diagnostic"] = log + ".diagnostic.txt"
            run["started_utc"] = datetime.now(timezone.utc).isoformat()
            result = subprocess.run(
                command,
                cwd=output,
                env=worker_env,
                capture_output=True,
                text=True,
                check=False,
            )
            run["finished_utc"] = datetime.now(timezone.utc).isoformat()
            run["returncode"] = result.returncode
            stdout, stderr = result.stdout, result.stderr
        except OSError as exc:
            run["returncode"] = -1
            stdout, stderr = "", str(exc)
        (output / run["stdout"]).write_text(stdout)
        (output / run["stderr"]).write_text(stderr)
        payload = read_json(output / raw)
        rows = payload["records"] if payload else []
        # Require a successful exit, passing checks and one raw result per
        # configuration.
        expected_configs = sorted(
            list(point.kernels) * (2 if args.validate_only else 1)
        )
        complete = sorted(row["configuration"] for row in rows) == expected_configs
        run["status"] = "ok" if run["returncode"] == 0 and complete else "failed"
        if not complete:
            run["error"] = "missing or incomplete raw records"
        for row in rows:
            entry = {
                **row,
                **context,
                "run_status": run["status"],
                "raw_output": raw,
            }
            entry["comparison_roles"] = [
                role
                for role in point.comparison_roles
                if role[1] == row["configuration"]
            ]
            manifest["records"].append(entry)
        run["metadata"] = payload["metadata"] if payload else None
        failed |= run["status"] == "failed"
        write_json(manifest, output / "campaign.json")
        print(f"{run['status']} {identity}", flush=True)
        if failed and not args.validate_only:
            # Keep the failure record and stop further timing after a failed check.
            break
    return int(failed)


def build_parser():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--physical-cpus",
        type=lambda s: [int(c) for c in s.split(",")],
        required=True,
        help="comma-separated CPU IDs; a run with p threads uses the first p",
    )
    parser.add_argument("--output-dir", type=Path, required=True)
    parser.add_argument(
        "--repeats", type=int, default=5, help="timing repeats (validation runs once)"
    )
    parser.add_argument("--dry-run", action="store_true")
    parser.add_argument(
        "--validate-only",
        action="store_true",
        help="run whole-call/nonzero/continuation checks across all final configurations",
    )
    return parser


def main():
    parser = build_parser()
    args = parser.parse_args()
    try:
        raise SystemExit(run_campaign(args))
    except ValueError as exc:
        parser.error(str(exc))


if __name__ == "__main__":
    main()
