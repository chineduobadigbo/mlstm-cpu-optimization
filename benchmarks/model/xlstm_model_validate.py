"""Validate local model backends against official execution before timing."""

import json
from copy import deepcopy
from pathlib import Path
from typing import Sequence

import torch
from torch import nn

from benchmarks.model.xlstm_model_backends import install_backend
from benchmarks.model.xlstm_model_constants import (
    BACKENDS,
    SCOPES,
    PREFILL_LENGTH,
    PROMPT_LENGTHS,
    pair_execution,
)
from benchmarks.model.xlstm_model_execution import prepare_execution
from benchmarks.model.xlstm_model_setup import clone_cache, load_model, new_cache


_ADAPTER_ARGUMENTS = ("query", "key", "value", "igate", "fgate", "c_initial", "n_initial", "m_initial")
_MODEL_TOLERANCE = {"rtol": 1e-3, "atol": 1e-4}


def load_prompt_fixture(path: str | Path, vocab_size: int) -> dict[str, object]:
    """Load saved prompt token IDs without constructing a tokenizer."""
    payload = json.loads(Path(path).read_text(encoding="utf-8"))
    token_ids = (*payload["prompts"].values(), payload["teacher_forced_continuation"])
    if max(max(ids) for ids in token_ids) >= vocab_size:
        raise ValueError("Prompt fixture contains token IDs outside the model vocabulary")
    return payload


def _capture_adapter_calls(
    model: nn.Module, run, names: Sequence[str] = _ADAPTER_ARGUMENTS
) -> list[list[dict[str, torch.Tensor]]]:
    """Run the callback and clone adapter arguments from every call in each block."""
    calls: list[list[dict[str, torch.Tensor]]] = [[] for _ in model.backbone.blocks]
    handles = []
    for block, block_calls in zip(model.backbone.blocks, calls):
        def capture(_module, _args, kwargs, block_calls=block_calls) -> None:
            block_calls.append({name: kwargs[name].detach().clone() for name in names})

        handles.append(block.mlstm_layer.mlstm_backend.register_forward_pre_hook(capture, with_kwargs=True))
    try:
        with torch.inference_mode():
            run()
    finally:
        for handle in handles:
            handle.remove()
    return calls


def _capture_cell_inputs(
    model: nn.Module, input_ids: torch.Tensor, cache: object, workload: str
) -> list[dict[str, torch.Tensor]]:
    """Capture official cell inputs from all blocks for validation and timing."""
    calls = _capture_adapter_calls(
        model, lambda: model(input_ids=input_ids, cache_params=cache, use_cache=True))
    if not all(calls):
        raise RuntimeError(f"capture backend=official workload={workload} tensor=adapter: hook did not run")
    return [block_calls[0] for block_calls in calls]


def _capture_adapter_input(
    model: nn.Module, input_ids: torch.Tensor, cache: object, workload: str
) -> dict[str, torch.Tensor]:
    """Extract the first block's captured official-model inputs."""
    return _capture_cell_inputs(model, input_ids, cache, workload)[0]


def _closeness(actual: torch.Tensor, expected: torch.Tensor, tolerance: dict[str, float]) -> dict[str, object]:
    """Compare each absolute error with atol + rtol * abs(expected)."""
    difference = (actual - expected).abs()
    bound = tolerance["atol"] + tolerance["rtol"] * expected.abs()
    return {
        "shape": list(actual.shape), "elements": actual.numel(),
        "failing_elements": int((difference > bound).sum()),
        "max_abs_error": float(difference.max()),
        "max_tolerance_ratio": float((difference / bound).max()),
        "tolerance": tolerance,
    }


def _check_close(
    actual: torch.Tensor,
    expected: torch.Tensor,
    *,
    check: str,
    subject: str,
    workload: str,
    tensor: str,
    tolerance: dict[str, float],
    failures: list[dict[str, object]],
) -> None:
    """Collect tolerance mismatches; reject invalid shapes and non-finite values."""
    message = (
        f"{check} {subject} workload={workload} tensor={tensor}: "
        f"mismatch at rtol={tolerance['rtol']} atol={tolerance['atol']}"
    )
    if (
        actual.shape != expected.shape
        or not torch.isfinite(actual).all()
        or not torch.isfinite(expected).all()
    ):
        raise RuntimeError(message)
    if not torch.allclose(actual, expected, **tolerance):
        failures.append({
            "message": message, "check": check, "subject": subject, "workload": workload,
            "tensor": tensor, **_closeness(actual, expected, tolerance),
        })


