import numpy as np

from .andrews_kwon import cvalue_spur1
from .cvalue import cvalue_eb2s, cvalue_sn, cvalue_sn2s
from .moment import m_function, m_hat, find_dist


def g_restriction(
    theta: np.ndarray,
    w_data: np.ndarray,
    a_matrix: np.ndarray,
    j0_vector: np.ndarray,
    v_bar: float,
    alpha: float,
    grid0: int | str = "all",
    iv_matrix: np.ndarray | None = None,
    test0: str = "CCK",
    cvalue: str = "SN",
    account_uncertainty: bool = False,
    bootstrap_replications: int | None = None,
    rng_seed: int | None = None,
    bootstrap_indices: np.ndarray | None = None,
    an_vec: np.ndarray | None = None,
    hat_r_inf: float | None = None,
    dist_data: np.ndarray | None = None,
) -> list[float, float]:
    """This high-level function parses arguments and calls the appropriate
    function for the test statistic and critical value.

    Parameters
    ----------
    theta : array_like
        d_theta x 1 parameter of interest.
    w_data : array_like
        n x j0 matrix of product portfolio.
    a_matrix : array_like
        n x (j0 + 1) matrix of estimated revenue differentials.
    j0_vector : array_like
        j0 x 2 matrix of ownership by two firms.
    v_bar : float
        Tuning parameter as in Assumption 4.2.
    alpha : float
        Significance level.
    grid0 : {1, 2, 'all'}
        Grid direction to use for the estimation of the model.
    iv_matrix : array_like or None
        n x d_IV matrix of instruments or None if no instruments are used.
    test0 : {'CCK', 'RC-CCK'}
        Test statistic to use.
    cvalue : {'SPUR1', 'SN', 'SN2S', 'EB2S'}
        Critical value to use.
    account_uncertainty : bool, default False
        Whether to account for additional uncertainty (as in Equations 50 and
        51). If True, the last two elements of theta are assumed to be mu.
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
    an_vec : array_like, optional
        If using SPUR 1, a n x 1 vector of An values as in eq. (4.25) in
        Andrews and Kwon (2023).
    hat_r_inf : float, optional
        If using RC-CCK, the lower value of the test as in eq. (4.4) in
        Andrews and Kwon (2023).
    dist_data : array_like, optional
        n x (J + 1) matrix of distances between product factories and cities.

    Returns
    -------
    test_stat : float
        The specified test statistic.
    critical_value : float
        The critical value.

    Notes
    -----
      - The test statistic is defined in eq (39)
      - The possible critical values are defined in eq (41), (42), and (49)
      - This function also includes the re-centered test statistic as in
        Section 8.2.2 and critical value SPUR1 as in Appendix Section C.
    """
    if cvalue == "SPUR1" and an_vec is None:
        raise ValueError("an_vec must be provided for SPUR1")
    if test0 == "RC-CCK" and hat_r_inf is None:
        raise ValueError("hat_r_inf must be provided for RC-CCK")

    if account_uncertainty:
        # assume that the last two elements of theta are mu
        theta, mu = np.split(theta, [-2])

    x_data = m_function(
        theta, w_data, a_matrix, j0_vector, v_bar, grid0, iv_matrix, dist_data
    )

    if account_uncertainty:
        # additional moments to account for randomness of the objective
        # function defined in eq (50) and (51)
        coke_max_dist, ener_max_dist = find_dist(dist_data, j0_vector)
        dist_u1 = coke_max_dist - mu[0]
        dist_u2 = ener_max_dist - mu[1]
        x_data = np.column_stack((x_data, dist_u1, -dist_u1, dist_u2, -dist_u2))

    n = x_data.shape[0]

    # see Section 4.2.2 in Chernozhukov et al. (2019)
    beta = alpha / 50

    # Set test statistic
    ## 1. CCK
    ## 2. RC-CCK
    match test0:
        case "CCK":
            test_stat = np.sqrt(n) * m_hat(x_data).max()
        case "RC-CCK":
            test_stat = -np.sqrt(n) * (m_hat(-x_data) + hat_r_inf).clip(max=0).min()
        case _:
            raise ValueError("test0 must be either CCK or RC-CCK")

    # Set critical value
    ## 1. SPUR1 as in Section 4.4 in Andrews and Kwon (2023)
    ##    (note, we use -x_data to match their condition)
    ## 2. SN as in eq (41)
    ## 3. SN2S as in eq (42)
    ## 4. EB2S as in eq (49)
    match cvalue:
        case "SN":
            critical_value = cvalue_sn(x_data, alpha)
        case "SN2S":
            critical_value = cvalue_sn2s(x_data, alpha, beta)
        case "EB2S":
            critical_value = cvalue_eb2s(
                x_data, alpha, beta, bootstrap_replications, rng_seed, bootstrap_indices
            )
        case "SPUR1":
            critical_value = cvalue_spur1(
                -x_data,
                alpha,
                an_vec,
                bootstrap_replications,
                rng_seed,
                bootstrap_indices,
            )
        case _:
            raise ValueError("cvalue must be either SPUR1, SN, SN2S, or EB2S")

    return [test_stat, critical_value]


def g_restriction_diff(*args, **kwargs):
    """Wrapper function for :func:`g_restriction` to be used with scipy.optimize"""
    return np.subtract(*g_restriction(*args, **kwargs))
