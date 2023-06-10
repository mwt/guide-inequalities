import numpy as np


def m_hat(x_data: np.ndarray, axis: int = 0) -> np.ndarray:
    """Compute a standardized sample mean of the moment functions as in eq (A.13)

    Parameters
    ----------
    x_data : array_like
        Matrix of the moment functions with n rows (output of
        :func:`ineq_functions.m_function`).
    axis : int, default=0
        Axis along which the mean and standard deviation are computed.

    Returns
    -------
    array_like
        Vector of the standardized sample mean of the moment functions.

    Notes
    -----
      - this function is useful for the procedure in Andrews and Kwon (2023)
      - define :math:`x_{ij} = m_j(w_i,theta)`, n: sample size, k: number of moments
      - define :math:`mu_j` as sample mean of :math:`x_{ij}` and
        :math:`sigma_j` std. of :math:`x_ij`
      - this function computes the vector :math:`mu_j / sigma_j`
    """
    # Compute the mean of each column of x_data
    mu_hat = x_data.mean(axis=axis)
    # Compute the standard deviation of each column of x_data
    sigma_hat = x_data.std(axis=axis)

    # as in eq (A.13) and similar to eq. (4.2) in Andrews and Kwon (2023)
    # use np.divide to avoid division by zero (treat 0/0 as 0)
    return np.divide(mu_hat, sigma_hat, out=np.zeros_like(mu_hat), where=mu_hat != 0)


def m_function(
    w_data: np.ndarray,
    a_matrix: np.ndarray,
    theta: np.ndarray,
    j0_vec: np.ndarray,
    v_bar: float,
    iv_matrix: np.ndarray | None = None,
    grid0: int | str = "all",
    dist_data: np.ndarray | None = None,
) -> np.ndarray:
    """Moment inequality function defined in eq (28)

    There are four main steps:
     1. Select moments with non-zero variance using ml_indx & mu_indx.
     2. Compute all the moment functions.
     3. Select the computed moment functions using ml_indx & mu_indx.

    Parameters
    ----------
    w_data : array_like
        n x j0 matrix of product portfolio.
    a_matrix : array_like
        n x (j0 + 1) matrix of estimated revenue differential.
    theta : array_like
        d_theta x 1 parameter of interest.
    j0_vec : array_like
        j0 x 2 matrix of ownership by two firms.
    v_bar : float
        Tuning parameter as in Assumption 4.2
    iv_matrix : array_like, optional
        n x d_IV matrix of instruments or None if no instruments are used.
    grid0 : {1, 2, 'all'}, default='all'
        Grid direction to use for the estimation of the model.
    dist_data : array_like, optional
        n x (J + 1) matrix of distances between product factories and cities.

    Returns
    -------
    array_like
        Matrix of the moment functions with n rows.
    """
    # Get number of rows in a_matrix and j0_vec
    n = a_matrix.shape[0]
    num_products = j0_vec.shape[0]

    # Check size of w_data
    if w_data.shape[0] != n:
        raise ValueError("w_data must have the same number of rows as a_matrix")

    # Step 1: Select moments with non-zero variance using ml_indx & mu_indx
    #         the procedure follows the discussion of section 8.1

    # Take sum of columns of w_data
    aux1 = w_data.sum(axis=0)
    aux1 = aux1[j0_vec[:, 0].astype(int) - 1]

    # Condition on grid0
    match grid0:
        case "all":
            ml_indx = (aux1 < n).nonzero()[0]
            mu_indx = (aux1 > 0).nonzero()[0]
        case 1 | 2:
            ml_indx = ((aux1 < n) & (j0_vec[:, 1] == grid0)).nonzero()[0]
            mu_indx = ((aux1 > 0) & (j0_vec[:, 1] == grid0)).nonzero()[0]
        case _:
            raise ValueError("grid0 must be either all, 1, or 2")

    # Subset vector of estimated revenue differential in market i
    a_subset = a_matrix[:, 1 : (num_products + 1)]
    # Subset vector of product portfolio of coca-cola and
    # energy-products in market i
    d_matrix = w_data[:, j0_vec[:, 0].astype(int) - 1]

    if dist_data is None:
        dist_subset = None
    else:
        # Note that we skip the first column of dist_data, so there is no `-1`
        dist_subset = dist_data[:, j0_vec[:, 0].astype(int)]

    ## step 2: compute all the moment functions

    if iv_matrix is None:
        # Create dummy IV "matrix"
        z_matrix = np.array([1])

        # Compute lower and upper bounds
        ml_vec = m_fun_lower(
            a_subset, d_matrix, z_matrix, j0_vec, theta, v_bar, dist_subset
        )
        mu_vec = m_fun_upper(
            a_subset, d_matrix, z_matrix, j0_vec, theta, v_bar, dist_subset
        )

        # Create new row of x_data
        x_data = np.hstack((ml_vec[:, ml_indx], mu_vec[:, mu_indx]))

    else:
        # Create dummy IV "matrix"
        z0_mat = np.array([1])
        # employment rate
        z3_mat = (iv_matrix[:, 1] > np.median(iv_matrix[:, 1])).astype(int)
        # average income in market
        z5_mat = (iv_matrix[:, 2] > np.median(iv_matrix[:, 2])).astype(int)
        # median income in market
        z7_mat = (iv_matrix[:, 3] > np.median(iv_matrix[:, 3])).astype(int)

        # Compute lower and upper bounds
        ml_vec0 = m_fun_lower(
            a_subset, d_matrix, z0_mat, j0_vec, theta, v_bar, dist_subset
        )
        mu_vec0 = m_fun_upper(
            a_subset, d_matrix, z0_mat, j0_vec, theta, v_bar, dist_subset
        )

        ml_vec3 = m_fun_lower(
            a_subset, d_matrix, z3_mat, j0_vec, theta, v_bar, dist_subset
        )
        mu_vec3 = m_fun_upper(
            a_subset, d_matrix, z3_mat, j0_vec, theta, v_bar, dist_subset
        )

        ml_vec5 = m_fun_lower(
            a_subset, d_matrix, z5_mat, j0_vec, theta, v_bar, dist_subset
        )
        mu_vec5 = m_fun_upper(
            a_subset, d_matrix, z5_mat, j0_vec, theta, v_bar, dist_subset
        )

        ml_vec7 = m_fun_lower(
            a_subset, d_matrix, z7_mat, j0_vec, theta, v_bar, dist_subset
        )
        mu_vec7 = m_fun_upper(
            a_subset, d_matrix, z7_mat, j0_vec, theta, v_bar, dist_subset
        )

        # Create new row of x_data
        x_data = np.hstack(
            (
                ml_vec0[:, ml_indx],
                mu_vec0[:, mu_indx],
                ml_vec3[:, ml_indx],
                mu_vec3[:, mu_indx],
                ml_vec5[:, ml_indx],
                mu_vec5[:, mu_indx],
                ml_vec7[:, ml_indx],
                mu_vec7[:, mu_indx],
            )
        )

    return x_data


