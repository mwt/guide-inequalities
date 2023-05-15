import numpy as np
from scipy.special import ndtri
from .shim import R, clean_args

cvalue_EB2S = clean_args(R.cvalue_EB2S)


def base_SN(n: int, k: int, alpha: float):
    """Base function for the SN test statistic defined in eq (40) of
    Section 5 in Canay, Illanes, and Velez (2023). This function is called
    by the other cvalue functions. It is not exported. Function
    :func:`ineq_functions.cvalue.cvalue_SN` is a convenience wrapper that sets
    n and k based on the dimensions of the input matrix.

    Parameters
    ----------
    n : int
        Sample size.
    k : int
        Number of moments.
    alpha : float
        Significance level.

    Returns
    -------
    float
        The SN critical value.
    """
    # Obtain the quantile of the standard normal distribution corresponding to
    # the significance level
    z_quantile = ndtri(1 - alpha / k)

    # Compute the c-value as in eq (40)
    return z_quantile / np.sqrt(1 - z_quantile**2 / n)


def cvalue_SN(X_data: np.ndarray, alpha: float):
    """Calculate the c-value for the SN test statistic defined in eq (40) of
    Section 5 in Canay, Illanes, and Velez (2023). This is a convenience
    wrapper for :func:`ineq_functions.cvalue.base_SN` that sets n and k based
    on the dimensions of the input matrix.

    Parameters
    ----------
    X_data : array_like
        Matrix of the moment functions with n rows (output of
        :func:`ineq_functions.m_function`).
    alpha : float
        Significance level.

    Returns
    -------
    float
        The c-value for the SN test statistic.
    """
    n = X_data.shape[0]  # sample size
    k = X_data.shape[1]  # number of moments

    # Compute the c-value as in eq (40)
    return base_SN(n, k, alpha)


def cvalue_SN2S(X_data: np.ndarray, alpha: float, beta: float | None = None):
    """Calculate the c-value for the SN2S test statistic defined in eq (41) of
    Section 5 in Canay, Illanes, and Velez (2023)

    Parameters
    ----------
    X_data : array_like
        Matrix of the moment functions with n rows (output of
        :func:`ineq_functions.m_function`).
    alpha : float
        Significance level for the first stage test.
    beta : float, default: alpha / 50
        Significance level for the second stage test.

    Returns
    -------
    float
        The c-value for the SN2S test statistic.
    """
    n = X_data.shape[0]  # sample size

    if beta is None:
        beta = alpha / 50

    # Step 1: define set J_SN as almost binding
    ## Run the first stage from cvalue_SN
    cvalue0 = cvalue_SN(X_data, alpha)

    ## Compute the mean of each column of X_data
    mu_hat = np.mean(X_data, axis=0)
    ## Compute the standard deviation of each column of X_data
    sigma_hat = np.std(X_data, axis=0)

    ## Studentized statistic for each moment inequality
    test_stat0 = np.sqrt(n) * mu_hat / sigma_hat

    ## Number of moment inequalities that are almost binding as in eq (39)
    k_hat = np.sum(test_stat0 > (-2 * cvalue0))

    # Step 2: calculate critical value using a subset of moment inequalities
    if k_hat > 0:
        cvalue1 = base_SN(n, k_hat, alpha - 2 * beta)  # as in eq (41)
    else:
        cvalue1 = 0

    return cvalue1