def _validate_recurrence(
    model: nn.Module,
    captured: dict[str, torch.Tensor],
    kernel: str,
    workload: str,
    failures: list[dict[str, object]],
) -> None:
    outputs = []
    for backend in BACKENDS:
        inputs = {name: tensor.clone() for name, tensor in captured.items()}
        with install_backend(model, backend, kernel):
            adapter = model.backbone.blocks[0].mlstm_layer.mlstm_backend
            hidden, state = adapter(**inputs, return_last_states=True)
        outputs.append((hidden, *state))
    expected, actual = outputs
    for name, actual_tensor, expected_tensor in zip(
        ("h", "C", "n", "m"), actual, expected, strict=True
    ):
        _check_close(
            actual_tensor,
            expected_tensor,
            check="recurrence",
            subject=f"backend={BACKENDS[1]} reference={BACKENDS[0]}",
            workload=workload,
            tensor=name,
            tolerance=_MODEL_TOLERANCE,
            failures=failures,
        )


def _run_model(
    model: nn.Module,
    backend: str,
    kernel: str,
    input_ids: torch.Tensor,
    cache: object,
):
    with install_backend(model, backend, kernel):
        with torch.inference_mode():
            output = model(input_ids=input_ids, cache_params=cache, use_cache=True)
    return output.logits.detach().clone(), output.cache_params


def _compare_caches(
    left: object, right: object, pair: str, workload: str, failures: list[dict[str, object]]
) -> None:
    if left.seqlen_offset != right.seqlen_offset:
        raise RuntimeError(f"model_pair pair={pair} workload={workload} tensor=seqlen_offset: mismatch")
    if left.rnn_state.keys() != right.rnn_state.keys():
        raise RuntimeError(
            f"model_pair pair={pair} workload={workload} tensor=cache_layers: mismatch"
        )
    for layer in left.rnn_state:
        for name, left_tensor, right_tensor in zip(
            ("C", "n", "m"),
            left.rnn_state[layer],
            right.rnn_state[layer],
            strict=True,
        ):
            _check_close(
                left_tensor,
                right_tensor,
                check="model_pair",
                subject=f"pair={pair}",
                workload=workload,
                tensor=f"cache[{layer}].{name}",
                tolerance=_MODEL_TOLERANCE,
                failures=failures,
            )


def _validate_model_pair(
    model: nn.Module,
    prompt: torch.Tensor,
    continuation: torch.Tensor,
    kernel: str,
    failures: list[dict[str, object]],
) -> None:
    pair = ",".join(BACKENDS)
    base_cache = new_cache(model)
    caches = [clone_cache(base_cache), clone_cache(base_cache)]
    calls = [(f"prefill length={prompt.shape[1]}", prompt)]
    calls.extend((f"teacher_forced_decode step={step}", continuation[:, step:step+1])
                 for step in range(continuation.shape[1]))
    for workload, tokens in calls:
        logits = []
        for index, backend in enumerate(BACKENDS):
            output, caches[index] = _run_model(model, backend, kernel, tokens, caches[index])
            logits.append(output)
        _check_close(logits[1], logits[0], check="model_pair", subject=f"pair={pair}",
                     workload=workload, tensor="logits", tolerance=_MODEL_TOLERANCE, failures=failures)
        _compare_caches(caches[1], caches[0], pair, workload, failures)


