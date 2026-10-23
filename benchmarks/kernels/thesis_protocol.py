"""Set campaign constants and gather diagnostics outside timed intervals."""

import ctypes
import json
import os
from pathlib import Path
import re
import subprocess

ROOT = Path(__file__).resolve().parents[2]
# Constants named after thesis labels hold kernel IDs and configuration names.
SCALAR = "scalar_c_rm_reference"
COMPILER_VEC = "compiler_c_rm"
COMPILER_VEC_FASTMATH = "compiler_fastmath_c_rm"
ROW1 = "avx2_c_rm_fused_r1"
ROW1_ROWSPLIT = "avx2_c_rm_rowsplit_r1"
ROW1_TWOPASS = "avx2_c_rm_twopass_r1"
ROW2 = "avx2_c_rm_fused_r2"
ROW4 = "avx2_c_rm_fused_r4"
ROW_TBLOCK4 = "avx2_c_rm_fused_r4_tb4"
COL_TBLOCK2 = "avx2_c_t_fused_r16_bhtd"
COL = "avx2_c_t_fused_r16_bhtd_unblocked"
COL_FULL = f"{COL}:nokb"
COL_PANEL = "recurrent_avx2_panelwise_bhtd"
CHUNK = "chunkwise_avx2_bhtd"
CHUNK4 = f"{CHUNK}:4"
CHUNK8 = f"{CHUNK}:8"
BLAS = "chunkwise_blas_bhtd"
BLAS32 = f"{BLAS}:32"
# Reuse the model benchmark's Transformers baseline through official_backend.py, with
# the 841M chunk length.
OFFICIAL = "official"
OFFICIAL_CHUNK = 64
# Environment settings read on each native BHTD call.
KERNEL_SETTINGS = ("MLSTM_THREADS", "MLSTM_CHUNK", "MLSTM_SPLIT", "MLSTM_KEY_BLOCK")
CONFIGURATIONS = {
    CHUNK4: (CHUNK, {"MLSTM_CHUNK": "4"}),
    CHUNK8: (CHUNK, {"MLSTM_CHUNK": "8"}),
    BLAS32: (BLAS, {}),
    # ColFull puts every key in one block.
    COL_FULL: (COL, {"MLSTM_KEY_BLOCK": "65536"}),
    # Request value-column splitting across threads.
    f"{COL_TBLOCK2}:split": (COL_TBLOCK2, {"MLSTM_SPLIT": "1"}),
    f"{CHUNK4}:split": (CHUNK, {"MLSTM_CHUNK": "4", "MLSTM_SPLIT": "1"}),
    f"{CHUNK8}:split": (CHUNK, {"MLSTM_CHUNK": "8", "MLSTM_SPLIT": "1"}),
    # Vary keys per block; nokb uses one block for all keys.
    f"{COL_TBLOCK2}:kb4": (COL_TBLOCK2, {"MLSTM_KEY_BLOCK": "4"}),
    f"{COL_TBLOCK2}:kb16": (COL_TBLOCK2, {"MLSTM_KEY_BLOCK": "16"}),
    f"{COL_TBLOCK2}:kb32": (COL_TBLOCK2, {"MLSTM_KEY_BLOCK": "32"}),
    f"{COL_TBLOCK2}:nokb": (COL_TBLOCK2, {"MLSTM_KEY_BLOCK": "65536"}),
    f"{CHUNK4}:kb4": (CHUNK, {"MLSTM_CHUNK": "4", "MLSTM_KEY_BLOCK": "4"}),
    f"{CHUNK4}:kb16": (CHUNK, {"MLSTM_CHUNK": "4", "MLSTM_KEY_BLOCK": "16"}),
    f"{CHUNK4}:kb32": (CHUNK, {"MLSTM_CHUNK": "4", "MLSTM_KEY_BLOCK": "32"}),
    f"{CHUNK4}:nokb": (CHUNK, {"MLSTM_CHUNK": "4", "MLSTM_KEY_BLOCK": "65536"}),
    # The suffix chooses eager or compiled execution.
    f"{OFFICIAL}:eager": (OFFICIAL, {}),
    f"{OFFICIAL}:compiled": (OFFICIAL, {}),
}
OPERATOR_ENV = dict(
    OMP_NUM_THREADS="1",
    OMP_DYNAMIC="FALSE",
    OMP_MAX_ACTIVE_LEVELS="1",
    MKL_NUM_THREADS="1",
    MKL_DOMAIN_NUM_THREADS="MKL_BLAS=1",
    MKL_DYNAMIC="FALSE",
    OPENBLAS_NUM_THREADS="1",
    MKL_VERBOSE="0",
)
# FP32 forward bounds from NX-AI/mlstm_kernels, commit 99b3677, against its parallel
# formulation: recurrent atol=rtol=1e-4; chunkwise atol=1e-4, rtol=1e-3.
RECURRENT_TOLERANCE = dict(atol=1e-4, rtol=1e-4)
CHUNKWISE_TOLERANCE = dict(atol=1e-4, rtol=1e-3)
# MXCSR flags: FTZ is bit 15 (0x8000); DAZ is bit 6 (0x0040).
# See Intel SDM sections 10.2.3, 10.2.3.3 and 10.2.3.4:
# https://cdrdv2-public.intel.com/789574/253665-sdm-vol-1.pdf
FP_POLICIES = {"default": 0, "ftz_daz": 0x8040}


