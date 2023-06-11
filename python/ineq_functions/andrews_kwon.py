import numpy as np

from .moment import m_function, m_hat


def rhat(
    w_data: np.ndarray,
    a_matrix: np.ndarray,
    theta: np.ndarray,
    j0_vector: np.ndarray,
    v_bar: float,
    iv_matrix: np.ndarray | None = None,
    grid0: int | str = "all",
    adjust: np.ndarray = np.array([0]),
) -> float:
    """Find the points of the rhat vector as in Andrews and Kwon (2023)

    Parameters
    ----------
    w_data : array_like
        n x j0 matrix of product portfolio.
    a_matrix : array_like
        n x (j0 + 1) matrix of estimated revenue differentials.
    theta : array_like
        d_theta x 1 parameter of interest.
    j0_vector : array_like
        j0 x 2 matrix of ownership by two firms.
    v_bar : float
        Tuning parameter as in Assumption 4.2
    iv_matrix : array_like, optional
        n x d_IV matrix of instruments or None if no instruments are used.
    grid0 : {1, 2, 'all'}, default='all'
        Grid direction to use for the estimation of the model.
    adjust : array_like, optional
        Adjustment to the m_hat vector. Default is 0.

    Returns
    -------
    float
        Value of rhat for a given parameter theta.
    """
    # note we use -m_function
    x_data = -1 * m_function(
        theta, w_data, a_matrix, j0_vector, v_bar, grid0, iv_matrix
    )
    m_hat0 = m_hat(x_data)
    return -1 * (m_hat0 + adjust).clip(max=0).min()


def compute_an_vec(
    aux1_var: np.ndarray,
    hat_r_inf: float,
    w_data: np.ndarray,
    a_matrix: np.ndarray,
    theta_grid: np.ndarray,
    j0_vector: np.ndarray,
    v_bar: float,
    iv_matrix,
    grid0: int,
    bootstrap_replications: int | None = None,
    rng_seed: int | None = None,
    bootstrap_indices: np.ndarray | None = None,
) -> np.ndarray:
    """Find the infimum An star as in Andrews and Kwon (2023)

    Parameters
    ----------
    aux1_var : array_like
        Vector of auxiliary variables with dimension n.
    hat_r_inf : float
        Value of rhat at the parameter of interest.
    w_data : array_like
        n x j0 matrix of product portfolio.
    a_matrix : array_like
        n x (j0 + 1) matrix of estimated revenue differentials.
    theta_grid : array_like
        Grid of parameter values to search. The value will be set at the index
        of theta corresponding to `grid0`. Other dimensions will be set to 0.
    j0_vector : array_like
        j0 x 2 matrix of ownership by two firms.
    v_bar : float
        Tuning parameter as in Assumption 4.2
    iv_matrix : array_like, optional
        n x d_IV matrix of instruments or None if no instruments are used.
    grid0 : {1, 2}
        Grid direction to use for the estimation of the model.
    bootstrap_replications : int, optional
        Number of bootstrap replications to use. If None, then bootstrap_indices must be
        specified.
    rng_seed : int, optional
        Seed for the random number generator.
    bootstrap_indices : array_like, optional
        n x bootstrap_replications matrix of bootstrap indices. If None, then
        bootstrap_replications must be specified.

    Returns
    -------
    array_like
        Vector of An star values with dimension bootstrap_replications.
    """
    n = a_matrix.shape[0]
    tau_n = np.sqrt(np.log(n))
    kappa_n = np.sqrt(np.log(n))

    boole_of_interest = (aux1_var <= tau_n / np.sqrt(n)) | (aux1_var == 1)
    theta_of_interest = theta_grid[boole_of_interest]

    # Obtain number of bootstrap replications
    if bootstrap_indices is not None:
        BB = bootstrap_indices.shape[0]
    elif bootstrap_replications is not None:
        BB = bootstrap_replications
    else:
        raise ValueError(
            "Either bootstrap_replications or bootstrap_indices must be specified."
        )

    # Initialize matrix to store results
    an_mat = np.zeros((BB, theta_of_interest.shape[0]))

    for i, t in enumerate(theta_of_interest):
        the_theta = np.zeros(2)
        the_theta[grid0 - 1] = t

        x_data = -1 * m_function(
            the_theta, w_data, a_matrix, j0_vector, v_bar, grid0, iv_matrix
        )
        b0_vec = std_b_vec(x_data, bootstrap_replications, rng_seed, bootstrap_indices)
        std_b2 = b0_vec[1, :]
        std_b3 = b0_vec[2, :]
        an_mat[:, i] = an_star(
            x_data,
            std_b2,
            std_b3,
            kappa_n,
            hat_r_inf,
            bootstrap_replications,
            rng_seed,
            bootstrap_indices,
        )

    return an_mat.min(axis=1)


