import numpy as np


def m_hat(X_data: np.ndarray, axis: int = 0) -> np.ndarray:
    """Compute a standardized sample mean of the moment functions as in eq (A.13)

    Parameters
    ----------
    X_data : array_like
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
      - define :math:`X_{ij} = m_j(W_i,theta)`, n: sample size, k: number of moments
      - define :math:`mu_j` as sample mean of :math:`X_{ij}` and
        :math:`sigma_j` std. of :math:`X_ij`
      - this function computes the vector :math:`mu_j / sigma_j`
    """
    # Compute the mean of each column of X_data
    mu_hat = np.mean(X_data, axis=axis)
    # Compute the standard deviation of each column of X_data
    sigma_hat = np.std(X_data, axis=axis)

    # as in eq (A.13) and similar to eq. (4.2) in Andrews and Kwon (2023)
    # use np.divide to avoid division by zero (treat 0/0 as 0)
    not_zero_over_zero = (sigma_hat != 0) | (mu_hat != 0)
    return np.divide(
        mu_hat, sigma_hat, out=np.zeros_like(mu_hat), where=not_zero_over_zero
    )


def m_function(
    W_data: np.ndarray,
    A_matrix: np.ndarray,
    theta: np.ndarray,
    J0_vec: np.ndarray,
    Vbar: float,
    IV_matrix: np.ndarray | None = None,
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
    IV_matrix : array_like, optional
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
    # Get number of rows in A_matrix and J0_vec
    n = A_matrix.shape[0]
    num_products = J0_vec.shape[0]

    # Check size of W_data
    if W_data.shape[0] != n:
        raise ValueError("W_data must have the same number of rows as A_matrix")

    # Step 1: Select moments with non-zero variance using ml_indx & mu_indx
    #         the procedure follows the discussion of section 8.1

    # Take sum of columns of W_data
    aux1 = np.sum(W_data, axis=0)
    aux1 = aux1[J0_vec[:, 0].astype(int) - 1]

    # Condition on grid0
    match grid0:
        case "all":
            ml_indx = (aux1 < n).nonzero()[0]
            mu_indx = (aux1 > 0).nonzero()[0]
        case 1 | 2:
            ml_indx = ((aux1 < n) & (J0_vec[:, 1] == grid0)).nonzero()[0]
            mu_indx = ((aux1 > 0) & (J0_vec[:, 1] == grid0)).nonzero()[0]
        case _:
            raise ValueError("grid0 must be either all, 1, or 2")

    # Subset vector of estimated revenue differential in market i
    A_subset = A_matrix[:, 1 : (num_products + 1)]
    # Subset vector of product portfolio of coca-cola and
    # energy-products in market i
    D_mat = W_data[:, J0_vec[:, 0].astype(int) - 1]

    if dist_data is None:
        dist_subset = None
    else:
        dist_subset = dist_data[J0_vec[:, 0].astype(int) - 1, 1 : (num_products + 1)]

    ## step 2: compute all the moment functions

    if IV_matrix is None:
        # Create dummy IV "matrix"
        Z_mat = np.array([1])

        # Compute lower and upper bounds
        ml_vec = MomentFunct_L(A_subset, D_mat, Z_mat, J0_vec, theta, Vbar, dist_subset)
        mu_vec = MomentFunct_U(A_subset, D_mat, Z_mat, J0_vec, theta, Vbar, dist_subset)

        # Create new row of X_data
        X_data = np.hstack((ml_vec[:, ml_indx], mu_vec[:, mu_indx]))

    else:
        # Create dummy IV "matrix"
        Z0_mat = np.array([1])
        # employment rate
        Z3_mat = (IV_matrix[:, 1] > np.median(IV_matrix[:, 1])).astype(int)
        # average income in market
        Z5_mat = (IV_matrix[:, 2] > np.median(IV_matrix[:, 2])).astype(int)
        # median income in market
        Z7_mat = (IV_matrix[:, 3] > np.median(IV_matrix[:, 3])).astype(int)

        # Compute lower and upper bounds
        ml_vec0 = MomentFunct_L(
            A_subset, D_mat, Z0_mat, J0_vec, theta, Vbar, dist_subset
        )
        mu_vec0 = MomentFunct_U(
            A_subset, D_mat, Z0_mat, J0_vec, theta, Vbar, dist_subset
        )

        ml_vec3 = MomentFunct_L(
            A_subset, D_mat, Z3_mat, J0_vec, theta, Vbar, dist_subset
        )
        mu_vec3 = MomentFunct_U(
            A_subset, D_mat, Z3_mat, J0_vec, theta, Vbar, dist_subset
        )

        ml_vec5 = MomentFunct_L(
            A_subset, D_mat, Z5_mat, J0_vec, theta, Vbar, dist_subset
        )
        mu_vec5 = MomentFunct_U(
            A_subset, D_mat, Z5_mat, J0_vec, theta, Vbar, dist_subset
        )

        ml_vec7 = MomentFunct_L(
            A_subset, D_mat, Z7_mat, J0_vec, theta, Vbar, dist_subset
        )
        mu_vec7 = MomentFunct_U(
            A_subset, D_mat, Z7_mat, J0_vec, theta, Vbar, dist_subset
        )

        # Create new row of X_data
        X_data = np.hstack(
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

    return X_data


def MomentFunct_L(
    A_subset: np.ndarray,
    D_mat: np.ndarray,
    Z_mat: np.ndarray,
    J0_vec: np.ndarray,
    theta: np.ndarray,
    Vbar: float,
    dist_subset: np.ndarray | None = None,
) -> np.ndarray:
    """Moment inequality function defined in eq (26)

    Parameters
    ----------
    A_subset : array_like
        n X J0 matrix of estimated revenue differential in a market.
    D_mat : array_like
        n X J0 matrix of product portfolio in a market.
    Z_mat : array_like
        n X J0 matrix of instruments in a market.
    J0_vec : array_like
        J0 x 2 array of products of coca-cola and energy-product.
    theta : array_like
        d_theta x 1 parameter of interest.
    Vbar : float
        Tuning parameter as in Assumption 4.2.
    dist_subset : array_like, optional
        A J0 x J0 matrix of distance between products in a market, by default None.

    Returns
    -------
    array_like
        1 x J0 vector of the moment function.
    """
    # Get number of firms
    num_firms = np.unique(J0_vec[:, 1]).shape[0]

    # Get indices that match theta values to the firm of each product
    j1i = J0_vec[:, 1].astype(int) - 1

    if dist_subset is None:
        # Create vector of theta values matched to the firm of each product
        theta_vector = theta[j1i]
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

    # Create vector of theta values matched to the firm of each product
    theta_vector = theta[J0_vec[:, 1].astype(int) - 1]

    # Run equation (26) for each product
    return (
        (A_subset - theta_vector[np.newaxis, :]) * (1 - D_mat) - Vbar * D_mat
    ) * Z_mat[:, np.newaxis]


def MomentFunct_U(
    A_subset: np.ndarray,
    D_mat: np.ndarray,
    Z_mat: np.ndarray,
    J0_vec: np.ndarray,
    theta: np.ndarray,
    Vbar: float,
    dist_subset: np.ndarray | None = None,
) -> np.ndarray:
    """Moment inequality function defined in eq (27)

    Parameters
    ----------
    A_subset : array_like
        n X J0 matrix of estimated revenue differential in a market.
    D_mat : array_like
        n X J0 matrix of product portfolio in a market.
    Z_mat : array_like
        n X J0 matrix of instruments in a market.
    J0_vec : array_like
        J0 x 2 array of products of coca-cola and energy-product.
    theta : array_like
        d_theta x 1 parameter of interest.
    Vbar : float
        Tuning parameter as in Assumption 4.2.
    dist_subset : array_like, optional
        A J0 x J0 matrix of distance between products in a market, by default None.

    Returns
    -------
    array_like
        1 x J0 vector of the moment function.
    """
    # Get number of firms
    num_firms = np.unique(J0_vec[:, 1]).shape[0]

    # Get indices that match theta values to the firm of each product
    j1i = J0_vec[:, 1].astype(int) - 1

    if dist_subset is None:
        # Create vector of theta values matched to the firm of each product
        theta_vector = theta[j1i]
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

    # Run equation (27) for each product
    return (
        (A_subset + theta_vector[np.newaxis, :]) * D_mat - Vbar * (1 - D_mat)
    ) * Z_mat[:, np.newaxis]
