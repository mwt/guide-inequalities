import numpy as np
from scipy.special import ndtri

# "cimport" is used to import special compile-time information
# about the numpy module (this is stored in a file numpy.pxd which is
# currently part of the Cython distribution).
cimport numpy as np

# It's necessary to call "import_array" if you use any part of the
# numpy PyArray_* API. From Cython 3, accessing attributes like
# ".shape" on a typed Numpy array use this API. Therefore we recommend
# always calling "import_array" whenever you "cimport numpy"
np.import_array()


def base_SN(n: int, k: int, alpha: float) -> float:
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


def cvalue_SN(X_data: np.ndarray, alpha: float) -> float:
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


def cvalue_SN2S(X_data: np.ndarray, alpha: float, beta: float | None = None) -> float:
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


def cvalue_EB2S(
    X_data: np.ndarray,
    BB: int,
    alpha: float,
    beta: float | None = None,
    rng_seed: int | None = None,
) -> float:
    """Calculate the c-value for the EB2S test statistic defined in eq (48) of
    Section 5 in Canay, Illanes, and Velez (2023)

    Parameters
    ----------
    X_data : array_like
        Matrix of the moment functions with n rows (output of
        :func:`ineq_functions.m_function`).
    BB : int
        Number of bootstrap replications.
    alpha : float
        Significance level for the first stage test.
    beta : float, default: alpha / 50
        Significance level for the second stage test.
    rng_seed : int, optional
        Random number generator seed (for replication purposes).

    Returns
    -------
    float
        The c-value for the EB2S test statistic.
    """
    n = X_data.shape[0]  # sample size

    if beta is None:
        beta = alpha / 50

    ## Step 1: Algorithm of the Empirical Bootstrap as in Section 5.2

    # Obtain random numbers for the bootstrap
    if rng_seed is not None:
        np.random.seed(rng_seed)
    bootstrap_indices = np.random.randint(0, n, size=(BB, n))

    ## Compute the mean of each column of X_data
    mu_hat = np.mean(X_data, axis=0)
    ## Compute the standard deviation of each column of X_data
    sigma_hat = np.std(X_data, axis=0)

    X_samples = X_data[bootstrap_indices, :]

    ## Follow the steps in eq (45)
    WEB_matrix = (
        np.sqrt(n)
        * (1 / n)
        * np.sum(X_samples - mu_hat[np.newaxis, np.newaxis, :], axis=1)
        / sigma_hat[np.newaxis, :]
    )

    ## Take maximum of each sample
    WEB_vector = np.max(WEB_matrix, axis=1)

    ## Obtain quantile of bootstrap samples
    cvalue0 = np.quantile(WEB_vector, 1 - beta)

    ## Studentized statistic for each moment inequality
    test_stat0 = np.sqrt(n) * mu_hat / sigma_hat

    # Step 2: Critical value

    ## Selection of moment inequalities that are almost binding as in eq (46)
    if np.sum(test_stat0 > (-2 * cvalue0)) > 0:
        WEB_matrix2 = WEB_matrix[:, test_stat0 > (-2 * cvalue0)]
        WEB_vector2 = np.max(WEB_matrix2, axis=1)
        cvalue1 = np.quantile(WEB_vector2, 1 - alpha + 2 * beta)
    else:
        cvalue1 = 0

    return cvalue1
