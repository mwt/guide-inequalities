import numpy as np

from .cvalue import cvalue_EB2S, cvalue_SN, cvalue_SN2S
from .moment import m_function, m_hat


def g_restriction(
    W_data: np.ndarray,
    A_matrix: np.ndarray,
    theta0: np.ndarray,
    J0_vec: np.ndarray,
    Vbar: float,
    IV_matrix: np.ndarray | None,
    grid0: np.ndarray,
    test0: str,
    cvalue: str,
    alpha: float,
    num_boots: int,
    rng_seed: int,
    An_vec: np.ndarray | None = None,
    hat_r_inf: float | None = None,
) -> tuple[float, float]:
    """This high-level function parses arguments and calls the appropriate
    function for the test statistic and critical value.

    Parameters
    ----------
    W_data : array_like
        n x J0 matrix of product portfolio.
    A_matrix : array_like
        n x (J0 + 1) matrix of estimated revenue differential.
    theta : array_like
        d_theta x 1 parameter of interest.
    J0_vec : array_like
        J0 x 2 matrix of ownership by two firms.
    Vbar : float
        Tuning parameter as in Assumption 4.2
    IV_matrix : array_like or None
        n x d_IV matrix of instruments or None if no instruments are used.
    grid0 : {1, 2, 'all'}
        Grid direction to use for the estimation of the model.
    test0 : {'CCK', 'RC-CCK'}
        Test statistic to use.
    cvalue : {'SPUR1', 'SN', 'SN2S', 'EB2S'}
        Critical value to use.
    alpha : float
        Significance level.
    num_boots : int
        Number of bootstrap replications.
    rng_seed : int
        Random number generator seed (for replication purposes).
    An_vec : array_like, optional
        If using SPUR 1, a n x 1 vector of An values as in eq. (4.25) in
        Andrews and Kwon (2023).
    hat_r_inf : float, optional
        If using RC-CCK, the lower value of the test as in eq. (4.4) in
        Andrews and Kwon (2023).

    Returns
    -------
    test_stat : float
        The specified test statistic.
    critical_value : float
        The critical value.

    Notes
    -----
      - The test statistic is defined in eq (38)
      - The possible critical values are defined in eq (40), (41), and (48)
      - This function also includes the re-centered test statistic as in
        Section 8.2.2 and critical value SPUR1 as in Appendix Section C.
    """
    if (cvalue == "SPUR1" or test0 == "RC-CCK") and (
        An_vec is None or hat_r_inf is None
    ):
        raise ValueError("An_vec and hat_r_inf must be provided for SPUR1 and RC-CCK")

    X_data = m_function(W_data, A_matrix, theta0, J0_vec, Vbar, IV_matrix, grid0)
    m_hat0 = m_hat(X_data)
    n = X_data.shape[0]

    # see Section 4.2.2 in Chernozhukov et al. (2019)
    beta = alpha / 50

    # Set test statistic
    ## 1. CCK
    ## 2. RC-CCK
    match test0:
        case "CCK":
            test_stat = np.sqrt(n) * np.max(m_hat0)
        case "RC-CCK":
            test_stat = -np.sqrt(n) * np.max(
                np.min(np.concatenate((m_hat0 + hat_r_inf, 0)))
            )
        case _:
            raise ValueError("test0 must be either CCK or RC-CCK")

    # Set critical value
    ## 1. SPUR1 as in Section 4.4 in Andrews and Kwon (2023)
    ##    (note, we use -X_data to match their condition)
    ## 2. SN as in eq (40)
    ## 3. SN2S as in eq (41)
    ## 4. EB2S as in eq (48)
    match cvalue:
        # case "SPUR1":
        #    critical_value = cvalue_SPUR1(-X_data, num_boots, alpha, An_vec, rng_seed)
        case "SN":
            critical_value = cvalue_SN(X_data, alpha)
        case "SN2S":
            critical_value = cvalue_SN2S(X_data, alpha, beta)
        case "EB2S":
            critical_value = cvalue_EB2S(X_data, num_boots, alpha, beta, rng_seed)
        case _:
            raise ValueError("cvalue must be either SPUR1, SN, SN2S, or EB2S")

    return test_stat, critical_value
