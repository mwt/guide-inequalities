""" Table 1 in Section 8.1 in Canay, Illanes and Velez (2023)
"""

import time
from pathlib import Path

import numpy as np
import texttable as tt
from latextable import draw_latex
from scipy.optimize import NonlinearConstraint, minimize

import ineq_functions as ineq

# Make folders for results
results_dir = Path(__file__).resolve().parent / "_results"
tables_dir = results_dir / "tables-tex"
tables_dir.mkdir(parents=True, exist_ok=True)


def load_data(name):
    file_path = Path(__file__).resolve().parent.parent / "data" / (name + ".csv")
    return np.loadtxt(file_path, delimiter=",")


dgp = {i: load_data(i) for i in ["A", "D", "J0", "Dist"]}
dgp["Dist"] = dgp["Dist"] / 1000  # Rescale the distance
dgp["W"] = dgp["D"][:, 1:]
n = dgp["A"].shape[0]

settings = {
    "Vbar": [500, 500, 1000, 1000],
    "test_stat": ["CCK", "CCK", "CCK", "CCK"],
    "cv": ["SN", "SN", "SN", "SN"],
    "alpha": 0.05,
    "IV": None,
}

sim = {
    "grid_size": 1401,
    "rng_seed": 20220826,
    "bootstrap_replications": 1000,
    "sim_name": "table_4",
    "lb": np.array(
        [
            [-40, -20, 0, -40, -20, 0, 0, 0],
            [-40, -20, -10, -40, -20, -10, 0, 0],
            [-40, -20, 0, -40, -20, 0, 0, 0],
            [-40, -20, -10, -40, -20, -10, 0, 0],
        ]
    ),
    "ub": np.array(
        [
            [100, 50, 0, 100, 50, 0, 3, 2],
            [100, 50, 10, 100, 50, 10, 3, 2],
            [100, 50, 0, 100, 50, 0, 3, 2],
            [100, 50, 10, 100, 50, 10, 3, 2],
        ]
    ),
}
sim["x0"] = np.zeros((4, 8))

results = {
    "CI_vec": [np.full((4, 2), np.nan) for i in range(8)],
    "comp_time": np.empty(4),
}

# Generate bootstrap indices
np.random.seed(sim["rng_seed"])
bootstrap_indices = np.random.randint(0, n, size=(sim["bootstrap_replications"], n))


# Define the constraint function
def restriction_function(
    theta: np.ndarray, sim_i: int, account_uncertainty: bool = False
):
    """Wrapper function for :func:`g_restriction` to be used with scipy.optimize"""
    if theta.shape == (1,):
        raise ValueError("theta must be a 1d array")
    # Return the difference between the critical value and test stat
    return -ineq.g_restriction_diff(
        theta=theta,
        W_data=dgp["W"],
        A_matrix=dgp["A"],
        J0_vec=dgp["J0"],
        Vbar=settings["Vbar"][sim_i],
        IV_matrix=settings["IV"],
        grid0="all",
        alpha=settings["alpha"],
        test0=settings["test_stat"][sim_i],
        cvalue=settings["cv"][sim_i],
        account_uncertainty=account_uncertainty,
        bootstrap_indices=bootstrap_indices,
        dist_data=dgp["Dist"],
    )


