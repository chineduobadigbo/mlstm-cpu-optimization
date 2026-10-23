"""Select local model configurations from operator timings.

L(c, T, p) is the median of process medians for configuration c, sequence length T and
p threads.

For 841M, consider native configurations timed at T=256 and (B,H,Dk,Dv)=(1,4,192,384).
Minimize W_1 * W_max, where W_p(c) = L(c, 256, p) + 128 * L(dec(c), 1, p) and max is the
largest thread count. dec(c) replaces Chunk8 with Chunk4, whose single-token decode is
identical.

For 1.42B, choose the native configuration with the lowest L at
(B,T,H,Dk,Dv)=(1,1024,4,256,512) and the largest thread count.

Use whole-state measurements when a split request falls back to whole states, including
p=1.
"""

import argparse
import json
from pathlib import Path
import statistics
import sys

ROOT = Path(__file__).resolve().parents[2]
if __package__ in (None, ""):
    sys.path.insert(0, str(ROOT))
from benchmarks.kernels import thesis_protocol as protocol
from benchmarks.model.xlstm_model_constants import DECODE_STEPS, PREFILL_LENGTH

PREFILL_841M = (1, PREFILL_LENGTH, 4, 192, 384)
DECODE_841M = (1, 1, 4, 192, 384)
PREFILL_142B = (1, 1024, 4, 256, 512)


def latency_table(campaign):
    """Map (configuration, shape, threads) to the median of process medians and repeat count."""
    samples = {}
    for row in campaign["records"]:
        if row["run_status"] == "ok" and not row["configuration"].startswith(
            protocol.OFFICIAL
        ):
            key = (row["configuration"], tuple(row["shape"]), row["threads"])
            samples.setdefault(key, []).append(row["median_ms"])
    return {
        key: (statistics.median(values), len(values)) for key, values in samples.items()
    }


def select(campaign):
    table = latency_table(campaign)
    largest = max(campaign["metadata"]["threads"])
    used = {}

    def latency(configuration, shape, threads):
        key = (configuration, shape, threads)
        split = configuration.endswith(":split")
        if (
            key not in table
            and split
            and not protocol.split_threads(
                protocol.base_kernel(configuration), shape, threads
            )
        ):
            key = (configuration.removesuffix(":split"), shape, threads)
        median, count = table[key]
        used[key] = dict(
            configuration=key[0],
            shape=list(shape),
            threads=threads,
            latency_ms=median,
            n=count,
        )
        return median

    candidates = {}
    for configuration in sorted({c for c, shape, _ in table if shape == PREFILL_841M}):
        decode = configuration.replace(protocol.CHUNK8, protocol.CHUNK4)
        work = [
            latency(configuration, PREFILL_841M, threads)
            + DECODE_STEPS * latency(decode, DECODE_841M, threads)
            for threads in (1, largest)
        ]
        candidates[configuration] = dict(
            decode=decode, W_1=work[0], W_max=work[1], product=work[0] * work[1]
        )
    long_prefill = {
        c: latency(c, PREFILL_142B, threads)
        for c, shape, threads in table
        if shape == PREFILL_142B and threads == largest
    }
    return {
        "largest_threads": largest,
        "model_841M": {
            "rule": "argmin W_1*W_max with W_p(c) = L(c, T=256, p) + 128*L(dec(c), T=1, p)",
            "candidates": candidates,
            "choice": min(candidates, key=lambda c: candidates[c]["product"]),
        },
        "model_142B": {
            "rule": "argmin L(c, (1,1024,4,256,512), largest thread count)",
            "candidates": long_prefill,
            "choice": min(long_prefill, key=long_prefill.get),
        },
        "latencies": sorted(
            used.values(),
            key=lambda row: (row["configuration"], row["shape"], row["threads"]),
        ),
    }


def main():
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument(
        "campaign_dir", type=Path, help="operator campaign output directory"
    )
    args = parser.parse_args()
    campaign = json.loads(
        (args.campaign_dir / "campaign.json").read_text(encoding="utf-8")
    )
    selection = select(campaign)
    output = args.campaign_dir / "model_selection.json"
    output.write_text(json.dumps(selection, indent=2) + "\n", encoding="utf-8")
    choice = selection["model_841M"]["choice"]
    work = selection["model_841M"]["candidates"][choice]
    print(
        f"841M: {choice} (W_1={work['W_1']:.4g} ms, W_{selection['largest_threads']}="
        f"{work['W_max']:.4g} ms)"
    )
    choice = selection["model_142B"]["choice"]
    print(f"1.42B: {choice} ({selection['model_142B']['candidates'][choice]:.4g} ms)")
    print(f"wrote {output}")


if __name__ == "__main__":
    main()
