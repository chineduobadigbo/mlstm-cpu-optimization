"""Build benchmark models from local xLSTM checkpoints."""

from copy import copy
from pathlib import Path

import torch
from torch import nn


_RUNTIME_CONFIG_OVERRIDES = {
    "chunkwise_kernel": "chunkwise--native_autograd",
    "sequence_kernel": "native_sequence__native",
    "step_kernel": "native",
    "mode": "inference",
    "return_last_states": True,
    "autocast_kernel_dtype": "float32",
    "inference_state_dtype": "float32",
}


def clone_cache(cache: object) -> object:
    """Clone every cached (C, n, m) tensor so state can change independently.

    Shallow-copy the cache to preserve seqlen_offset, using the layout in pinned
    Transformers 5.9.0.
    """
    cloned = copy(cache)
    cloned.rnn_state = {layer: tuple(tensor.clone() for tensor in state)
                        for layer, state in cache.rnn_state.items()}
    return cloned


def new_cache(model: nn.Module) -> object:
    from transformers.models.xlstm.modeling_xlstm import xLSTMCache

    return xLSTMCache(
        model.config, max_batch_size=1, dtype=torch.float32, device="cpu"
    )


def canonicalize_config(
    raw_config: dict[str, object],
) -> tuple[dict[str, object], dict[str, dict[str, object]]]:
    """Apply runtime overrides while preserving checkpoint dimensions."""
    effective_config = raw_config.copy()
    changes: dict[str, dict[str, object]] = {}
    for modern, legacy in (
        ("hidden_size", "embedding_dim"),
        ("num_hidden_layers", "num_blocks"),
    ):
        if modern not in raw_config and legacy in raw_config:
            effective_config[modern] = raw_config[legacy]
            changes[modern] = {"raw": None, "effective": raw_config[legacy]}
    effective_config.update(_RUNTIME_CONFIG_OVERRIDES)
    changes.update(
        {
            field: {"raw": raw_config.get(field), "effective": value}
            for field, value in _RUNTIME_CONFIG_OVERRIDES.items()
            if raw_config.get(field) != value
        }
    )
    return effective_config, changes


def _transformers_model_components() -> tuple[type[object], type[nn.Module]]:
    try:
        import transformers
        from transformers.models.xlstm.configuration_xlstm import xLSTMConfig
        from transformers.models.xlstm.modeling_xlstm import xLSTMForCausalLM
    except ImportError as error:
        raise RuntimeError(
            "Real-model benchmarking requires the real-model-benchmark dependency group."
        ) from error
    if transformers.__version__ != "5.9.0":
        raise RuntimeError(
            f"Transformers 5.9.0 is required, found {transformers.__version__}."
        )
    return xLSTMConfig, xLSTMForCausalLM


def reject_loading_info(loading_info: dict[str, object]) -> None:
    """Reject any weight-loading diagnostics reported by from_pretrained."""
    nonempty_categories = {key: value for key, value in loading_info.items() if value}
    if nonempty_categories:
        raise RuntimeError(
            f"Checkpoint loading diagnostics are not empty: {nonempty_categories}"
        )


def _validate_loaded_model(model: nn.Module) -> dict[str, int | float]:
    config = model.config
    # Verify FP32 parameters after from_pretrained; CPU placement and eval mode are
    # already set.
    parameters = tuple(model.parameters())
    if any(parameter.dtype != torch.float32 for parameter in parameters):
        raise RuntimeError("xLSTM model parameters must be float32")
    return {
        "parameter_count": sum(parameter.numel() for parameter in parameters),
        "eps": config.eps,
        "num_hidden_layers": int(config.num_hidden_layers),
        "num_blocks": int(config.num_blocks),
        "hidden_size": int(config.hidden_size),
        "embedding_dim": int(config.embedding_dim),
        "num_heads": int(config.num_heads),
        "vocab_size": int(config.vocab_size),
        "key_dim": int(config.hidden_size * config.qk_dim_factor) // config.num_heads,
        "value_dim": int(config.hidden_size * config.v_dim_factor) // config.num_heads,
    }


def load_model(checkpoint_dir: str | Path) -> tuple[nn.Module, dict[str, object]]:
    """Load a local checkpoint for CPU inference in FP32."""
    config_class, model_class = _transformers_model_components()
    raw_config, _ = config_class.get_config_dict(
        str(checkpoint_dir), local_files_only=True
    )
    effective_config, config_changes = canonicalize_config(raw_config)
    config = config_class(**effective_config)
    model, loading_info = model_class.from_pretrained(
        str(checkpoint_dir),
        config=config,
        dtype=torch.float32,
        local_files_only=True,
        use_safetensors=True,
        output_loading_info=True,
    )
    model.to("cpu")
    model.eval()
    reject_loading_info(loading_info)
    return model, {
        "validation": _validate_loaded_model(model),
        "config_changes": config_changes,
    }
