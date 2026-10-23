"""Time xLSTM calls in a configured benchmark process.

Import after the CLI applies the environment and CPU affinity.
"""

import json
import os
import platform
import statistics
import subprocess
import sys
import time
from contextlib import contextmanager
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Callable, Sequence

import torch
from torch import nn

from benchmarks.kernels import thesis_protocol as protocol
from benchmarks.model.xlstm_model_constants import (
    BACKENDS,
    execution_metadata,
    DECODE_STEPS,
    LOCAL_KERNEL_BACKEND,
    PREFILL_LENGTH,
    PROMPT_LENGTHS,
    SCOPES,
)
from benchmarks.model.xlstm_model_execution import prepare_execution, timed_execution
from benchmarks.model.xlstm_model_validate import (
    _ADAPTER_ARGUMENTS,
    _capture_adapter_calls,
    _capture_cell_inputs,
    load_prompt_fixture,
)
from benchmarks.model.xlstm_model_backends import install_backend
from benchmarks.model.xlstm_model_setup import clone_cache, load_model, new_cache

PROMPT_WARMUPS = 2
PROMPT_SAMPLES = 5
DECODE_WARMUPS = 2
DIAGNOSTIC_DECODE_STEPS = 4


def fp_checkpoint(reset=False):
    # Team resizing may replace OS threads. Record IDs, but validate size, affinity and
    # FP flags through fp_state. Reset applies the process policy to the caller and
    # every OpenMP thread.
    path = os.environ.get("MLSTM_FP_PROBE")
    if not path:
        return None
    policy = os.environ.get("MLSTM_FP_POLICY", "default")
    return protocol.fp_state(
        protocol.load_fp_probe(path, policy), torch.get_num_threads(), reset=reset
    )


def time_prompt_samples(
    run: Callable[[], object],
    reset: Callable[[], object],
    *,
    warmups: int = PROMPT_WARMUPS,
    samples: int = PROMPT_SAMPLES,
    execution_mode: str = "eager",
) -> dict[str, object]:
    """Time prompt calls with state resets outside the timer."""
    sample_times: list[float] = []
    with torch.inference_mode():
        for _ in range(warmups):
            reset()
            run()
        before = fp_checkpoint()
        for _ in range(samples):
            reset()
            with timed_execution(execution_mode):
                started = time.perf_counter_ns()
                run()
                sample_times.append((time.perf_counter_ns() - started) / 1_000_000)
    after = fp_checkpoint()
    return {
        **({"fp_before": before, "fp_after": after} if before else {}),
        "samples_ms": sample_times,
        "median_ms": statistics.median(sample_times),
    }


def time_decode_trajectory(
    run_step: Callable[[int], object],
    reset: Callable[[], object],
    *,
    warmups: int = DECODE_WARMUPS,
    steps: int = DECODE_STEPS,
    execution_mode: str = "eager",
) -> dict[str, object]:
    """Warm up full decode sequences, then time one sequence with persistent state."""
    with torch.inference_mode():
        for _ in range(warmups):
            reset()
            for step in range(steps):
                run_step(step)
        reset()
        before = fp_checkpoint()
        with timed_execution(execution_mode):
            started = time.perf_counter_ns()
            for step in range(steps):
                run_step(step)
            trajectory_ms = (time.perf_counter_ns() - started) / 1_000_000
    after = fp_checkpoint()
    return {
        "trajectory_ms": trajectory_ms,
        **({"fp_before": before, "fp_after": after} if before else {}),
    }


def _transformers_version() -> str:
    import transformers

    return transformers.__version__


def _fixture_tokens(
    fixture: dict[str, object],
    prefill_only: int | None = None,
) -> tuple[dict[int, torch.Tensor], list[torch.Tensor]]:
    lengths = PROMPT_LENGTHS if prefill_only is None else (prefill_only,)
    prompts = {
        length: torch.tensor([fixture["prompts"][str(length)]], dtype=torch.long)
        for length in lengths
    }
    continuation = (
        fixture["teacher_forced_continuation"] if prefill_only is None else []
    )
    return prompts, [
        torch.tensor([[token]], dtype=torch.long) for token in continuation
    ]


