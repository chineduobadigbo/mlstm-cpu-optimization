"""Provide xLSTM benchmark defaults without loading the model runtime."""

OFFICIAL_BACKEND = "official"
LOCAL_KERNEL_BACKEND = "local_kernel"

# Backend order: official baseline, then local candidate.
BACKENDS = (OFFICIAL_BACKEND, LOCAL_KERNEL_BACKEND)

# adapter_core times each cell on captured official-model inputs; full_model times the
# complete causal language model call.
SCOPES = ("adapter_core", "full_model")
PROMPT_LENGTHS = (16, 64, 256, 1024)
PREFILL_LENGTH = 256
DECODE_STEPS = 128
DEFAULT_PAIR_COUNT = 8

EXECUTION_MODES = ("eager", "compiled")


def execution_metadata(mode: str) -> dict[str, object]:
    return {
        "mode": mode,
        "compile": {"backend": "inductor", "fullgraph": True, "dynamic": None}
        if mode == "compiled" else None,
    }


def pair_execution(modes: tuple[str, str]) -> dict[str, dict[str, object]]:
    """Associate modes in BACKENDS order with their execution settings."""
    return {backend: execution_metadata(mode) for backend, mode in zip(BACKENDS, modes)}