def m_fun_lower(
    a_subset: np.ndarray,
    d_matrix: np.ndarray,
    z_matrix: np.ndarray,
    j0_vec: np.ndarray,
    theta: np.ndarray,
    v_bar: float,
    dist_subset: np.ndarray | None = None,
) -> np.ndarray:
    """Moment inequality function defined in eq (26)

    Parameters
    ----------
    a_subset : array_like
        n X j0 matrix of estimated revenue differential in a market.
    d_matrix : array_like
        n X j0 matrix of product portfolio in a market.
    z_matrix : array_like
        n X j0 matrix of instruments in a market.
    j0_vec : array_like
        j0 x 2 array of products of coca-cola and energy-product.
    theta : array_like
        d_theta x 1 parameter of interest.
    v_bar : float
        Tuning parameter as in Assumption 4.2.
    dist_subset : array_like, optional
        n x j0 matrix of distance between products in a market, by default None.

    Returns
    -------
    array_like
        1 x j0 vector of the moment function.
    """
    # Get number of firms
    num_firms = np.unique(j0_vec[:, 1]).shape[0]

    # Get indices that match theta values to the firm of each product
    j1i = j0_vec[:, 1].astype(int) - 1

    if dist_subset is None:
        # Create vector of theta values matched to the firm of each product
        theta_vector = theta[np.newaxis, j1i]
    else:
        # Reshape theta to be num_firms x 3
        theta = theta.reshape(num_firms, 3)
        # Create g_theta vector as in Section 8.2.3
        theta_vector = (
            theta[j1i, 0]
            + theta[j1i, 1] * dist_subset
            + theta[j1i, 2] * (dist_subset**2)
        )

    if num_firms != theta.shape[0]:
        raise ValueError(
            f"theta must have the same number of elements as num_firms (i.e., {num_firms})"
        )

    # Run equation (26) for each product
    return ((a_subset - theta_vector) * (1 - d_matrix) - v_bar * d_matrix) * z_matrix[
        :, np.newaxis
    ]


def m_fun_upper(
    a_subset: np.ndarray,
    d_matrix: np.ndarray,
    z_matrix: np.ndarray,
    j0_vec: np.ndarray,
    theta: np.ndarray,
    v_bar: float,
    dist_subset: np.ndarray | None = None,
) -> np.ndarray:
    """Moment inequality function defined in eq (27)

    Parameters
    ----------
    a_subset : array_like
        n X j0 matrix of estimated revenue differential in a market.
    d_matrix : array_like
        n X j0 matrix of product portfolio in a market.
    z_matrix : array_like
        n X j0 matrix of instruments in a market.
    j0_vec : array_like
        j0 x 2 array of products of coca-cola and energy-product.
    theta : array_like
        d_theta x 1 parameter of interest.
    v_bar : float
        Tuning parameter as in Assumption 4.2.
    dist_subset : array_like, optional
        n x j0 matrix of distance between products in a market, by default None.

    Returns
    -------
    array_like
        1 x j0 vector of the moment function.

    Notes
    -----
    Calls m_fun_lower with two substitutions:
    1. theta is negated
    2. d_matrix replaced with 1 - d_matrix
    """
    # Moment function upper is moment function lower with two substitutions:
    # 1. theta is negated
    # 2. d_matrix replaced with 1 - d_matrix
    return m_fun_lower(
        a_subset=a_subset,
        d_matrix=1 - d_matrix,
        z_matrix=z_matrix,
        j0_vec=j0_vec,
        theta=-theta,
        v_bar=v_bar,
        dist_subset=dist_subset,
    )


def find_dist(dist_data: np.ndarray, j0_vec: np.ndarray) -> np.ndarray:
    """Find maximum distance from each firm's factory to the market.

    Parameters
    ----------
    dist_data : array_like
        n x j0 matrix of distance between products in a market.
    j0_vec : array_like
        j0 x 2 array of products of coca-cola and energy-product.

    Returns
    -------
    coke_max_dist : array_like
        n dimensional vector of maximum distance from coca-cola factory to
        each market.
    ener_max_dist : array_like
        n dimensional vector of maximum distance from energy-product factory
        to each market.

    Notes
    -----
    This function is used only in Table 4.
    """
    coke_dist = dist_data[:, j0_vec[j0_vec[:, 1] == 1, 0].astype(int) - 1]
    ener_dist = dist_data[:, j0_vec[j0_vec[:, 1] == 2, 0].astype(int) - 1]
    return coke_dist.max(axis=1), ener_dist.max(axis=1)
