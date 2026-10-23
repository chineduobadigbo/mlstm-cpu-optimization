"""Compile the selected backend and fail on recompilation inside timed calls."""

from contextlib import nullcontext

import torch

from benchmarks.model.xlstm_model_constants import execution_metadata


def prepare_execution(module, execution_mode: str):
    config = execution_metadata(execution_mode)["compile"]
    if config is None:
        return module
    # Clear guards shared with earlier scopes or backends so they do not exhaust this
    # scope's recompilation allowance.
    torch.compiler.reset()
    return torch.compile(module, **config)


def timed_execution(execution_mode: str):
    return (torch.compiler.set_stance("fail_on_recompile")
            if execution_mode == "compiled" else nullcontext())
