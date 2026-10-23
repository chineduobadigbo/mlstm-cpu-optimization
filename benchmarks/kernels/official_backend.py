"""Use the model benchmark's Transformers xLSTM backend for operator comparisons.

Accept unscaled BHTD inputs, C [B,H,Dk,Dv] and m [B,H,1]. Return (Y, (C, n, m)) while
preserving the input state.
"""

from benchmarks.kernels.thesis_protocol import OFFICIAL_CHUNK
from benchmarks.model.xlstm_model_execution import prepare_execution
from benchmarks.model.xlstm_model_setup import _RUNTIME_CONFIG_OVERRIDES
from mlstm_cpu.ops import KernelSpec


def official_spec(execution_mode: str, eps: float) -> KernelSpec:
    """Expose eager or compiled official calls through the native layout adapter."""
    import transformers
    from transformers.models.xlstm.configuration_xlstm import xLSTMConfig
    from transformers.models.xlstm.modeling_xlstm import xLSTMBackend

    config = xLSTMConfig(
        **_RUNTIME_CONFIG_OVERRIDES, chunk_size=OFFICIAL_CHUNK, eps=eps
    )
    return KernelSpec(
        prepare_execution(xLSTMBackend(config), execution_mode),
        f"Transformers {transformers.__version__} xLSTM backend, {execution_mode}; returns new state",
        c_transposed=True,
        input_layout="BHTD",
    )
