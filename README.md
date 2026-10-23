# mLSTM CPU kernels

FP32 CPU kernels using AVX2/FMA and OpenMP for the recurrent and chunkwise xLSTM mLSTM cell. This code includes the benchmarks and final results of a master's thesis.

## Requirements

- Ubuntu on x86-64 with AVX2 and FMA
- `build-essential`
- `uv`

## Build

Run from the project root:

```bash
uv sync --group real-model-benchmark
.venv/bin/python setup.py build_ext --inplace --force
```

## Test

After building, run the operator tests:

```bash
.venv/bin/python -m pytest tests
```

## Run

`benchmarks/campaigns/final-run.sh` contains the commands to reproduce all results.
It uses CPUs 0-15. Set `CHECKPOINTS` to a folder containing these two checkpoint directories
from the Hugging Face repository `NX-AI/xlstm_scaling_laws` at revision
`2ce74c14add515517ae6a32d3ae80cc766f62c03`:

- `mlstm_v1--tokenparam--ctx-8192--params-841.5M--tokens-926.94B--id-m97a5wxv`
- `mlstm_v1--tokenparam--ctx-8192--params-1.42B--tokens-1.56T--id-7wwry7p1`

Run from the project root with `CHECKPOINTS` exported. The new results are
written to `benchmarks/results/`:

```bash
bash benchmarks/campaigns/final-run.sh
```

After building, each benchmark entry point supports `--help`:

```bash
.venv/bin/python benchmarks/kernels/bench_mlstm_core.py --help
.venv/bin/python benchmarks/campaigns/run_thesis_campaign.py --help
.venv/bin/python benchmarks/model/bench_xlstm_model.py --help
```

## Results

Directories under `benchmarks/thesis_results/`:

- `final-operators/`: Operator timings and model configuration selection.
- `final-validation/`: Operator numerical validation.
- `model-841M-default-cell/`: 841M cell scope, FTZ/DAZ off, one and sixteen threads.
- `model-841M-default-full/`: 841M full model and in-model cell pass, FTZ/DAZ off, one and sixteen threads.
- `model-841M-ftz/`: 841M cell scope, full model and in-model pass, FTZ/DAZ on.
- `model-841M-compiled/`: 841M official compiled against Col-TBlock2 eager, FTZ/DAZ on.
- `model-841M-sweep-native1/`: 841M with Col-TBlock2 on one thread, surrounding model on sixteen, FTZ/DAZ off.
- `model-142B-default/`: 1.42B long prefill, FTZ/DAZ off.
- `model-142B-ftz/`: 1.42B long prefill, FTZ/DAZ on.

## Kernel names

| Thesis label | Kernel ID or configuration |
| --- | --- |
| Scalar | `scalar_c_rm_reference` |
| CompilerVec | `compiler_c_rm` |
| CompilerVec fast-math | `compiler_fastmath_c_rm` |
| Row1 | `avx2_c_rm_fused_r1` |
| Row1 row-split, Row1 two-pass | `avx2_c_rm_rowsplit_r1`, `avx2_c_rm_twopass_r1` |
| Row2 | `avx2_c_rm_fused_r2` |
| Row4 | `avx2_c_rm_fused_r4` |
| Row-TBlock4 | `avx2_c_rm_fused_r4_tb4` |
| Col-TBlock2 | `avx2_c_t_fused_r16_bhtd` |
| Col, ColFull | `avx2_c_t_fused_r16_bhtd_unblocked`, `avx2_c_t_fused_r16_bhtd_unblocked:nokb` |
| ColPanel | `recurrent_avx2_panelwise_bhtd` |
| Chunk4, Chunk8 | `chunkwise_avx2_bhtd:4`, `chunkwise_avx2_bhtd:8` |
| BLAS32 | `chunkwise_blas_bhtd:32` |
| Split-state variants | `avx2_c_t_fused_r16_bhtd:split`, `chunkwise_avx2_bhtd:4:split`, `chunkwise_avx2_bhtd:8:split` |
| Key-block variants | `avx2_c_t_fused_r16_bhtd:kb4`, `:kb16`, `:kb32`, `:nokb`; `chunkwise_avx2_bhtd:4:kb4`, `:4:kb16`, `:4:kb32`, `:4:nokb` |
| Official backend | `official:eager`, `official:compiled` |
