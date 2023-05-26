import numpy as np
from .moment import m_hat


def cvalue_SPUR1(
    X_data: np.ndarray,
    alpha: float,
    an_vec: np.ndarray,
    bootstrap_replications: int | None = None,
    rng_seed: int | None = None,
    bootstrap_indices: np.ndarray | None = None,
) -> float:
    """Calculate the c-value for the SPUR1 test statistic presented in
    Section 4 in Andrews and Kwon (2023).

    Parameters
    ----------
    X_data : array_like
        Matrix of the moment functions with n rows (output of
        :func:`ineq_functions.m_function`).
    alpha : float
        Significance level for the first stage test.
    an_vec : array_like
        Vector as in eq. (4.25) in Andrews and Kwon (2023).
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
        The c-value for the SPUR1 test statistic.
    """
    n = X_data.shape[0]  # sample size
    kappa_n = np.sqrt(np.log(n))  # tuning parameter

    # Step 1: Computation of Bootstrap statistic

    std_b0 = std_b_vec(X_data, bootstrap_replications, rng_seed, bootstrap_indices)
    std_b1 = std_b0[0, :]
    tn_vec = tn_star(
        X_data, std_b1, kappa_n, bootstrap_replications, rng_seed, bootstrap_indices
    )

    sn_star_vec = np.max(-1 * (tn_vec + an_vec[:, np.newaxis]).clip(max=0), axis=1)

    # Step 2: Computation of critical value
    # We use the midpoint interpolation method for consistency with MATLAB
    c_value = np.quantile(sn_star_vec, 1 - alpha, interpolation='midpoint')

    return c_value


def std_b_vec(
    X_data: np.ndarray,
    bootstrap_replications: int | None = None,
    rng_seed: int | None = None,
    bootstrap_indices: np.ndarray | None = None,
) -> np.ndarray:
    """Compute scaling factors (std_1, std_2, std_3) as in (4.19), (4.21),
    and (4.22) as in Andrews and Kwon (2023).

    Parameters
    ----------
    X_data : array_like
        Matrix of the moment functions with n rows (output of
        :func:`ineq_functions.m_function`).
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
    array_like
        Array of shape (3, k) with the scaling factors.
    """
    iota = 1e-6  # small number as in eq (4.16) and Section 4.7.1
    n = X_data.shape[0]  # sample size

    # Obtain random numbers for the bootstrap
    if bootstrap_indices is None:
        if bootstrap_replications is None:
            raise ValueError(
                "bootstrap_replications must be specified if bootstrap_indices is not."
            )
        else:
            if rng_seed is not None:
                np.random.seed(rng_seed)
            bootstrap_indices = np.random.randint(
                0, n, size=(bootstrap_replications, n)
            )

    # Axis 0 is the bootstrap replications. So we specify axis=1
    mhat_star_vec = m_hat(X_data[bootstrap_indices, :], axis=1)

    # Get repeated terms
    mhat_star_clip = mhat_star_vec.clip(max=0)
    mn_star_vec = np.min(mhat_star_clip, axis=1)

    # Compute the scaling factors to be clipped below at iota
    vec_1 = np.sqrt(n) * (mhat_star_vec - mn_star_vec[:, np.newaxis])
    vec_2 = np.sqrt(n) * mhat_star_vec
    vec_3 = np.sqrt(n) * (mn_star_vec[:, np.newaxis] - mhat_star_clip)

    std_b = np.vstack(
        (
            np.std(vec_1, axis=0).clip(min=iota),
            np.std(vec_2, axis=0).clip(min=iota),
            np.std(vec_3, axis=0).clip(min=iota),
        )
    )

    return std_b


def tn_star(
    X_data: np.ndarray,
    std_b1: np.ndarray,
    kappa_n: float,
    bootstrap_replications: int | None = None,
    rng_seed: int | None = None,
    bootstrap_indices: np.ndarray | None = None,
) -> np.ndarray:
    """Compute the tn* statistic as in (4.24) as in Andrews and Kwon (2023).

    Parameters
    ----------
    X_data : array_like
        Matrix of the moment functions with n rows (output of
        :func:`ineq_functions.m_function`).
    std_b1 : array_like
        Array of shape (1, k, 1) with the first scaling factor.
    kappa_n : float
        Tuning parameter as in (4.23).
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
    array_like
        Array of shape (bootstrap_replications, k) with the tn* statistics.
    """
    n = X_data.shape[0]  # sample size

    # Obtain random numbers for the bootstrap
    if bootstrap_indices is None:
        if bootstrap_replications is None:
            raise ValueError(
                "bootstrap_replications must be specified if bootstrap_indices is not."
            )
        else:
            if rng_seed is not None:
                np.random.seed(rng_seed)
            bootstrap_indices = np.random.randint(
                0, n, size=(bootstrap_replications, n)
            )

    m_hat0 = m_hat(X_data)
    r_hat_vec = -1 * m_hat0.clip(max=0)
    r_hat = np.max(r_hat_vec)

    xi_n = (np.sqrt(n) * (m_hat0 + r_hat)) / (std_b1 * kappa_n)
    phi_n = np.zeros_like(xi_n)
    phi_n[xi_n > 1] = np.inf

    # Combining (4.17) and (4.18) from Andrews and Kwon (2023)
    tn_star_vec = (
        np.sqrt(n) * (m_hat(X_data[bootstrap_indices, :], axis=1) - m_hat0) + phi_n
    )

    return tn_star_vec
