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

def cvalue_EB2S(*args):
    args = [robjects.NULL if x is None else x for x in args]
    with np_cv_rules.context():
        return R.cvalue_EB2S(*args)
    
def cvalue_SN2S(*args):
    args = [robjects.NULL if x is None else x for x in args]
    with np_cv_rules.context():
        return R.cvalue_SN2S(*args)
    
def cvalue_SN(*args):
    args = [robjects.NULL if x is None else x for x in args]
    with np_cv_rules.context():
        return R.cvalue_SN(*args)

def G_restriction(*args):
    args = [robjects.NULL if x is None else x for x in args]
    with np_cv_rules.context():
        return R.G_restriction(*args)

def m_function(*args):
    args = [robjects.NULL if x is None else x for x in args]
    with np_cv_rules.context():
        return R.m_function(*args)
    
def m_hat(*args):
    args = [robjects.NULL if x is None else x for x in args]
    with np_cv_rules.context():
        return R.m_hat(*args)
    
def MomentFunct_L(*args):
    args = [robjects.NULL if x is None else x for x in args]
    with np_cv_rules.context():
        return R.MomentFunct_L(*args)

def MomentFunct_U(*args):
    args = [robjects.NULL if x is None else x for x in args]
    with np_cv_rules.context():
        return R.MomentFunct_U(*args)
