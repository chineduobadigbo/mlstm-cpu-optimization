from glob import glob
from pathlib import Path

from setuptools import find_packages, setup
from torch.utils.cpp_extension import BuildExtension, CppExtension

ROOT = Path(__file__).parent.resolve()

sources = sorted(glob("csrc/dispatch/*.cpp") + glob("csrc/kernels/*.cpp"))
include_dirs = [str(ROOT / "csrc" / "include")]
compile_args = ["-O3", "-std=c++17", "-mavx2", "-mfma", "-fopenmp"]

setup(
    name="mlstm_cpu",
    version="0.1.0",
    description="CPU inference kernels for the mLSTM memory core",
    packages=find_packages(),
    ext_modules=[
        CppExtension(
            name="mlstm_cpu._C",
            sources=sources,
            include_dirs=include_dirs,
            extra_compile_args={"cxx": compile_args},
            extra_link_args=["-fopenmp"],
        ),
        # Build fast-math in a separate extension. Omit -ffast-math when linking: GCC
        # would add crtfastmath.o, enabling FTZ/DAZ on the loading thread and affecting
        # later computations.
        CppExtension(
            name="mlstm_cpu._C_fastmath",
            sources=sorted(glob("csrc/*/fastmath/*.cpp")),
            include_dirs=include_dirs,
            extra_compile_args={"cxx": [*compile_args, "-ffast-math"]},
            extra_link_args=["-fopenmp"],
        ),
    ],
    cmdclass={"build_ext": BuildExtension},
)