def _capture_adapter_decode_inputs(
    model: Any,
    prefill_ids: torch.Tensor,
    continuation_ids: Sequence[torch.Tensor],
) -> tuple[object, list[list[dict[str, torch.Tensor]]]]:
    """Capture each block's single-token inputs in an untimed decode pass.

    Replay these inputs during timing, carrying separate state from the saved
    post-prefill cache.
    """
    prefill_cache = new_cache(model)
    with torch.inference_mode():
        model(input_ids=prefill_ids, cache_params=prefill_cache, use_cache=True)
    post_prefill_cache = clone_cache(prefill_cache)
    trajectory_cache = clone_cache(post_prefill_cache)

    def decode() -> None:
        for input_ids in continuation_ids:
            model(input_ids=input_ids, cache_params=trajectory_cache, use_cache=True)

    captured_steps = _capture_adapter_calls(
        model, decode, _ADAPTER_ARGUMENTS[:5]
    )  # q, k, v, i, f only.
    if any(len(steps) != len(continuation_ids) for steps in captured_steps):
        raise RuntimeError(
            "adapter decode capture did not record every persistent step"
        )
    return post_prefill_cache, captured_steps


def _adapter_state(
    captured: dict[str, torch.Tensor],
) -> tuple[torch.Tensor, torch.Tensor, torch.Tensor]:
    return tuple(captured[name].clone() for name in ("c_initial", "n_initial", "m_initial"))  # type: ignore[return-value]  # Exactly three state tensors.


def _run_adapter(
    adapter: Any,
    captured: dict[str, torch.Tensor],
    state: tuple[torch.Tensor, torch.Tensor, torch.Tensor],
) -> object:
    return adapter(
        query=captured["query"],
        key=captured["key"],
        value=captured["value"],
        igate=captured["igate"],
        fgate=captured["fgate"],
        c_initial=state[0],
        n_initial=state[1],
        m_initial=state[2],
    )


def run_adapter_step(
    adapter: Any,
    captured: dict[str, torch.Tensor],
    state: tuple[torch.Tensor, torch.Tensor, torch.Tensor],
) -> tuple[object, tuple[torch.Tensor, torch.Tensor, torch.Tensor]]:
    """Return the adapter result and the state to carry into the next call.

    load_model sets return_last_states, making both backends return (h, (C, n, m)).
    """
    output = _run_adapter(adapter, captured, state)
    return output, output[1]


def _prompt_record(
    scope: str, prompt_length: int, timing: dict[str, object]
) -> dict[str, object]:
    return {
        "scope": scope,
        "workload": "prompt",
        "prompt_length": prompt_length,
        "token_count": prompt_length,
        **timing,
    }


def _decode_record(scope: str, timing: dict[str, object]) -> dict[str, object]:
    return {
        "scope": scope,
        "workload": "decode",
        "prefill_length": PREFILL_LENGTH,
        "token_count": DECODE_STEPS,
        "decode_length": DECODE_STEPS,
        **timing,
    }


