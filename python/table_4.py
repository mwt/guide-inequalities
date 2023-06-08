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
    "sim_name": "table_1",
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
    "CI_vec": [np.full((4, 2), np.nan) for i in range(10)],
    "comp_time": np.empty(4),
}

# Generate bootstrap indices
np.random.seed(sim["rng_seed"])
bootstrap_indices = np.random.randint(0, n, size=(sim["bootstrap_replications"], n))


# Define the constraint function
def restriction_function(theta: np.ndarray, sim_i: int):
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
        bootstrap_indices=bootstrap_indices,
        dist_data=dgp["Dist"],
    )


for sim_i in range(4):
    print("Simulation:", sim_i + 1)
    # Obtain the time at the beginning of the simulation
    tic = time.perf_counter()

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
                bounds=[(sim["lb"][sim_i, theta_index], sim["ub"][sim_i, theta_index])],
                constraints=nonlinear_constraint,
                tol=1e-8,
            )

            CI_upper = minimize(
                lambda x, i: -x[i],
                sim["x0"][sim_i, 0:6],
                args=(theta_index,),
                method="SLSQP",
                jac=lambda x, i: np.array([-1 if j == i else 0 for j in range(6)]),
                bounds=[(sim["lb"][sim_i, theta_index], sim["ub"][sim_i, theta_index])],
                constraints=nonlinear_constraint,
                tol=1e-8,
            )

            results["CI_vec"][theta_index][sim_i, 0] = CI_lower.x[theta_index]
            results["CI_vec"][theta_index][sim_i, 1] = CI_upper.x[theta_index]

    # Stop the timer
    toc = time.perf_counter()
    results["comp_time"][sim_i] = toc - tic
    print("~> time:", results["comp_time"][sim_i])


[print(results["CI_vec"][theta_index]) for theta_index in range(6)]
# Save results
# (results_dir / sim["sim_name"]).mkdir(exist_ok=True)
# for key, value in results.items():
#    np.save(results_dir / sim["sim_name"] / key, value)
#
## Make and print the table
# tableObj = tt.Texttable(0)
#
# tableObj.set_cols_align(["l", "l", "c", "c", "c"])
# tableObj.set_cols_dtype(["i", "t", "t", "t", "f"])
#
# the_table = np.array(settings["Vbar"])
# the_table = np.column_stack((the_table, settings["cv"]))
# for ci_theta in results["CI_vec"]:
#    the_table = np.column_stack(
#        (
#            the_table,
#            [
#                "[" + "{:.1f}".format(x[0]) + ", " + "{:.1f}".format(x[1]) + "]"
#                for x in ci_theta
#            ],
#        )
#    )
# the_table = np.column_stack((the_table, results["comp_time"]))
# the_table = np.vstack(
#    (
#        [
#            "$\\Bar{V}$",
#            "Crit. Value",
#            "$\\theta_1$: Coca-Cola",
#            "$\\theta_2$: Energy Brands",
#            "Comp. Time",
#        ],
#        the_table,
#    )
# )
#
# tableObj.add_rows(the_table)
# print(tableObj.draw())
#
## Save table
# with open(tables_dir / (sim["sim_name"] + ".tex"), "w", encoding="utf8") as f:
#    f.write(draw_latex(tableObj))