for sim_i in range(4):
    print("Simulation:", sim_i + 1)
    # Obtain the time at the beginning of the simulation
    tic = time.perf_counter()

    # Six dimensional theta confidence intervals
    for theta_index in range(6):
        # Define the nonlinear constraint
        nonlinear_constraint = {
            "type": "ineq",
            "fun": restriction_function,
            "args": (sim_i,),
        }

        if sim["lb"][sim_i, theta_index] == sim["ub"][sim_i, theta_index]:
            # If the bounds are equal, then theta is fixed
            results["CI_vec"][theta_index][sim_i, 0] = sim["lb"][sim_i, theta_index]
            results["CI_vec"][theta_index][sim_i, 1] = sim["ub"][sim_i, theta_index]
        else:
            # Call the optimization routine
            CI_lower = minimize(
                lambda x, i: x[i],
                x0=sim["x0"][sim_i, 0:6],
                args=(theta_index,),
                method="SLSQP",
                jac=lambda x, i: np.array([1 if j == i else 0 for j in range(6)]),
                bounds=[
                    (sim["lb"][sim_i, t_i], sim["ub"][sim_i, t_i]) for t_i in range(6)
                ],
                constraints=nonlinear_constraint,
                tol=1e-8,
            )

            CI_upper = minimize(
                lambda x, i: -x[i],
                sim["x0"][sim_i, 0:6],
                args=(theta_index,),
                method="SLSQP",
                jac=lambda x, i: np.array([-1 if j == i else 0 for j in range(6)]),
                bounds=[
                    (sim["lb"][sim_i, t_i], sim["ub"][sim_i, t_i]) for t_i in range(6)
                ],
                constraints=nonlinear_constraint,
                tol=1e-8,
            )

            results["CI_vec"][theta_index][sim_i, 0] = CI_lower.x[theta_index]
            results["CI_vec"][theta_index][sim_i, 1] = CI_upper.x[theta_index]

    # Two dimensional theta confidence intervals accounting for uncertainty
    for theta_index in range(2):
        # Define the nonlinear constraint (this time accounting for uncertainty)
        nonlinear_constraint = {
            "type": "ineq",
            "fun": restriction_function,
            "args": (sim_i, True),  # True: account for uncertainty
        }

        # Call the optimization routine
        CI_lower = minimize(
            lambda x, i: np.sum(x[(i * 3) : ((i + 1) * 3)]) * x[6 + i],
            x0=sim["x0"][sim_i],
            args=(theta_index,),
            method="SLSQP",
            jac=lambda x, i: np.array(
                [x[6 + i] if (i * 3) <= j < ((i + 1) * 3) else 0 for j in range(6)]
                + [
                    np.sum(x[(i * 3) : ((i + 1) * 3)]) if j == 6 + i else 0
                    for j in range(6, 8)
                ]
            ),
            bounds=[(sim["lb"][sim_i, t_i], sim["ub"][sim_i, t_i]) for t_i in range(8)],
            constraints=nonlinear_constraint,
            tol=1e-8,
        )

        CI_upper = minimize(
            lambda x, i: -np.sum(x[(i * 3) : ((i + 1) * 3)]) * x[6 + i],
            sim["x0"][sim_i],
            args=(theta_index,),
            method="SLSQP",
            jac=lambda x, i: -np.array(
                [x[6 + i] if (i * 3) <= j < ((i + 1) * 3) else 0 for j in range(6)]
                + [
                    np.sum(x[(i * 3) : ((i + 1) * 3)]) if j == 6 + i else 0
                    for j in range(6, 8)
                ]
            ),
            bounds=[(sim["lb"][sim_i, t_i], sim["ub"][sim_i, t_i]) for t_i in range(8)],
            constraints=nonlinear_constraint,
            tol=1e-8,
        )

        results["CI_vec"][theta_index + 6][sim_i, 0] = CI_lower.x[theta_index]
        results["CI_vec"][theta_index + 6][sim_i, 1] = CI_upper.x[theta_index]

    # Stop the timer
    toc = time.perf_counter()
    results["comp_time"][sim_i] = toc - tic
    print("~> time:", results["comp_time"][sim_i])

# Save results
(results_dir / sim["sim_name"]).mkdir(exist_ok=True)
for key, value in results.items():
    np.save(results_dir / sim["sim_name"] / key, value)

# Make and print the table
tableObj = tt.Texttable(0)

# tableObj.set_cols_align(["c", "c", "c", "c", "c", "c"])
# tableObj.set_cols_dtype(["t", "t", "t", "t", "t", "t"])
#
the_table = np.array(["Coca-", "Cola", "", "", "Energy", "Brands", "", ""])
the_table = np.column_stack(
    (
        the_table,
        np.array(
            [
                f"$\\theta_{{{i},{j}}}$" if j < 4 else f"$\\theta_{{{i}}}$"
                for i in range(1, 3)
                for j in range(1, 5)
            ]
        ),
    )
)

sub_table = []
for ci_theta in results["CI_vec"]:
    sub_table += [
        [
            "[" + "{:.1f}".format(x[0]) + ", " + "{:.1f}".format(x[1]) + "]"
            for x in ci_theta
        ]
    ]

# the order has the theta_1(mu) and theta_2(mu) at the end
sorted_sub_table = np.array(sub_table)[[0, 1, 2, 6, 3, 4, 5, 7], :]
the_table = np.column_stack((the_table, sorted_sub_table))
the_table = np.vstack(
    (
        ["", "Parameter", "Linear", "Quadratic", "Linear", "Quadratic"],
        the_table,
        ["Comp. Time", ""] + list(results["comp_time"]),
    )
)

tableObj.add_rows(the_table)
print(tableObj.draw())

# Save table
with open(tables_dir / (sim["sim_name"] + ".tex"), "w", encoding="utf8") as f:
    f.write(draw_latex(tableObj))