def measure_adapter_core(
    model: Any,
    prompt_inputs: dict[int, torch.Tensor],
    continuation_inputs: Sequence[torch.Tensor],
    backend: str,
    kernel: str,
    execution_mode: str = "eager",
) -> list[dict[str, object]]:
    """Time each adapter on inputs captured from its official-model block."""
    captures = {
        prompt_length: _capture_cell_inputs(
            model,
            prompt_inputs[prompt_length],
            new_cache(model),
            f"prefill length={prompt_length}",
        )
        for prompt_length in prompt_inputs
    }
    if continuation_inputs:
        post_prefill_cache, captured_steps = _capture_adapter_decode_inputs(
            model, prompt_inputs[PREFILL_LENGTH], continuation_inputs
        )
    records: list[dict[str, object]] = []
    with install_backend(model, backend, kernel):
        # Prepare every adapter first so blocks sharing code and settings can reuse
        # compiled graphs.
        adapters = [
            prepare_execution(block.mlstm_layer.mlstm_backend, execution_mode)
            for block in model.backbone.blocks
        ]
        for block, adapter in enumerate(adapters):
            for prompt_length in prompt_inputs:
                captured = captures[prompt_length][block]
                state: tuple[torch.Tensor, torch.Tensor, torch.Tensor] | None = None

                def reset() -> None:
                    nonlocal state
                    state = _adapter_state(captured)

                def run() -> object:
                    return _run_adapter(adapter, captured, state)

                timing = time_prompt_samples(run, reset, execution_mode=execution_mode)
                records.append(
                    {**_prompt_record(SCOPES[0], prompt_length, timing), "block": block}
                )

            if not continuation_inputs:
                continue

            state = None

            def reset_decode() -> None:
                nonlocal state
                state = tuple(
                    tensor.clone() for tensor in post_prefill_cache.rnn_state[block]
                )

            def run_decode_step(step: int) -> object:
                nonlocal state
                output, state = run_adapter_step(
                    adapter, captured_steps[block][step], state
                )
                return output

            timing = time_decode_trajectory(
                run_decode_step, reset_decode, execution_mode=execution_mode
            )
            records.append({**_decode_record(SCOPES[0], timing), "block": block})
    return records


def _measure_model_calls(
    model: Any,
    scope: str,
    call: Callable[[torch.Tensor, object], object],
    prompt_inputs: dict[int, torch.Tensor],
    continuation_inputs: Sequence[torch.Tensor],
    execution_mode: str = "eager",
) -> list[dict[str, object]]:
    records: list[dict[str, object]] = []
    for prompt_length in prompt_inputs:
        base_cache = new_cache(model)
        cache: object | None = None

        def reset() -> None:
            nonlocal cache
            cache = clone_cache(base_cache)

        def run() -> object:
            return call(prompt_inputs[prompt_length], cache)

        records.append(
            _prompt_record(
                scope,
                prompt_length,
                time_prompt_samples(run, reset, execution_mode=execution_mode),
            )
        )

    if not continuation_inputs:
        return records

    prefill_cache = new_cache(model)
    with torch.inference_mode():
        call(prompt_inputs[PREFILL_LENGTH], prefill_cache)
    post_prefill_cache = clone_cache(prefill_cache)
    cache = None

    def reset_decode() -> None:
        nonlocal cache
        cache = clone_cache(post_prefill_cache)

    def run_decode_step(step: int) -> object:
        return call(continuation_inputs[step], cache)

    records.append(
        _decode_record(
            scope,
            time_decode_trajectory(
                run_decode_step, reset_decode, execution_mode=execution_mode
            ),
        )
    )
    return records


def measure_model(
    model: Any,
    prompt_inputs: dict[int, torch.Tensor],
    continuation_inputs: Sequence[torch.Tensor],
    backend: str,
    kernel: str,
    execution_mode: str = "eager",
) -> list[dict[str, object]]:
    """Time full language-model calls for the selected prompt and decode workloads."""
    with install_backend(model, backend, kernel):
        call = prepare_execution(model, execution_mode)
        return _measure_model_calls(
            model,
            SCOPES[1],
            lambda input_ids, cache: call(
                input_ids=input_ids, cache_params=cache, use_cache=True
            ),
            prompt_inputs,
            continuation_inputs,
            execution_mode,
        )


class _WrappedCell(nn.Module):
    """Invoke before(block) and after(block) around a block's cell call."""

    def __init__(
        self,
        cell: Any,
        block: int,
        before: Callable[[int], None],
        after: Callable[[int], None],
    ) -> None:
        super().__init__()
        self.cell, self.block, self.before, self.after = cell, block, before, after

    def forward(self, **kwargs: object) -> object:
        self.before(self.block)
        output = self.cell(**kwargs)
        self.after(self.block)
        return output