def tolerance(kernel):
    """Return formulation-specific error bounds, including chunkwise bounds at T=1 for
    chunkwise, BLAS and official backends.
    """
    return (
        CHUNKWISE_TOLERANCE
        if kernel.startswith(("chunkwise", OFFICIAL))
        else RECURRENT_TOLERANCE
    )


def base_kernel(name):
    """Resolve a configuration to its kernel ID; leave kernel IDs unchanged."""
    return CONFIGURATIONS.get(name, (name, {}))[0]


def configure(name):
    """Apply a configuration's environment overrides outside timing and return its kernel ID."""
    for key in KERNEL_SETTINGS:
        if key != "MLSTM_THREADS":
            os.environ.pop(key, None)
    kernel, overrides = CONFIGURATIONS.get(name, (name, {}))
    os.environ.update(overrides)
    return kernel


def split_threads(kernel, shape, requested):
    """Match split_state_threads: return the split team size, or 0 for whole states.

    Allow at most one thread per 16 value columns and require at least two per state.
    Col and Col-TBlock2 also require Dv%16==0.
    """
    b, _, h, _, dv = shape
    states = b * h
    team = min(requested, states * ((dv + 15) // 16))
    return team if team >= 2 * states and (kernel == CHUNK or dv % 16 == 0) else 0


def predicted_path(kernel, shape, requested):
    """Predict the dispatch path from source rules without observing execution."""
    b, t, h, dk, dv = shape
    states = b * h
    result = dict(requested_threads=requested)
    if kernel == OFFICIAL:
        # Lengths 1, 16 and chunk multiples use step, sequence and chunkwise paths.
        # PyTorch is configured with the full requested thread count.
        path = "step" if t == 1 else "sequence" if t < OFFICIAL_CHUNK else "chunkwise"
        result.update(team_threads=requested, scheduling="pytorch_intra_op", path=path)
        return result
    if kernel in (COL_PANEL, BLAS):
        result.update(team_threads=min(requested, states * ((dv + 15) // 16)))
        if kernel == COL_PANEL:
            result.update(
                scheduling="state_panels", path="direct" if t == 1 else "packed"
            )
        else:
            result.update(scheduling="state_columns", path="chunk", chunk=min(t, 32))
        return result
    if kernel in (COL_TBLOCK2, COL, CHUNK):
        # MLSTM_SPLIT=1 divides value columns when split_threads permits; otherwise
        # threads take whole states.
        requested_split = int(os.environ.get("MLSTM_SPLIT", 0)) == 1
        split_team = split_threads(kernel, shape, requested) if requested_split else 0
        key_block = int(os.environ.get("MLSTM_KEY_BLOCK", dk if split_team else 8))
        result.update(
            team_threads=split_team or min(requested, states),
            requested_scheduling="split" if requested_split else "states",
            scheduling="split" if split_team else "states",
            key_block_size=min(dk, max(1, key_block)),
        )
        if kernel == CHUNK:
            chunk = min(t, max(1, min(8, int(os.environ.get("MLSTM_CHUNK", 4)))))
            result.update(path="chunk", chunk=chunk)
        else:
            result.update(
                path="two_token" if kernel == COL_TBLOCK2 and t >= 2 else "one_token"
            )
        return result
    result.update(team_threads=1, scheduling="serial")
    return result


def cpu_topology(cpus):
    """Return the lscpu JSON report plus each CPU's core ID and SMT siblings."""
    lscpu = subprocess.run(["lscpu", "-J"], check=True, capture_output=True, text=True)
    sysfs = Path("/sys/devices/system/cpu")
    return {
        "lscpu": json.loads(lscpu.stdout),
        "cpus": [
            {
                "cpu": cpu,
                "core_id": int((sysfs / f"cpu{cpu}/topology/core_id").read_text()),
                "thread_siblings_list": (
                    sysfs / f"cpu{cpu}/topology/thread_siblings_list"
                )
                .read_text()
                .strip(),
            }
            for cpu in cpus
        ],
    }


def marked_mkl_threads(text, label):
    """Extract MKL_VERBOSE NThr values between matching BEGIN/END label lines.

    Return None if no matching marker pair exists.
    """
    marker = re.escape(label)
    segments = re.findall(rf"BEGIN {marker}\n(.*?)END {marker}", text, re.S)
    if not segments:
        return None
    return sorted(
        {
            int(value)
            for segment in segments
            for value in re.findall(r"NThr:\s*(\d+)", segment)
        }
    )


def build_fp_probe(output):
    """Build the FP probe against PyTorch's OpenMP runtime."""
    import torch

    libdir = Path(torch.__file__).parent / "lib"
    runtimes = sorted(libdir.glob("libgomp*.so*"))
    if not runtimes:
        raise RuntimeError(
            "FP probe requires the extension's GNU OpenMP runtime; record unsupported host"
        )
    output = Path(output).resolve()
    output.parent.mkdir(parents=True, exist_ok=True)
    command = [
        "c++",
        "-O2",
        "-shared",
        "-fPIC",
        "-fopenmp",
        str(ROOT / "benchmarks/kernels/fp_probe.cpp"),
        str(runtimes[0]),
        "-Wl,-rpath," + str(libdir),
        "-o",
        str(output),
    ]
    subprocess.run(command, check=True, capture_output=True, text=True)
    version = subprocess.run(
        ["c++", "--version"], check=True, capture_output=True, text=True
    )
    return {"compiler": version.stdout.splitlines()[0], "openmp": runtimes[0].name}


def load_fp_probe(path, policy="default"):
    lib = ctypes.CDLL(str(Path(path).resolve()))
    lib.fp_probe.argtypes = [
        ctypes.c_int,
        ctypes.c_int,
        ctypes.POINTER(ctypes.c_uint),
        ctypes.POINTER(ctypes.c_int),
        ctypes.POINTER(ctypes.c_int),
    ]
    lib.fp_probe.restype = ctypes.c_int
    lib.allowed_cpus = (
        set(map(int, os.environ["MLSTM_BENCH_CPUS"].split(",")))
        if os.environ.get("MLSTM_BENCH_CPUS")
        else set(os.sched_getaffinity(0))
    )
    lib.policy = policy
    return lib


def fp_state(lib, threads, reset=False):
    """Check team size, affinity and FP flags; apply the policy first when reset=True."""
    flags = FP_POLICIES[lib.policy]
    csr, tids, cpus = (
        (ctypes.c_uint * threads)(),
        (ctypes.c_int * threads)(),
        (ctypes.c_int * threads)(),
    )
    actual = lib.fp_probe(threads, flags if reset else -1, csr, tids, cpus)
    if actual != threads or any(value & 0xE040 != flags for value in csr):
        raise RuntimeError(
            f"FP policy {lib.policy} requires full team, round-to-nearest "
            f"and FTZ/DAZ {'on' if flags else 'off'}"
        )
    if not set(cpus) <= lib.allowed_cpus:
        raise RuntimeError("OpenMP thread outside selected affinity")
    return dict(
        policy=lib.policy,
        observed_threads=actual,
        mxcsr=list(csr),
        tids=list(tids),
        cpus=list(cpus),
    )