def _validate_compiled_execution(model, fixture, kernel, scopes, failures, prefill_only=None,
                                 execution_modes=("compiled", "compiled")):
    """Validate outputs at the execution modes and call boundaries used in timing.

    In adapter_core scope, check every block on captured inputs and collect mismatches
    in failures. If the official backend is compiled, also compare its output with
    eager execution for diagnostics only.
    """
    from benchmarks.model.xlstm_model_measure import (
        _fixture_tokens, _capture_adapter_decode_inputs,
        _adapter_state, run_adapter_step,
    )

    prompts, continuation = _fixture_tokens(fixture, prefill_only)
    if "adapter_core" in scopes:
        captures = {
            length: _capture_cell_inputs(model, tokens, new_cache(model), f"prefill length={length}")
            for length, tokens in prompts.items()
        }
        if continuation:
            post_prefill, steps = _capture_adapter_decode_inputs(
                model, prompts[PREFILL_LENGTH], continuation
            )
    # Share weight tensors while copying modules so their backends can be replaced
    # independently.
    candidate_model = deepcopy(model, {id(p): p for p in model.parameters()})
    reference_backend, backend = BACKENDS
    reference_mode, candidate_mode = execution_modes
    checks = []
    with (torch.inference_mode(),
          install_backend(model, reference_backend, kernel),
          install_backend(candidate_model, backend, kernel)):
        for scope in scopes:
            cell = scope == "adapter_core"
            if cell:
                pairs = [(left.mlstm_layer.mlstm_backend, right.mlstm_layer.mlstm_backend)
                         for left, right in zip(model.backbone.blocks, candidate_model.backbone.blocks)]
            else:
                pairs = [(model, candidate_model)]
            # Prepare both selected modes alongside the official eager control.
            units = [(baseline, prepare_execution(baseline, reference_mode),
                      prepare_execution(candidate, candidate_mode)) for baseline, candidate in pairs]
            subject = f"backend={backend} reference={reference_backend} scope={scope}"
            output_name = "hidden" if cell else "logits"
            copy_state = (lambda state: tuple(t.clone() for t in state)) if cell else clone_cache
            failures_before = len(failures)
            control = {"compared": f"{reference_backend} compiled vs {reference_backend} eager",
                       "tensor": output_name, "failing_elements": 0, "max_tolerance_ratio": 0.0,
                       "max_abs_error": 0.0, "workload": None, "tolerance": dict(_MODEL_TOLERANCE),
                       } if reference_mode == "compiled" else None

            def compare(left, right, left_state, right_state, workload):
                _check_close(
                    right, left, check="compiled", subject=subject,
                    workload=workload, tensor=output_name,
                    tolerance=_MODEL_TOLERANCE, failures=failures,
                )
                if cell:
                    for name, reference_state, compiled_state in zip(
                        ("C", "n", "m"), left_state, right_state, strict=True
                    ):
                        _check_close(
                            compiled_state, reference_state,
                            check="compiled", subject=subject,
                            workload=workload, tensor=name,
                            tolerance=_MODEL_TOLERANCE, failures=failures,
                        )
                else:
                    _compare_caches(right_state, left_state, subject, workload, failures)

            def record_control(compiled_output, eager_output, workload):
                result = _closeness(compiled_output, eager_output, _MODEL_TOLERANCE)
                control["failing_elements"] += result["failing_elements"]
                if result["max_tolerance_ratio"] > control["max_tolerance_ratio"]:
                    control.update(max_tolerance_ratio=result["max_tolerance_ratio"],
                                   max_abs_error=result["max_abs_error"], workload=workload)

            def run(call, inputs, state):
                if cell:
                    output, state = run_adapter_step(call, inputs, state)
                    return output[0], state
                output = call(input_ids=inputs, cache_params=state, use_cache=True)
                return output.logits, output.cache_params

            def step(unit, inputs, states, workload):
                baseline, reference, candidate = unit
                left_state, right_state, eager_state = states
                left, left_state = run(reference, inputs, left_state)
                right, right_state = run(candidate, inputs, right_state)
                compare(left, right, left_state, right_state, workload)
                if control is not None:
                    eager, eager_state = run(baseline, inputs, eager_state)
                    record_control(left, eager, workload)
                return left_state, right_state, eager_state

            def label(workload, block):
                return f"{workload} block={block}" if cell else workload

            for length in prompts:
                for block, unit in enumerate(units):
                    inputs = captures[length][block] if cell else prompts[length]
                    initial = _adapter_state(inputs) if cell else new_cache(model)
                    states = step(unit, inputs, (initial, copy_state(initial), copy_state(initial)),
                                  label(f"prefill length={length}", block))
                    if not cell and length == PREFILL_LENGTH:
                        decode_states = [states]
            # Full-model decode keeps each model's prefill state; cell decode copies the
            # captured official post-prefill state.
            if continuation:
                # Clear shared prefill compilation guards before validating single-token
                # decode calls.
                torch.compiler.reset()
            if continuation and cell:
                decode_states = []
                for block in range(len(units)):
                    initial = tuple(t.clone() for t in post_prefill.rnn_state[block])
                    decode_states.append((initial, copy_state(initial), copy_state(initial)))
            # Always start decode from the 256-token prefill.
            for index, tokens in enumerate(continuation):
                for block, unit in enumerate(units):
                    decode_states[block] = step(unit, steps[block][index] if cell else tokens,
                                                decode_states[block], label(f"decode step={index}", block))
            checks.append({
                "backend": backend, "reference_backend": reference_backend,
                "scope": scope, "status": "failed" if len(failures) > failures_before else "passed",
                "blocks": len(units) if cell else None,
                "prompt_lengths": list(prompts),
                "prefill_length": PREFILL_LENGTH if continuation else None,
                "decode_steps": len(continuation),
                "tolerance": dict(_MODEL_TOLERANCE),
                "control": control,
            })
    return checks