@contextmanager
def _wrap_cells(
    model: Any, before: Callable[[int], None], after: Callable[[int], None]
):
    """Temporarily wrap every installed cell for an untimed diagnostic pass."""
    layers = [block.mlstm_layer for block in model.backbone.blocks]
    cells = [layer.mlstm_backend for layer in layers]
    try:
        for block, (layer, cell) in enumerate(zip(layers, cells)):
            layer.mlstm_backend = _WrappedCell(cell, block, before, after)
        yield
    finally:
        for layer, cell in zip(layers, cells):
            layer.mlstm_backend = cell


def time_cells_in_model(
    model: Any,
    prompt_inputs: dict[int, torch.Tensor],
    continuation_inputs: Sequence[torch.Tensor],
    backend: str,
    kernel: str,
    execution_mode: str = "eager",
) -> dict[str, object]:
    """Sum cell times by block during a pass outside full-model timing.

    Reset the cache for each prompt; start decode after an uncounted 256-token prefill.
    Available only in eager mode: timers inside compiled graphs violate fullgraph=True.
    """
    if execution_mode != "eager":
        return {"available": False, "reason": f"{execution_mode} execution"}
    blocks = len(model.backbone.blocks)
    started, cell_ns = [0] * blocks, [0] * blocks

    def start(block: int) -> None:
        started[block] = time.perf_counter_ns()

    def stop(block: int) -> None:
        cell_ns[block] += time.perf_counter_ns() - started[block]

    def run(calls: Sequence[torch.Tensor], cache: object) -> dict[str, object]:
        cell_ns[:] = [0] * blocks
        begin = time.perf_counter_ns()
        for input_ids in calls:
            model(input_ids=input_ids, cache_params=cache, use_cache=True)
        wall_ns = time.perf_counter_ns() - begin
        return {
            "cell_ms": [ns / 1_000_000 for ns in cell_ns],
            "total_cell_ms": sum(cell_ns) / 1_000_000,
            "wall_ms": wall_ns / 1_000_000,
        }

    workloads = []
    with (
        torch.inference_mode(),
        install_backend(model, backend, kernel),
        _wrap_cells(model, start, stop),
    ):
        for length, input_ids in prompt_inputs.items():
            workloads.append(
                _prompt_record(SCOPES[1], length, run([input_ids], new_cache(model)))
            )
        if continuation_inputs:
            cache = new_cache(model)
            model(
                input_ids=prompt_inputs[PREFILL_LENGTH],
                cache_params=cache,
                use_cache=True,
            )
            workloads.append(_decode_record(SCOPES[1], run(continuation_inputs, cache)))
    return {"available": True, "workloads": workloads}


def print_marked_cell_calls(
    checkpoint_dir: Path,
    fixture_path: Path,
    kernel: str,
    threads: int,
    prefill_only: int | None = None,
) -> None:
    """Diagnose one prefill and a short local-kernel decode in eager mode.

    Exclude these calls from timing. Print BEGIN/END markers around each cell call to
    identify its MKL_VERBOSE output.
    """
    torch.set_num_threads(threads)
    torch.set_num_interop_threads(1)
    model, _ = load_model(checkpoint_dir)
    fixture = load_prompt_fixture(fixture_path, vocab_size=int(model.config.vocab_size))
    prompt_inputs, continuation_inputs = _fixture_tokens(fixture, prefill_only)
    calls = [
        prompt_inputs[prefill_only or PREFILL_LENGTH],
        *continuation_inputs[:DIAGNOSTIC_DECODE_STEPS],
    ]

    def marker(word: str) -> Callable[[int], None]:
        return lambda _block: print(f"{word} {LOCAL_KERNEL_BACKEND}", flush=True)

    cache = new_cache(model)
    with (
        torch.inference_mode(),
        install_backend(model, LOCAL_KERNEL_BACKEND, kernel),
        _wrap_cells(model, marker("BEGIN"), marker("END")),
    ):
        for input_ids in calls:
            model(input_ids=input_ids, cache_params=cache, use_cache=True)


def _command_output(*args: str) -> str | None:
    try:
        result = subprocess.run(
            args, check=False, capture_output=True, text=True, timeout=10
        )
    except (OSError, subprocess.TimeoutExpired):
        return None
    return result.stdout.strip() or result.stderr.strip() or None


