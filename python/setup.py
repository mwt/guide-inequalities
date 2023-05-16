from pathlib import Path

from setuptools import setup
from Cython.Build import cythonize

ineq_functions_path = Path(__file__).resolve().parent / "ineq_functions"

module_files = [ineq_functions_path / "cvalue.pyx", ineq_functions_path / "moment.pyx"]
module_files = [str(i) for i in module_files]

setup(
    ext_modules=cythonize(
        module_files,
        compiler_directives={"language_level": "3"},
    )
)