def validate_model(
    checkpoint_dir: Path,
    fixture_path: Path,
    kernel: str,
    execution_modes: Sequence[str] = ("eager", "eager"),
    scopes: Sequence[str] = SCOPES,
    prefill_only: int | None = None,
) -> dict[str, object]:
    """Validate official and local execution before timing, with modes in BACKENDS order.

    Eager pairs check the first cell block and full model. Compiled pairs check selected
    scopes at timed call boundaries. Collect finite tolerance mismatches in
    numerical_failures and mark failure while continuing checks. Raise immediately for
    invalid shapes, non-finite values, or execution errors.
    """
    eager = set(execution_modes) == {"eager"}
    model, load_metadata = load_model(checkpoint_dir)
    fixture = load_prompt_fixture(fixture_path, int(model.config.vocab_size))
    prompts = fixture["prompts"]
    continuation = fixture["teacher_forced_continuation"]
    prompt_lengths = PROMPT_LENGTHS if prefill_only is None else (prefill_only,)
    if prefill_only is not None:
        continuation = []
    recurrence = []
    failures: list[dict[str, object]] = []
    if eager:
        prompt = torch.tensor([prompts[str(prompt_lengths[0])]], dtype=torch.long)
        capture_cache = new_cache(model)
        captures = [
            ("prefill", _capture_adapter_input(model, prompt, capture_cache, "prefill")),
        ]
        if continuation:
            next_token = torch.tensor([[continuation[0]]], dtype=torch.long)
            captures.append((
                "warm_step",
                _capture_adapter_input(model, next_token, capture_cache, "warm_step"),
            ))
        for workload, captured in captures:
            failures_before = len(failures)
            _validate_recurrence(model, captured, kernel, workload, failures)
            recurrence.append(
                {"backend": BACKENDS[1], "reference_backend": BACKENDS[0],
                 "workload": workload, "status": "failed" if len(failures) > failures_before else "passed"}
            )
        for length in prompt_lengths:
            tokens = torch.tensor([prompts[str(length)]], dtype=torch.long)
            decode = torch.tensor([continuation if length == PREFILL_LENGTH else []], dtype=torch.long)
            _validate_model_pair(model, tokens, decode, kernel, failures)
    compiled_checks = [] if eager else _validate_compiled_execution(
        model, fixture, kernel, scopes, failures, prefill_only, tuple(execution_modes))
    return {
        "execution": pair_execution(execution_modes),
        "compiled_checks": compiled_checks,
        "status": "failed" if failures else "passed",
        **({"failure_kind": "numerical", "numerical_failures": failures} if failures else {}),
        "backends": list(BACKENDS),
        "reference_backend": BACKENDS[0],
        "kernel": kernel,
        "prefill_only": prefill_only,
        "load": load_metadata,
        "fixture": {
            "tokenizer": fixture["tokenizer"],
            "bos_token_id": fixture["bos_token_id"],
        },
        "recurrence": recurrence,
        "model_pair": {
            "pair": list(BACKENDS),
            "prompt_lengths": list(prompt_lengths),
            "prefill_length": PREFILL_LENGTH if continuation else None,
            "decode_steps": len(continuation),
            "checked": "logits, all layer C/n/m states and cache offset after every call",
            "tolerance": _MODEL_TOLERANCE,
            "status": "failed" if any(f["check"] == "model_pair" for f in failures) else "passed",
        } if eager or "full_model" in scopes else None,
    }
