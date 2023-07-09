import numpy as np
from scipy.special import ndtri

from .helpers import get_bootstrap_indices


def base_sn(n: int, k: int, alpha: float) -> float:
    """Base function for the SN test statistic defined in eq (41) of
    Section 5 in Canay, Illanes, and Velez (2023). This function is called
    by the other cvalue functions. It is not exported. Function
    :func:`ineq_functions.cvalue.cvalue_sn` is a convenience wrapper that sets
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

    # Compute the c-value as in eq (41)
    return z_quantile / np.sqrt(1 - z_quantile**2 / n)


def cvalue_sn(x_data: np.ndarray, alpha: float) -> float:
    """Calculate the c-value for the SN test statistic defined in eq (40) of
    Section 5 in Canay, Illanes, and Velez (2023). This is a convenience
    wrapper for :func:`ineq_functions.cvalue.base_sn` that sets n and k based
    on the dimensions of the input matrix.

    Parameters
    ----------
    x_data : array_like
        Matrix of the moment functions with n rows (output of
        :func:`ineq_functions.m_function`).
    alpha : float
        Significance level.

    Returns
    -------
    float
        The c-value for the SN test statistic.
    """
    n = x_data.shape[0]  # sample size
    k = x_data.shape[1]  # number of moments

    # Compute the c-value as in eq (41)
    return base_sn(n, k, alpha)


def cvalue_sn2s(x_data: np.ndarray, alpha: float, beta: float | None = None) -> float:
    """Calculate the c-value for the SN2S test statistic defined in eq (42) of
    Section 5 in Canay, Illanes, and Velez (2023).

    Parameters
    ----------
    x_data : array_like
        n x k matrix of the moment functions with n rows (output of
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
    n = x_data.shape[0]  # sample size
    k = x_data.shape[1]  # number of moments

    if beta is None:
        beta = alpha / 50

    # Step 1: define set J_sn as almost binding
    ## Run the first stage from cvalue_sn
    cvalue0 = base_sn(n, k, beta)

    ## Compute the mean of each column of x_data
    mu_hat = x_data.mean(axis=0)
    ## Compute the standard deviation of each column of x_data
    sigma_hat = x_data.std(axis=0)

    ## Studentized statistic for each moment inequality
    test_stat0 = np.sqrt(n) * mu_hat / sigma_hat

    ## Number of moment inequalities that are almost binding as in eq (40)
    k_hat = (test_stat0 > (-2 * cvalue0)).sum()

    # Step 2: calculate critical value using a subset of moment inequalities
    if k_hat > 0:
        return base_sn(n, k_hat, alpha - 2 * beta)  # as in eq (42)
    else:
        return 0


def cvalue_eb2s(
    x_data: np.ndarray,
    alpha: float,
    beta: float | None = None,
    bootstrap_replications: int | None = None,
    rng_seed: int | None = None,
    bootstrap_indices: np.ndarray | None = None,
) -> float:
    """Calculate the c-value for the EB2S test statistic defined in eq (49) of
    Section 5 in Canay, Illanes, and Velez (2023).

    Parameters
    ----------
    x_data : array_like
        n x k matrix of the moment functions with n rows (output of
        :func:`ineq_functions.m_function`).
    alpha : float
        Significance level for the first stage test.
    beta : float, default: alpha / 50
        Significance level for the second stage test.
    bootstrap_replications : int, optional
        Number of bootstrap replications. Required if bootstrap_indices
        is not specified.
    rng_seed : int, optional
        Random number generator seed (for replication purposes). If not
        specified, the system seed will be used as-is.
    bootstrap_indices : array_like, optional
        Integer array of shape (bootstrap_replications, n) for the bootstrap
        replications. If this is specified, bootstrap_replications and rng_seed
        will be ignored. If this is not specified, bootstrap_replications is
        required.

    Returns
    -------
    float
        The c-value for the EB2S test statistic.
    """
    n = x_data.shape[0]  # sample size

    if beta is None:
        beta = alpha / 50

    ## Step 1: Algorithm of the Empirical Bootstrap as in Section 5.2

    # Obtain random numbers for the bootstrap
    bootstrap_indices = get_bootstrap_indices(
        n, bootstrap_replications, rng_seed, bootstrap_indices
    )

    ## Compute the mean of each column of x_data
    mu_hat = x_data.mean(axis=0)
    ## Compute the standard deviation of each column of x_data
    sigma_hat = x_data.std(axis=0)

    x_samples = x_data[bootstrap_indices, :]

    ## Follow the steps in eq (46)
    web_matrix = (
        np.sqrt(n)
        * (1 / n)
        * (x_samples - mu_hat[np.newaxis, np.newaxis, :]).sum(axis=1)
        / sigma_hat[np.newaxis, :]
    )

    ## Take maximum of each sample
    web_vector = web_matrix.max(axis=1)

    ## Obtain quantile of bootstrap samples
    cvalue0 = np.quantile(web_vector, 1 - beta)

    ## Studentized statistic for each moment inequality
    test_stat0 = np.sqrt(n) * mu_hat / sigma_hat

    # Step 2: Critical value

    ## Selection of moment inequalities that are almost binding as in eq (47)
    almost_binding = test_stat0 > (-2 * cvalue0)
    if np.any(almost_binding):
        web_matrix2 = web_matrix[:, almost_binding]
        web_vector2 = web_matrix2.max(axis=1)
        # We use the midpoint interpolation method for consistency with MATLAB
        return np.quantile(web_vector2, 1 - alpha + 2 * beta, interpolation="midpoint")
    else:
        return 0