def _os_release() -> str | None:
    try:
        for line in Path("/etc/os-release").read_text(encoding="utf-8").splitlines():
            if line.startswith("PRETTY_NAME="):
                return line.split("=", 1)[1].strip().strip('"')
    except OSError:
        pass
    return None


def _host_metadata(transformers_version: str) -> dict[str, object]:
    lscpu = _command_output("lscpu", "-J")
    try:
        topology = json.loads(lscpu) if lscpu else None
    except json.JSONDecodeError:
        topology = None
    cpu_info = {
        entry["field"].rstrip(":"): entry["data"]
        for entry in (topology or {}).get("lscpu", [])
        if "field" in entry and "data" in entry
    }
    return {
        "cpu_model": cpu_info.get("Model name") or platform.processor(),
        "memory_gib": round(
            os.sysconf("SC_PAGE_SIZE") * os.sysconf("SC_PHYS_PAGES") / 2**30, 1
        ),
        "os": _os_release(),
        "kernel": platform.release(),
        "python": sys.version.split()[0],
        "torch": torch.__version__,
        "transformers": transformers_version,
        "torch_config": torch.__config__.show(),
    }


def run_worker(
    checkpoint_dir: Path,
    fixture_path: Path,
    backend: str,
    scopes: Sequence[str],
    kernel: str,
    threads: int,
    pair_index: int,
    selected_affinity: Sequence[int],
    execution_mode: str = "eager",
    prefill_only: int | None = None,
    fp_policy: str = "default",
    in_model_cells: bool = False,
) -> dict:
    """Load and time a backend, returning a JSON-serializable process record.

    The campaign validates thread counts, affinity and scopes. execution_mode selects
    the backend mode. fp_policy is metadata; fp_checkpoint applies MLSTM_FP_POLICY.
    in_model_cells enables the separate full-model cell diagnostic.
    """
    started_utc = datetime.now(timezone.utc).isoformat()
    selected_scopes = tuple(scopes)
    torch.set_num_threads(threads)
    torch.set_num_interop_threads(1)
    fp_checkpoint(reset=True)
    model, load_metadata = load_model(checkpoint_dir)
    transformers_version = _transformers_version()
    fixture = load_prompt_fixture(fixture_path, vocab_size=int(model.config.vocab_size))
    prompt_inputs, continuation_inputs = _fixture_tokens(fixture, prefill_only)
    host = _host_metadata(transformers_version)
    measurements: list[dict[str, object]] = []
    arguments = (
        model,
        prompt_inputs,
        continuation_inputs,
        backend,
        kernel,
        execution_mode,
    )
    for scope in SCOPES:
        if scope in selected_scopes:
            measurements.extend(
                measure_adapter_core(*arguments)
                if scope == "adapter_core"
                else measure_model(*arguments)
            )
    cells = (
        time_cells_in_model(*arguments)
        if in_model_cells and SCOPES[1] in selected_scopes
        else None
    )
    return {
        "started_utc": started_utc,
        "finished_utc": datetime.now(timezone.utc).isoformat(),
        "identity": {
            "execution": execution_metadata(execution_mode),
            "fp_policy": fp_policy,
            "checkpoint": checkpoint_dir.resolve().name,
            "backends": list(BACKENDS),
            "backend": backend,
            "scopes": list(selected_scopes),
            "prefill_only": prefill_only,
            "kernel": kernel,
            "threads": threads,
            "pair_index": pair_index,
            "affinity": list(selected_affinity),
        },
        "model": load_metadata["validation"],
        "host": host,
        "runtime": {
            "parallel_info": torch.__config__.parallel_info(),
            "environment": {
                key: value
                for key, value in os.environ.items()
                if key in protocol.KERNEL_SETTINGS
                or key.startswith(("OMP_", "MKL_", "OPENBLAS_", "MLSTM_BENCH_"))
            },
        },
        "measurements": measurements,
        "in_model_cells": cells,
    }
