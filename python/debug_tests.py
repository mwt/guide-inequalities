from pathlib import Path

import numpy as np

import ineq_functions as ineq


def load_data(name):
    file_path = Path(__file__).resolve().parent.parent / "data" / (name + ".csv")
    return np.loadtxt(file_path, delimiter=",")


A_matrix = load_data("A")
D_matrix = load_data("D")
IV_matrix = load_data("IV")
J0_vec = load_data("J0")
W_data = D_matrix[:, 1:]
Vbar = 0
theta = np.array([7, 12])
alpha = 0.05
bootstrap_indices = load_data("random").astype(int)
bootstrap_indices = bootstrap_indices.T - 1
num_boots = bootstrap_indices.shape[0]

print("No IV, CCK, SN")
print(
    ineq.g_restriction(
        W_data,
        A_matrix,
        theta,
        J0_vec,
        Vbar,
        None,
        1,
        "CCK",
        "SN",
        alpha,
        bootstrap_indices=bootstrap_indices,
    )
)
print("No IV, CCK, SN2S")
print(
    ineq.g_restriction(
        W_data,
        A_matrix,
        theta,
        J0_vec,
        Vbar,
        None,
        1,
        "CCK",
        "SN2S",
        alpha,
        bootstrap_indices=bootstrap_indices,
    )
)
print("No IV, CCK, EB2S")
print(
    ineq.g_restriction(
        W_data,
        A_matrix,
        theta,
        J0_vec,
        Vbar,
        None,
        1,
        "CCK",
        "EB2S",
        alpha,
        bootstrap_indices=bootstrap_indices,
    )
)
print("No IV, RC-CCK, SPUR1")
print(
    ineq.g_restriction(
        W_data,
        A_matrix,
        theta,
        J0_vec,
        Vbar,
        None,
        1,
        "RC-CCK",
        "SPUR1",
        alpha,
        bootstrap_indices=bootstrap_indices,
        An_vec=np.zeros(num_boots),
        hat_r_inf=0,
    )
)

# X_data = ineq.m_function(W_data, A_matrix, theta, J0_vec, Vbar, None, 1)
# n = X_data.shape[0]  # sample size
# kappa_n = np.sqrt(np.log(n))  # tuning parameter
# std_b0 = ineq.std_b_vec(X_data=X_data, bootstrap_indices=bootstrap_indices)
# std_b1 = std_b0[0, :]
# tn_vec = ineq.tn_star(X_data, std_b1, kappa_n, bootstrap_indices=bootstrap_indices)
# mhatstar_vec = ineq.m_hat(X_data[bootstrap_indices, :], axis=1)
# print(tn_vec[0, :])

# print("M hat")
# print(ineq.m_hat(ineq.m_function(W_data, A_matrix, theta, J0_vec, Vbar, None, "all")))
