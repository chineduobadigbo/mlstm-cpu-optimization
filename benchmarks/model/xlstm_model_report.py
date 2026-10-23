"""Check model campaign records and flatten paired comparisons."""

from copy import deepcopy
from typing import Sequence

from benchmarks.kernels.thesis_protocol import base_kernel
from benchmarks.model.xlstm_model_constants import (
    BACKENDS,
    DECODE_STEPS,
    PREFILL_LENGTH,
    PROMPT_LENGTHS,
    SCOPES,
    pair_execution,
)


def _one(items: list[dict], missing: str, duplicate: str) -> dict:
    if not items:
        raise ValueError(missing)
    if len(items) > 1:
        raise ValueError(duplicate)
    return items[0]


def _measurement(
    record: dict,
    *,
    scope: str,
    workload: str,
    prompt_length: int | None = None,
    block: int | None = None,
) -> dict:
    matches = []
    for measurement in record.get("measurements", []):
        if (
            measurement.get("scope"),
            measurement.get("workload"),
            measurement.get("block"),
        ) != (scope, workload, block):
            continue
        if workload == "prompt" and measurement.get("prompt_length") != prompt_length:
            continue
        if workload == "decode" and (
            measurement.get("prefill_length") != PREFILL_LENGTH
            or measurement.get("decode_length") != DECODE_STEPS
        ):
            continue
        matches.append(measurement)
    label = f"scope={scope} workload={workload}"
    if prompt_length is not None:
        label += f" prompt_length={prompt_length}"
    if block is not None:
        label += f" block={block}"
    return _one(
        matches,
        f"missing measurement for {label}",
        f"duplicate measurement for {label}",
    )


def _latency(measurement: dict) -> tuple[float, int]:
    """Return the comparison latency and recorded token count."""
    key = "median_ms" if measurement["workload"] == "prompt" else "trajectory_ms"
    return measurement[key], measurement["token_count"]


def merge_results(
    validation: dict,
    raw_records: list[dict],
    *,
    checkpoint: str,
    scopes: Sequence[str],
    kernel: str,
    pair_count: int,
    thread_counts: Sequence[int],
    execution_modes: Sequence[str] = ("eager", "eager"),
    fp_policy: str = "default",
    prefill_only: int | None = None,
) -> dict:
    """Require one process per pair and backend, then flatten paired results.

    Record kernel (the --kernel ID or configuration name) alongside its base kernel.
    Cell rows distinguish block, process pair, thread count and workload.
    """
    acceptance = validation.get("status", "unknown")
    scopes = list(scopes)
    execution = pair_execution(execution_modes)
    for key, value in (
        ("execution", execution),
        ("prefill_only", prefill_only),
        ("fp_policy", fp_policy),
    ):
        if validation.get(key) != value:
            raise ValueError(f"validation {key} does not match the campaign")
    workloads = [
        {"workload": "prompt", "prompt_length": length}
        for length in (PROMPT_LENGTHS if prefill_only is None else (prefill_only,))
    ]
    if prefill_only is None:
        workloads.append(
            {
                "workload": "decode",
                "prefill_length": PREFILL_LENGTH,
                "decode_length": DECODE_STEPS,
            }
        )

    # _one() requires exactly one matching process and measurement.
    comparison_records: list[dict[str, object]] = []
    model = host = None
    for threads in thread_counts:
        for pair_index in range(pair_count):
            runs = []
            for backend in BACKENDS:
                label = f"threads={threads} pair={pair_index} backend={backend}"
                run = _one(
                    [
                        record
                        for record in raw_records
                        if (
                            record.get("identity", {}).get("threads"),
                            record.get("identity", {}).get("pair_index"),
                            record.get("identity", {}).get("backend"),
                        )
                        == (threads, pair_index, backend)
                    ],
                    f"missing process for {label}",
                    f"duplicate process for {label}",
                )
                if model is None:
                    model, host = deepcopy(run.get("model")), deepcopy(run.get("host"))
                runs.append(run)

            for scope in scopes:
                for block in (
                    range(model["num_blocks"]) if scope == SCOPES[0] else (None,)
                ):
                    for workload in workloads:
                        (baseline_ms, tokens), (candidate_ms, _) = (
                            _latency(
                                _measurement(
                                    run,
                                    scope=scope,
                                    workload=workload["workload"],
                                    prompt_length=workload.get("prompt_length"),
                                    block=block,
                                )
                            )
                            for run in runs
                        )
                        comparison_records.append(
                            {
                                "threads": threads,
                                "pair_index": pair_index,
                                "scope": scope,
                                "block": block,
                                **workload,
                                "token_count": tokens,
                                "baseline": BACKENDS[0],
                                "candidate": BACKENDS[1],
                                "baseline_ms": baseline_ms,
                                "candidate_ms": candidate_ms,
                                "numerical_acceptance": acceptance,
                            }
                        )

    return {
        "run": {
            "numerical_acceptance": acceptance,
            "execution": execution,
            "fp_policy": fp_policy,
            "checkpoint": checkpoint,
            "backends": list(BACKENDS),
            "configuration": kernel,
            "kernel": base_kernel(kernel),
            "scopes": scopes,
            "prefill_only": prefill_only,
            "workloads": ["prompt", "decode"] if prefill_only is None else ["prompt"],
            "threads": list(thread_counts),
            "pair_count": pair_count,
        },
        "validation": deepcopy(validation),
        "model": model,
        "host": host,
        "records": comparison_records,
    }
