from pathlib import Path

import numpy as np
from joblib import Parallel, delayed

import ineq_functions as ineq


def load_data(name):
    file_path = Path(__file__).resolve().parent.parent / "data" / (name + ".csv")
    return np.loadtxt(file_path, delimiter=",")


A_matrix = load_data("A")
D_matrix = load_data("D")
Dist_matrix = load_data("Dist") / 1000
IV_matrix = load_data("IV")
j0_vector = load_data("J0")
W_data = D_matrix[:, 1:]
Vbar = 0
theta = np.array([7, 12])
theta6 = np.array([1, 2, 3, 4, 5, 6])
alpha = 0.05
bootstrap_indices = load_data("random").astype(int)
bootstrap_indices = bootstrap_indices.T - 1
num_boots = bootstrap_indices.shape[0]

print("No IV, CCK, SN")
print(
    ineq.g_restriction(
        theta,
        W_data,
        A_matrix,
        j0_vector,
        Vbar,
        None,
        1,
        alpha,
        "CCK",
        "SN",
        bootstrap_indices=bootstrap_indices,
    )
)
print("No IV, CCK, SN2S")
print(
    ineq.g_restriction(
        theta,
        W_data,
        A_matrix,
        j0_vector,
        Vbar,
        None,
        1,
        alpha,
        "CCK",
        "SN2S",
        bootstrap_indices=bootstrap_indices,
    )
)
print("No IV, CCK, EB2S")
print(
    ineq.g_restriction(
        theta,
        W_data,
        A_matrix,
        j0_vector,
        Vbar,
        None,
        1,
        alpha,
        "CCK",
        "EB2S",
        bootstrap_indices=bootstrap_indices,
    )
)
print("No IV, RC-CCK, SPUR1")
print(
    ineq.g_restriction(
        theta,
        W_data,
        A_matrix,
        j0_vector,
        Vbar,
        None,
        1,
        alpha,
        "RC-CCK",
        "SPUR1",
        bootstrap_indices=bootstrap_indices,
        An_vec=np.zeros(num_boots),
        hat_r_inf=0,
    )
)

print("G restriction fmin")
print(
    ineq.g_restriction_diff(
        theta6,
        W_data,
        A_matrix,
        j0_vector,
        Vbar,
        None,
        "all",
        alpha,
        "CCK",
        "SN",
        bootstrap_indices=bootstrap_indices,
        dist_data=Dist_matrix,
    )
)

# grid_theta = np.linspace(-40, 100, 1401)
# X_data = ineq.m_function(W_data, A_matrix, theta, j0_vector, Vbar, None, 1)
# n = X_data.shape[0]  # sample size
# kappa_n = np.sqrt(np.log(n))  # tuning parameter

# b0_vec = ineq.std_b_vec(X_data, bootstrap_indices=bootstrap_indices)
# std_b1 = b0_vec[0, :]
# std_b2 = b0_vec[1, :]
# std_b3 = b0_vec[2, :]

# rhat_vec = np.array(
#     Parallel(n_jobs=-1)(
#         delayed(ineq.rhat)(
#             W_data, A_matrix, np.array([theta, 0]), j0_vector, Vbar, None, 1
#         )
#         for theta in grid_theta
#     )
# )
# hat_r_inf = 0.22314601534719314
#
# an_star = ineq.an_star(
#     X_data, std_b2, std_b3, kappa_n, hat_r_inf, bootstrap_indices=bootstrap_indices
# )
# print("an_star")
# print(an_star)

# std_b0 = ineq.std_b_vec(X_data=X_data, bootstrap_indices=bootstrap_indices)
# std_b1 = std_b0[0, :]
# tn_vec = ineq.tn_star(X_data, std_b1, kappa_n, bootstrap_indices=bootstrap_indices)
# mhatstar_vec = ineq.m_hat(X_data[bootstrap_indices, :], axis=1)
# print(tn_vec[0, :])

# print("M hat")
# print(ineq.m_hat(ineq.m_function(W_data, A_matrix, theta, j0_vector, Vbar, None, "all")))
