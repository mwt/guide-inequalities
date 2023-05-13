import numpy as np
from .shim import R, clean_args

# m_function = clean_args(R.m_function)
m_hat = clean_args(R.m_hat)
MomentFunct_L = clean_args(R.MomentFunct_L)
MomentFunct_U = clean_args(R.MomentFunct_U)


def m_function(W_data, A_matrix, theta, J0_vec, Vbar, IV_matrix, grid0):
    n = A_matrix.shape[0]
    J0 = J0_vec.shape[0]

    # Check size of W_data
    if W_data.shape[0] != n:
        raise ValueError("W_data must have the same number of rows as A_matrix")

    # Step 1: Select moments with non-zero variance using ml_indx & mu_indx
    #         the procedure follows the discussion of section 8.1

    # Take sum of columns of W_data
    aux1 = np.sum(W_data, axis=0)
    aux1 = aux1[J0_vec[:, 0].astype(int)]

    # Condition on grid0
    match grid0:
        case "all":
            ml_indx = np.where(aux1 < n)
            mu_indx = np.where(aux1 > 0)
        case 1 | 2:
            ml_indx = np.where((aux1 < n) & (J0_vec[:, 1] == grid0))
            mu_indx = np.where(aux1 > 1)
        case _:
            raise ValueError("grid0 must be either all, 1, or 2")

    ## step 2: compute all the moment functions

    if IV_matrix is None:
        # Initialize X_data
        X_data = np.empty((n, ml_indx[0].size + mu_indx[0].size))

        # Create dummy IV vector
        Z_vec = np.ones(J0)

        for market_index in range(n):
            # Subset vector of estimated revenue differential in market i
            A_vec = A_matrix[market_index, 1:(J0+1)]
            # Subset vector of product portfolio of coca-cola and
            # energy-products in market i
            D_vec = W_data[market_index, 1:(J0+1)]

            # Compute lower and upper bounds
            ml_vec = MomentFunct_L(A_vec, D_vec, Z_vec, J0_vec, theta, Vbar)
            mu_vec = MomentFunct_U(A_vec, D_vec, Z_vec, J0_vec, theta, Vbar)

            # Create new row of X_data
            X_data[market_index, :] = np.concatenate((ml_vec[ml_indx], mu_vec[mu_indx]))

    else:
        # Initialize X_data
        X_data = np.empty((n, 4 * (ml_indx[0].size + mu_indx[0].size)))

        # Create dummy IV vector
        Z_vec = np.ones(J0)
        # employment rate
        Z3_vec = (IV_matrix[:, 1] > np.median(IV_matrix[:, 1])).astype(int)
        # average income in market
        Z5_vec = (IV_matrix[:, 2] > np.median(IV_matrix[:, 2])).astype(int)
        # median income in market
        Z7_vec = (IV_matrix[:, 3] > np.median(IV_matrix[:, 3])).astype(int)

        for market_index in range(n):
            # Subset vector of estimated revenue differential in market i
            A_vec = A_matrix[market_index, 1:J0]
            # Subset vector of product portfolio of coca-cola and
            # energy-products in market i
            D_vec = W_data[market_index, 1:J0]

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
