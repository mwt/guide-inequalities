import numpy as np

from .cvalue import cvalue_EB2S, cvalue_SN, cvalue_SN2S
from .moment import m_function, m_hat


def g_restriction(
    W_data: np.ndarray,
    A_matrix: np.ndarray,
    theta0: np.ndarray,
    J0_vec: np.ndarray,
    Vbar: float,
    IV_matrix,
    grid0: np.ndarray,
    test0: str,
    cvalue: str,
    alpha_input,
    num_boots,
    rng_seed,
    An_vec=None,
    hat_r_inf=None,
):
    if (cvalue == "SPUR1" or test0 == "RC-CCK") and (
        An_vec is None or hat_r_inf is None
    ):
        raise ValueError("An_vec and hat_r_inf must be provided for SPUR1 and RC-CCK")

    X_data = m_function(W_data, A_matrix, theta0, J0_vec, Vbar, IV_matrix, grid0)
    m_hat0 = m_hat(X_data)
    n = X_data.shape[0]

    # see Section 4.2.2 in Chernozhukov et al. (2019)
    beta_input = alpha_input / 50

    # Set test statistic
    ## 1. CCK
    ## 2. RC-CCK
    match test0:
        case "CCK":
            test_stat = np.max(np.sqrt(n) * m_hat0)
        case "RC-CCK":
            test_stat = np.max(-np.min(np.append(np.sqrt(n) * (m_hat0 + hat_r_inf), 0)))
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
        #    critical_value = cvalue_SPUR1(-X_data, num_boots, alpha_input, An_vec, rng_seed)
        case "SN":
            critical_value = cvalue_SN(X_data, alpha_input)
        case "SN2S":
            critical_value = cvalue_SN2S(X_data, alpha_input, beta_input)
        case "EB2S":
            critical_value = cvalue_EB2S(
                X_data, num_boots, alpha_input, beta_input, rng_seed
            )
        case _:
            raise ValueError("cvalue must be either SPUR1, SN, SN2S, or EB2S")

    return test_stat, critical_value
