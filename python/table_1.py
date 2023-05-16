import time
from pathlib import Path

import numpy as np
import texttable as tt

import ineq_functions as ineq


def load_data(name):
    file_path = Path(__file__).resolve().parent.parent / "data" / (name + ".csv")
    return np.loadtxt(file_path, delimiter=",")


dgp = {i: load_data(i) for i in ["A", "D", "J0"]}
dgp["W"] = dgp["D"][:, 1:]

settings = {
    "Vbar": [500, 500, 1000, 1000],
    "test_stat": ["CCK", "CCK", "CCK", "CCK"],
    "cv": ["SN2S", "EB2S", "SN2S", "EB2S"],
    "alpha": [0.05, 0.05, 0.05, 0.05],
    "IV": [None, None, None, None],
}

sim = {
    "grid_size": 1401,
    "rng_seed": 20220826,
    "num_boots": 1000,
    "sim_name": "table_1",
}
sim["grid_theta"] = (
    np.linspace(-40, 100, sim["grid_size"]),
    np.linspace(-40, 100, sim["grid_size"]),
)

results = {
    "CI_vec": (np.empty((4, 2)), np.empty((4, 2))),
    "Tn_vec": (np.empty((sim["grid_size"], 4)), np.empty((sim["grid_size"], 4))),
    "comp_time": np.empty(4),
}

for sim0 in range(4):
    print("Simulation:", sim0 + 1)
    # Obtain the time at the beginning of the simulation
    tic = time.perf_counter()
    for theta_index in range(2):
        reject_H = np.empty(sim["grid_size"])
        Test_vec = np.empty(sim["grid_size"])
        cv_vec = np.empty(sim["grid_size"])

        # Step 1: find test stat. Tn(theta) and c.value(theta) using G_restriction

        for i, theta in enumerate(sim["grid_theta"][theta_index]):
            theta0 = np.zeros(2)
            theta0[theta_index] = theta

            Test_vec[i], cv_vec[i] = ineq.g_restriction(
                W_data=dgp["W"],
                A_matrix=dgp["A"],
                theta0=theta0,
                J0_vec=dgp["J0"],
                Vbar=settings["Vbar"][sim0],
                IV_matrix=settings["IV"][sim0],
                grid0=theta_index + 1,
                test0=settings["test_stat"][sim0],
                cvalue=settings["cv"][sim0],
                alpha=settings["alpha"][sim0],
                num_boots=sim["num_boots"],
                rng_seed=sim["rng_seed"],
            )

        # reject_H = (Test_vec > cv_vec)

        # Theta values for which the null is not rejected
        CS_vec = sim["grid_theta"][theta_index][Test_vec <= cv_vec]

        # Create results objects
        results["Tn_vec"][theta_index][:, sim0] = Test_vec

        if len(CS_vec) == 0:
            # it may be the CI is empty
            results["CI_vec"][theta_index][sim0,] = [np.NaN, np.NaN]
            # in this case, we report [nan, argmin test statistic]
            results["CI_vec"][theta_index][sim0, 2] = np.min(
                sim["grid_theta"][theta_index]
            )
        else:
            results["CI_vec"][theta_index][sim0,] = [np.min(CS_vec), np.max(CS_vec)]

    # Stop the timer
    toc = time.perf_counter()
    results["comp_time"][sim0] = toc - tic
    print("~> time:", results["comp_time"][sim0])

# Make and print the table
tableObj = tt.Texttable(0)

tableObj.set_cols_align(["l", "c", "c", "c"])
tableObj.set_cols_dtype(["i", "t", "t", "f"])

the_table = np.array(settings["Vbar"])
for ci_theta in results["CI_vec"]:
    the_table = np.column_stack(
        (
            the_table,
            np.apply_along_axis(
                lambda x: "["
                + "{:.2f}".format(x[0])
                + ", "
                + "{:.2f}".format(x[1])
                + "]",
                1,
                ci_theta,
            ),
        )
    )
the_table = np.column_stack((the_table, results["comp_time"]))
the_table = np.vstack(
    (
        [
            "$\\Bar{V}$",
            "$\\theta_1$: Coca-Cola",
            "$\\theta_2$: Energy Brands",
            "Comp. Time",
        ],
        the_table,
    )
)

tableObj.add_rows(the_table)

print(tableObj.draw())