def an_star(
    x_data: np.ndarray,
    std_b2: np.ndarray,
    std_b3: np.ndarray,
    kappa_n: float,
    hat_r_inf: float,
    bootstrap_replications: int | None = None,
    rng_seed: int | None = None,
    bootstrap_indices: np.ndarray | None = None,
) -> np.ndarray:
    """Computes the objective function that appears in inf problem defined in
    eq. (4.25) in Andrews and Kwon (2023).

    Parameters
    ----------
    x_data : array_like
        n x k matrix of the moment functions with n rows (output of
        :func:`ineq_functions.m_function`).
    std_b2 : array_like
        Vector of scaling factors as in eq. (4.21) of Andrews and Kwon (2023).
        (second column of output of :func:`ineq_functions.std_b_vec`).
    std_b3 : array_like
        Vector of scaling factors as in eq. (4.22) of Andrews and Kwon (2023).
        (third column of output of :func:`ineq_functions.std_b_vec`).
    kappa_n : float
        Tuning parameter as in (4.20) of Andrews and Kwon (2023).
    hat_r_inf : float
        Estimator of the minimal relaxation of the moment ineq. as in (4.4) in
        Andrews and Kwon (2023) (min of output of :func:`ineq_functions.r_hat`).

    Returns
    -------
    array_like
        Vector of An star values with dimension bootstrap_replications.
    """
    n = x_data.shape[0]

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

    # Step 1: Obtain hat_j_r(theta) as in (4.24) in Andrews and Kwon (2023)
    m_hat0 = m_hat(x_data)
    r_hat_vec = -1 * (m_hat0).clip(max=0)
    r_hat0 = r_hat_vec.max()

    # Obtain set of indicies for which this inequality holds
    hat_j_r = (r_hat_vec >= r_hat0 - std_b3 * kappa_n / np.sqrt(n)).nonzero()[0]

    # Step 2: Compute the objective function
    hat_b = np.sqrt(n) * (r_hat_vec - hat_r_inf) - std_b3 * kappa_n
    xi_a = (np.sqrt(n) * (r_hat_vec - hat_r_inf)) / (std_b3 * kappa_n)

    phi_n = np.zeros_like(xi_a)
    phi_n[xi_a > 1] = np.inf

    # Use the bootstrap
    vstar = np.sqrt(n) * (m_hat(x_data[bootstrap_indices, :], axis=1) - m_hat0)

    # Obtain plus-minus variable based on sign of vstar (negative if vstar >= 0)
    pm = 1 - 2 * (vstar >= 0)

    hat_hi_star = (
        -1 * (np.sqrt(n) * m_hat0 + pm * std_b2 * kappa_n + vstar).clip(max=0)
    ) - (-1 * (np.sqrt(n) * m_hat0 + pm * std_b2 * kappa_n).clip(max=0))

    aux_vec2 = np.zeros((vstar.shape[0], hat_j_r.shape[0]))

    for i, j in enumerate(hat_j_r):
        hat_bnew = hat_b.copy()
        hat_bnew[j] = phi_n[j]
        aux_vec2[:, i] = (hat_bnew + hat_hi_star).max(axis=1)

    return aux_vec2.min(axis=1)


def cvalue_spur1(
    x_data: np.ndarray,
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
    x_data : array_like
        n x k matrix of the moment functions with n rows (output of
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
    n = x_data.shape[0]  # sample size
    kappa_n = np.sqrt(np.log(n))  # tuning parameter

    # Step 1: Computation of Bootstrap statistic

    std_b0 = std_b_vec(x_data, bootstrap_replications, rng_seed, bootstrap_indices)
    std_b1 = std_b0[0, :]
    tn_vec = tn_star(
        x_data, std_b1, kappa_n, bootstrap_replications, rng_seed, bootstrap_indices
    )

    sn_star_vec = -1 * (tn_vec + an_vec[:, np.newaxis]).clip(max=0).min(axis=1)

    # Step 2: Computation of critical value
    # We use the midpoint interpolation method for consistency with MATLAB
    c_value = np.quantile(sn_star_vec, 1 - alpha, interpolation="midpoint")

    return c_value


def std_b_vec(
    x_data: np.ndarray,
    bootstrap_replications: int | None = None,
    rng_seed: int | None = None,
    bootstrap_indices: np.ndarray | None = None,
) -> np.ndarray:
    """Compute scaling factors (std_1, std_2, std_3) as in (4.19), (4.21),
    and (4.22) as in Andrews and Kwon (2023).

    Parameters
    ----------
    x_data : array_like
        n x k matrix of the moment functions with n rows (output of
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
    n = x_data.shape[0]  # sample size

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
    mhat_star_vec = m_hat(x_data[bootstrap_indices, :], axis=1)

    # Get repeated terms
    mhat_star_clip = mhat_star_vec.clip(max=0)
    mn_star_vec = mhat_star_clip.min(axis=1)

    # Compute the scaling factors to be clipped below at iota
    vec_1 = np.sqrt(n) * (mhat_star_vec - mn_star_vec[:, np.newaxis])
    vec_2 = np.sqrt(n) * mhat_star_vec
    vec_3 = np.sqrt(n) * (mn_star_vec[:, np.newaxis] - mhat_star_clip)

    std_b = np.vstack(
        (
            vec_1.std(axis=0).clip(min=iota),
            vec_2.std(axis=0).clip(min=iota),
            vec_3.std(axis=0).clip(min=iota),
        )
    )

    return std_b


def tn_star(
    x_data: np.ndarray,
    std_b1: np.ndarray,
    kappa_n: float,
    bootstrap_replications: int | None = None,
    rng_seed: int | None = None,
    bootstrap_indices: np.ndarray | None = None,
) -> np.ndarray:
    """Compute the tn* statistic as in (4.24) as in Andrews and Kwon (2023).

    Parameters
    ----------
    x_data : array_like
        n x k matrix of the moment functions with n rows (output of
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
    n = x_data.shape[0]  # sample size

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

    m_hat0 = m_hat(x_data)
    r_hat_vec = -1 * m_hat0.clip(max=0)
    r_hat = r_hat_vec.max()

    xi_n = (np.sqrt(n) * (m_hat0 + r_hat)) / (std_b1 * kappa_n)
    phi_n = np.zeros_like(xi_n)
    phi_n[xi_n > 1] = np.inf

    # Combining (4.17) and (4.18) from Andrews and Kwon (2023)
    tn_star_vec = (
        np.sqrt(n) * (m_hat(x_data[bootstrap_indices, :], axis=1) - m_hat0) + phi_n
    )

    return tn_star_vec
