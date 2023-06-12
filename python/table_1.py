""" Table 1 in Section 8.1 in Canay, Illanes and Velez (2023)
"""

import time
from pathlib import Path

import numpy as np
import texttable as tt
from joblib import Parallel, delayed
from latextable import draw_latex

import ineq_functions as ineq

# Make folders for results
results_dir = Path(__file__).resolve().parent / "_results"
tables_dir = results_dir / "tables-tex"
tables_dir.mkdir(parents=True, exist_ok=True)


def load_data(name):
    file_path = Path(__file__).resolve().parent.parent / "data" / (name + ".csv")
    return np.loadtxt(file_path, delimiter=",")


dgp = {i: load_data(i) for i in ["A", "D", "J0"]}
dgp["W"] = dgp["D"][:, 1:]
n = dgp["A"].shape[0]

settings = {
    "v_bar": [500, 500, 1000, 1000],
    "test_stat": ["CCK", "CCK", "CCK", "CCK"],
    "cv": ["SN2S", "EB2S", "SN2S", "EB2S"],
    "alpha": 0.05,
    "iv": None,
}

sim = {
    "grid_size": 1401,
    "rng_seed": 20220826,
    "bootstrap_replications": 1000,
    "num_robots": 4,
    "sim_name": "table_1",
}
sim["grid_theta"] = (
    np.linspace(-40, 100, sim["grid_size"]),
    np.linspace(-40, 100, sim["grid_size"]),
)

results = {
    "ci_vector": (np.empty((4, 2)), np.empty((4, 2))),
    "tn_vector": (np.empty((sim["grid_size"], 4)), np.empty((sim["grid_size"], 4))),
    "comp_time": np.empty(4),
}

# Generate bootstrap indices
bootstrap_indices = ineq.helpers.get_bootstrap_indices(
    n, sim["bootstrap_replications"], sim["rng_seed"]
)

for sim_i in range(4):
    print("Simulation:", sim_i + 1)
    # Obtain the time at the beginning of the simulation
    tic = time.perf_counter()
    for theta_index in range(2):
        # Step 1: find test stat. Tn(theta) and c.value(theta) using G_restriction
        def theta0(theta, theta_index):
            the_theta = np.zeros(2)
            the_theta[theta_index] = theta
            return the_theta

        output = np.array(
            Parallel(n_jobs=sim["num_robots"])(
                delayed(ineq.g_restriction)(
                    theta=theta0(theta, theta_index),
                    w_data=dgp["W"],
                    a_matrix=dgp["A"],
                    j0_vector=dgp["J0"],
                    v_bar=settings["v_bar"][sim_i],
                    alpha=settings["alpha"],
                    grid0=theta_index + 1,
                    iv_matrix=settings["iv"],
                    test0=settings["test_stat"][sim_i],
                    cvalue=settings["cv"][sim_i],
                    bootstrap_indices=bootstrap_indices,
                )
                for theta in sim["grid_theta"][theta_index]
            )
        )

        # Because g_function returns a list, and Parallel returns it's runs in
        # a list, test_vec and cv_vec are the columns of the output matrix!
        test_vec = output[:, 0]
        cv_vec = output[:, 1]

        # Theta values for which the null is not rejected
        cs_vec = sim["grid_theta"][theta_index][test_vec <= cv_vec]

        # Create results objects
        results["tn_vector"][theta_index][:, sim_i] = test_vec

        if len(cs_vec) == 0:
            # it may be the CI is empty
            results["ci_vector"][theta_index][sim_i,] = [
                np.NaN,
                sim["grid_theta"][theta_index][test_vec.argmin()],
            ]
        else:
            results["ci_vector"][theta_index][sim_i,] = [cs_vec.min(), cs_vec.max()]

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

tableObj.set_cols_align(["l", "l", "c", "c", "c"])
tableObj.set_cols_dtype(["i", "t", "t", "t", "f"])

the_table = np.array(settings["v_bar"])
the_table = np.column_stack((the_table, settings["cv"]))
for ci_theta in results["ci_vector"]:
    the_table = np.column_stack(
        (
            the_table,
            [
                "[" + "{:.1f}".format(x[0]) + ", " + "{:.1f}".format(x[1]) + "]"
                for x in ci_theta
            ],
        )
    )
the_table = np.column_stack((the_table, results["comp_time"]))
the_table = np.vstack(
    (
        [
            "$\\Bar{V}$",
            "Crit. Value",
            "$\\theta_1$: Coca-Cola",
            "$\\theta_2$: Energy Brands",
            "Comp. Time",
        ],
        the_table,
    )
)

tableObj.add_rows(the_table)
print(tableObj.draw())

# Save table
with open(tables_dir / (sim["sim_name"] + ".tex"), "w", encoding="utf8") as f:
    f.write(draw_latex(tableObj))
