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
    "Vbar": [500, 500, 1000, 1000],
    "test_stat": ["CCK", "CCK", "CCK", "CCK"],
    "cv": ["SN2S", "EB2S", "SN2S", "EB2S"],
    "alpha": 0.05,
    "IV": None,
}

sim = {
    "rng_seed": 20220826,
    "bootstrap_replications": 1000,
    "num_robots": 4,
    "sim_name": "table_b2",
}
sim["grid_theta"] = np.swapaxes(np.mgrid[-40:101, -40:101], 0, 2).reshape(-1, 2)
sim["grid_size"] = sim["grid_theta"].shape[0]  # number of theta values: 19881
sim["dim_theta"] = sim["grid_theta"].shape[1]  # dimension of theta: 2

results = {
    "CI_vec": (np.empty((4, 2)), np.empty((4, 2))),
    "Tn_vec": (np.empty((sim["grid_size"], 4)), np.empty((sim["grid_size"], 4))),
    "comp_time": np.empty(4),
}

# Generate bootstrap indices
np.random.seed(sim["rng_seed"])
bootstrap_indices = np.random.randint(0, n, size=(sim["bootstrap_replications"], n))

for sim_i in range(4):
    print("Simulation:", sim_i + 1)
    # Obtain the time at the beginning of the simulation
    tic = time.perf_counter()

    output = np.array(
        Parallel(n_jobs=sim["num_robots"])(
            delayed(ineq.g_restriction)(
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
            )
            for theta in sim["grid_theta"]
        )
    )

    # Because g_function returns a list, and Parallel returns it's runs in
    # a list, test_vec and cv_vec are the columns of the output matrix!
    Test_vec = output[:, 0]
    cv_vec = output[:, 1]

    # Theta values for which the null is not rejected
    CS_vec = sim["grid_theta"][Test_vec <= cv_vec, :]

    for theta_index in range(sim["dim_theta"]):
        # Create results objects
        results["Tn_vec"][theta_index][:, sim_i] = Test_vec

        if CS_vec.shape[0] == 0:
            # it may be the CI is empty
            results["CI_vec"][theta_index][sim_i,] = [
                np.NaN,
                sim["grid_theta"][theta_index][np.argmin(Test_vec)],
            ]
        else:
            results["CI_vec"][theta_index][sim_i,] = [
                CS_vec[:, theta_index].min(),
                CS_vec[:, theta_index].max(),
            ]

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

the_table = np.array(settings["Vbar"])
the_table = np.column_stack((the_table, settings["cv"]))
for ci_theta in results["CI_vec"]:
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
