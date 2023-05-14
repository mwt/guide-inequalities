from pathlib import Path
import rpy2.robjects as robjects
from rpy2.robjects import numpy2ri
from rpy2.robjects import default_converter

r_shim_path = (Path(__file__).resolve().parent / "shim.R").as_posix()

# Load the R functions into an R session.
R = robjects.r
R.source(r_shim_path)

# Create a converter that starts with rpy2's default converter
# to which the numpy conversion rules are added.
np_cv_rules = default_converter + numpy2ri.converter


def clean_args(f):
    """
    This decorator cleans the arguments before passing them to the R function.
    """

    def inner_func(*args, **kwargs):
        with np_cv_rules.context():
            return f(*args, **kwargs)

    return inner_func
