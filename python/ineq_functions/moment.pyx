import numpy as np

# "cimport" is used to import special compile-time information
# about the numpy module (this is stored in a file numpy.pxd which is
# currently part of the Cython distribution).
cimport numpy as np

# It's necessary to call "import_array" if you use any part of the
# numpy PyArray_* API. From Cython 3, accessing attributes like
# ".shape" on a typed Numpy array use this API. Therefore we recommend
# always calling "import_array" whenever you "cimport numpy"
np.import_array()


def m_hat(X_data: np.ndarray):
    """Compute a standardized sample mean of the moment functions as in eq (A.13)

    Parameters
    ----------
    X_data : array_like
        Matrix of the moment functions with n rows (output of
        :func:`ineq_functions.m_function`).

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
    mu_hat = np.mean(X_data, axis=0)
    # Compute the standard deviation of each column of X_data
    sigma_hat = np.std(X_data, axis=0)

    # as in eq (A.13) and similar to eq. (4.2) in Andrews and Kwon (2023)
    return mu_hat / sigma_hat


def m_function(
    W_data: np.ndarray,
    A_matrix: np.ndarray,
    theta: np.ndarray,
    J0_vec: np.ndarray,
    Vbar: float,
    IV_matrix: np.ndarray | None = None,
    grid0: int | str = "all",
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
    if grid0 == "all":
        ml_indx = np.asarray(aux1 < n).nonzero()
        mu_indx = np.asarray(aux1 > 0).nonzero()
    elif grid0 in (1,2):
        ml_indx = np.asarray((aux1 < n) & (J0_vec[:, 1] == grid0)).nonzero()
        mu_indx = np.asarray((aux1 > 0) & (J0_vec[:, 1] == grid0)).nonzero()
    else:
        raise ValueError("grid0 must be either all, 1, or 2")

    ## step 2: compute all the moment functions

    if IV_matrix is None:
        # Initialize X_data
        X_data = np.empty((n, ml_indx[0].size + mu_indx[0].size))

        # Create dummy IV vector
        Z_vec = np.ones(num_products)

        for market_index in range(n):
            # Subset vector of estimated revenue differential in market i
            A_vec = A_matrix[market_index, 1 : (num_products + 1)]
            # Subset vector of product portfolio of coca-cola and
            # energy-products in market i
            D_vec = W_data[market_index, J0_vec[:, 0].astype(int) - 1]

            # Compute lower and upper bounds
            ml_vec = MomentFunct_L(A_vec, D_vec, Z_vec, J0_vec, theta, Vbar)
            mu_vec = MomentFunct_U(A_vec, D_vec, Z_vec, J0_vec, theta, Vbar)

            # Create new row of X_data
            X_data[market_index, :] = np.concatenate((ml_vec[ml_indx], mu_vec[mu_indx]))

    else:
        # Initialize X_data
        X_data = np.empty((n, 4 * (ml_indx[0].size + mu_indx[0].size)))

        # Create dummy IV vector
        Z_vec = np.ones(num_products)
        # employment rate
        Z3_vec = (IV_matrix[:, 1] > np.median(IV_matrix[:, 1])).astype(int)
        # average income in market
        Z5_vec = (IV_matrix[:, 2] > np.median(IV_matrix[:, 2])).astype(int)
        # median income in market
        Z7_vec = (IV_matrix[:, 3] > np.median(IV_matrix[:, 3])).astype(int)

        for market_index in range(n):
            # Subset vector of estimated revenue differential in market i
            A_vec = A_matrix[market_index, 1 : (num_products + 1)]
            # Subset vector of product portfolio of coca-cola and
            # energy-products in market i
            D_vec = W_data[market_index, J0_vec[:, 0].astype(int) - 1]

            # Compute lower and upper bounds
            ml_vec = MomentFunct_L(A_vec, D_vec, Z_vec, J0_vec, theta, Vbar)
            mu_vec = MomentFunct_U(A_vec, D_vec, Z_vec, J0_vec, theta, Vbar)

            ml_vec3 = MomentFunct_L(A_vec, D_vec, Z3_vec, J0_vec, theta, Vbar)
            mu_vec3 = MomentFunct_U(A_vec, D_vec, Z3_vec, J0_vec, theta, Vbar)

            ml_vec5 = MomentFunct_L(A_vec, D_vec, Z5_vec, J0_vec, theta, Vbar)
            mu_vec5 = MomentFunct_U(A_vec, D_vec, Z5_vec, J0_vec, theta, Vbar)

            ml_vec7 = MomentFunct_L(A_vec, D_vec, Z7_vec, J0_vec, theta, Vbar)
            mu_vec7 = MomentFunct_U(A_vec, D_vec, Z7_vec, J0_vec, theta, Vbar)

            # Create new row of X_data
            X_data[market_index, :] = np.concatenate(
                (
                    ml_vec[ml_indx],
                    mu_vec[mu_indx],
                    ml_vec3[ml_indx],
                    mu_vec3[mu_indx],
                    ml_vec5[ml_indx],
                    mu_vec5[mu_indx],
                    ml_vec7[ml_indx],
                    mu_vec7[mu_indx],
                )
            )

    return X_data


def MomentFunct_L(
    A_vec: np.ndarray,
    D_vec: np.ndarray,
    Z_vec: np.ndarray,
    J0_vec: np.ndarray,
    theta: np.ndarray,
    Vbar: float,
) -> np.ndarray:
    """Moment inequality function defined in eq (26)

    Parameters
    ----------
    A_vec : array_like
        J0 x 1 vector of estimated revenue differential in a market.
    D_vec : array_like
        J0 x 1 vector of product portfolio in a market.
    Z_vec : array_like
        J0 x 1 vector of instruments in a market.
    J0_vec : array_like
        J0 x 2 array of products of coca-cola and energy-product.
    theta : array_like
        d_theta x 1 parameter of interest.
    Vbar : float
        Tuning parameter as in Assumption 4.2

    Returns
    -------
    array_like
        1 x J0 vector of the moment function.
    """
    # Get number of firms
    num_firms = np.unique(J0_vec[:, 1]).shape[0]

    if num_firms != theta.shape[0]:
        raise ValueError(
            f"theta must have the same number of elements as num_firms (i.e., {num_firms})"
        )

    # Create vector of theta values matched to the firm of each product
    theta_vector = theta[J0_vec[:, 1].astype(int) - 1]

    # Run equation (26) for each product
    return ((A_vec - theta_vector) * (1 - D_vec) - Vbar * D_vec) * Z_vec


def MomentFunct_U(
    A_vec: np.ndarray,
    D_vec: np.ndarray,
    Z_vec: np.ndarray,
    J0_vec: np.ndarray,
    theta: np.ndarray,
    Vbar: float,
) -> np.ndarray:
    """Moment inequality function defined in eq (27)

    Parameters
    ----------
    A_vec : array_like
        J0 x 1 vector of estimated revenue differential in a market.
    D_vec : array_like
        J0 x 1 vector of product portfolio in a market.
    Z_vec : array_like
        J0 x 1 vector of instruments in a market.
    J0_vec : array_like
        J0 x 2 array of products of coca-cola and energy-product.
    theta : array_like
        d_theta x 1 parameter of interest.
    Vbar : float
        Tuning parameter as in Assumption 4.2

    Returns
    -------
    array_like
        1 x J0 vector of the moment function.
    """
    # Get number of firms
    num_firms = np.unique(J0_vec[:, 1]).shape[0]

    if num_firms != theta.shape[0]:
        raise ValueError(
            f"theta must have the same number of elements as num_firms (i.e., {num_firms})"
        )

    # Create vector of theta values matched to the firm of each product
    theta_vector = theta[J0_vec[:, 1].astype(int) - 1]

    # Run equation (27) for each product
    return ((A_vec + theta_vector) * D_vec - Vbar * (1 - D_vec)) * Z_vec
