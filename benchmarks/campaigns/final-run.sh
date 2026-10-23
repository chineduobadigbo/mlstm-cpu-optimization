#!/usr/bin/env bash
# Script that produced the final results; run serially and stop on the first failure.
set -euo pipefail
cd "$(dirname "$0")/../.."
step() { echo "=== $(date -u +%FT%TZ) STEP $*"; }

step "6 git status / clean build"
test -z "$(git status --short)" || { echo "working tree not clean"; exit 1; }
rm -rf build
env -u CFLAGS -u CXXFLAGS -u CPPFLAGS -u LDFLAGS -u CC -u CXX MAX_JOBS=4 \
  .venv/bin/python setup.py build_ext --inplace --force -v 2>&1 \
  | tee benchmarks/results/final-build.log > /dev/null

step "6 disassembly"
for lib in mlstm_cpu/_C.*.so mlstm_cpu/_C_fastmath.*.so; do
  for sym in $(nm "$lib" | awk '$2 == "T" && /mlstm_core_sequence_(scalar_c_rm_reference|compiler_c_rm|compiler_fastmath_c_rm|avx2_c_rm_fused_r1)/ {print $3}'); do
    objdump -d -l -M intel --no-show-raw-insn --disassemble="$sym" "$lib"
  done
done | c++filt | sed "s|$PWD/||g" > benchmarks/results/final-disassembly.asm
for k in scalar_c_rm_reference compiler_c_rm compiler_fastmath_c_rm avx2_c_rm_fused_r1; do
  n=$(grep -c "mlstm_core_sequence_${k}.*>:$" benchmarks/results/final-disassembly.asm || true)
  echo "disassembly symbols for $k: $n"
  [ "$n" -ge 1 ] || { echo "missing disassembly for $k"; exit 1; }
done

step "7 clear Inductor cache"
rm -rf "${TORCHINDUCTOR_CACHE_DIR:-$(.venv/bin/python -c 'import tempfile; print(tempfile.gettempdir())')/torchinductor_$USER}"

CPUS=0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
step "dry run"
.venv/bin/python benchmarks/campaigns/run_thesis_campaign.py \
  --physical-cpus "$CPUS" --dry-run --output-dir benchmarks/results/final-plan

step "8 V (validate-only)"
.venv/bin/python benchmarks/campaigns/run_thesis_campaign.py \
  --physical-cpus "$CPUS" --validate-only --output-dir benchmarks/results/final-validation
.venv/bin/python - <<'EOF'
import json
c = json.load(open("benchmarks/results/final-validation/campaign.json"))
bad_runs = [r for r in c["runs"] if r["status"] != "ok"]
bad_recs = [r for r in c["records"] if r["correctness"] != "passed"]
print(f"V: {len(c['runs'])} workers, {len(bad_runs)} not ok; {len(c['records'])} records, {len(bad_recs)} not passed")
raise SystemExit(1 if bad_runs or bad_recs else 0)
EOF

step "9 operator timing"
.venv/bin/python benchmarks/campaigns/run_thesis_campaign.py \
  --physical-cpus "$CPUS" --output-dir benchmarks/results/final-operators

step "10 selection"
.venv/bin/python benchmarks/campaigns/select_model_configuration.py \
  benchmarks/results/final-operators

