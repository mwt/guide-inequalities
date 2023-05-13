from pathlib import Path

import numpy as np
import scipy as sp

import ineq_functions as ineq


def load_data(name):
    file_path = Path(__file__).resolve().parent.parent / "data" / (name + ".csv")
    return np.loadtxt(file_path, delimiter=",")


A_matrix = load_data("A")
D_matrix = load_data("D")
IV_matrix = load_data("IV")
J0_vec = load_data("J0")
num_market = np.shape(A_matrix)[0]
num_product = np.shape(D_matrix)[0] - 1
W_data = D_matrix[:, :-1]
Vbar = 500
theta0 = np.array([7, 12])
alpha = 0.05
rng_seed = 20220826
num_boots = 1000

print("No IV, CCK, SN")
print(
    ineq.G_restriction(
        W_data,
        A_matrix,
        theta0,
        J0_vec,
        Vbar,
        None,
        1,
        "CCK",
        "SN",
        alpha,
        num_boots,
        rng_seed,
    )
)
print("No IV, CCK, SN2S")
print(
    ineq.G_restriction(
        W_data,
        A_matrix,
        theta0,
        J0_vec,
        Vbar,
        None,
        1,
        "CCK",
        "SN2S",
        alpha,
        num_boots,
        rng_seed,
    )
)
print("No IV, CCK, EB2S")
print(
    ineq.G_restriction(
        W_data,
        A_matrix,
        theta0,
        J0_vec,
        Vbar,
        None,
        1,
        "CCK",
        "EB2S",
        alpha,
        num_boots,
        rng_seed,
    )
)

print("M hat")
print(ineq.m_hat(ineq.m_function(W_data, A_matrix, theta0, J0_vec, Vbar, None, "all")))