step "11 model runs"
CK841=$CHECKPOINTS/mlstm_v1--tokenparam--ctx-8192--params-841.5M--tokens-926.94B--id-m97a5wxv
CK142=$CHECKPOINTS/mlstm_v1--tokenparam--ctx-8192--params-1.42B--tokens-1.56T--id-7wwry7p1
SELECTION=benchmarks/results/final-operators/model_selection.json
C841=$(.venv/bin/python -c "import json, sys; print(json.load(open(sys.argv[1]))['model_841M']['choice'])" "$SELECTION")
C142=$(.venv/bin/python -c "import json, sys; print(json.load(open(sys.argv[1]))['model_142B']['choice'])" "$SELECTION")
echo "selection: 841M=$C841 1.42B=$C142"
RUN=".venv/bin/python benchmarks/model/bench_xlstm_model.py run --physical-cpus $CPUS"
step "11a M-default cell";  $RUN --checkpoint $CK841 --kernel $C841 --scopes adapter_core --threads 1 all --output benchmarks/results/model-841M-default-cell
step "11b M-default full";  $RUN --checkpoint $CK841 --kernel $C841 --scopes full_model --threads 1 all --in-model-cells --output benchmarks/results/model-841M-default-full
step "11c M-FTZ";           $RUN --checkpoint $CK841 --kernel $C841 --scopes adapter_core full_model --threads all --fp-policy ftz_daz --in-model-cells --output benchmarks/results/model-841M-ftz
step "11d M-compiled";      $RUN --checkpoint $CK841 --kernel $C841 --scopes full_model --threads all --fp-policy ftz_daz --official-execution-mode compiled --local-execution-mode eager --output benchmarks/results/model-841M-compiled
step "11e M1 default";      $RUN --checkpoint $CK142 --kernel $C142 --prefill-only 1024 --scopes adapter_core full_model --threads all --in-model-cells --output benchmarks/results/model-142B-default
step "11f M1 FTZ";          $RUN --checkpoint $CK142 --kernel $C142 --prefill-only 1024 --scopes adapter_core full_model --threads all --fp-policy ftz_daz --in-model-cells --output benchmarks/results/model-142B-ftz
SWEEP=$(.venv/bin/python -c "
import json, sys
records = json.load(open(sys.argv[1]))['records']
decode = [r for r in records if (r['scope'], r['workload'], r['threads']) == ('full_model', 'decode', 16)]
print(len(decode) == 8 and all(r['baseline_ms'] < r['candidate_ms'] for r in decode)
      and not sys.argv[2].startswith('chunkwise_blas'))
" benchmarks/results/model-841M-default-full/results.json "$C841")
echo "M-sweep triggered: $SWEEP"
if [ "$SWEEP" = True ]; then
  step "11g M-sweep"
  $RUN --checkpoint $CK841 --kernel $C841 --scopes full_model --threads all --native-threads 1 --in-model-cells --output benchmarks/results/model-841M-sweep-native1
fi

step "12 completeness check"
.venv/bin/python - <<'EOF'
import glob, json
R = "benchmarks/results"
def check(label, ok):
    print(("ok       " if ok else "PROBLEM  ") + label)
for d, workers, records in (("final-validation", 134, 1338), ("final-operators", 670, 3345)):
    c = json.load(open(f"{R}/{d}/campaign.json"))
    check(f"{d}: {workers} workers ok, {records} records passed",
          len(c["runs"]) == workers and all(r["status"] == "ok" for r in c["runs"])
          and len(c["records"]) == records and all(r["correctness"] == "passed" for r in c["records"]))
check("final-operators: 78 BLAS32 MKL diagnostics",
      len(glob.glob(f"{R}/final-operators/logs/*.diagnostic.txt")) == 78)
s = json.load(open(f"{R}/final-operators/model_selection.json"))
check(f"selection: 841M {s['model_841M']['choice']}, 1.42B {s['model_142B']['choice']}", True)
for d, workers, records in (("model-841M-default-cell", 32, 1920), ("model-841M-default-full", 32, 80),
                            ("model-841M-ftz", 16, 1000), ("model-841M-compiled", 16, 40),
                            ("model-142B-default", 16, 200), ("model-142B-ftz", 16, 200),
                            ("model-841M-sweep-native1", 16, 40)):
    if d.endswith("sweep-native1") and not glob.glob(f"{R}/{d}"):
        print(f"skipped  {d} (trigger did not hold)")
        continue
    try:
        r = json.load(open(f"{R}/{d}/results.json"))
    except FileNotFoundError:
        check(f"{d}: results.json missing", False)
        continue
    budgets = {x["threads"] for x in r["records"]}
    blas = r["run"]["kernel"].startswith("chunkwise_blas")
    check(f"{d}: {r['run']['configuration']}, {workers} workers, {records} records, "
          f"acceptance {r['run']['numerical_acceptance']}",
          r["run"]["pair_count"] == 8 and len(r["records"]) == records
          and len(glob.glob(f"{R}/{d}/raw/pair-*.json")) == workers
          and (not blas or len(glob.glob(f"{R}/{d}/mkl-*.log")) == len(budgets)))
EOF
step "DONE"
