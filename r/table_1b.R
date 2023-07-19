# Table 1 in Section 8.1 in Canay, Illanes and Velez (2023)

if (!dir.exists("_results")) {
  dir.create("_results")
}

# Import packages and functions
library(readr)
library(tictoc)
library(Rfast)
library(Rfast2)
library(foreach)
library(doParallel)
library(xtable)
library(devtools)

# Install and import package
devtools::install("ineqfunctions", upgrade = "never")

# Import data
datasets <- c("A", "D", "J0")
data_path <- file.path("..", "data")
dgp <- sapply(datasets, function(dataset) {
  unname(as.matrix(readr::read_csv(
    file.path(data_path, paste0(dataset, ".csv")),
    col_names = F,
    show_col_types = F
  )))
}, simplify = F)
dgp$W <- dgp$D[, -1]
# number of markets
n <- nrow(dgp$A)

# Settings (cell arrays are used to loop over each of the four different specifications)
settings <- list(
  # v_bar is defined in Assumption 4.2 and appears in eq. (26)-(27).
  v_bar = c(500, 500, 1000, 1000),
  # CCK as in eq. (38).
  test_stat = rep("CCK", 4),
  # Critical values as in eq. (41) and (47).
  cv = rep(c("SN2S", "EB2S"), 2),
  # significance level
  alpha = 0.05,
  # no IVs
  iv = NULL
)

# Technical settings (lists are used to loop over the two parameters: theta1 and theta2)
sim <- list(
  grid_theta = list(
    seq(
      from = -40,
      to = 100,
      length.out = 1401
    ),
    seq(
      from = -40,
      to = 100,
      length.out = 1401
    )
  ),
  rng_seed = 20220826,
  bootstrap_replications = 1000,
  num_robots = 4,
  sim_name = "table_1b"
)

results <- list(
  ci_vector = list(matrix(NA, 4, 2), matrix(NA, 4, 2)),
  tn_vector = lapply(sim$grid_theta, function(grid) {
    matrix(NA, nrow = length(grid), ncol = 4)
  }),
  comp_time = rep(NA, 4)
)

# Generate bootstrap indices
bootstrap_indices <- ineqfunctions::get_bootstrap_indices(
  n, sim$bootstrap_replications, sim$rng_seed
)

# Parallel computing
cl <- parallel::makePSOCKcluster(sim$num_robots)
doParallel::registerDoParallel(cl)

## 2 Computation
#  two steps:
#             i) compute test statistic and critical value
#            ii) conlist() confidence interevals

for (sim_i in 1:4) {
  tictoc::tic(paste("Simulation", sim_i))

  for (theta_index in 1:2) {
    # Temporary in-loop variables (for each theta)
    gridsize <- length(sim$grid_theta[[theta_index]])

    # Step 1: find test stat. Tn(theta) and c.value(theta) using g_restriction
    output <- foreach::foreach(
      theta_i = sim$grid_theta[[theta_index]],
      .combine = "rbind"
    ) %dopar% {
      theta <- numeric(2)
      theta[theta_index] <- theta_i

      # output: [T_n, c_value]
      ineqfunctions::g_restriction(
        theta = theta,
        w_data = dgp$W,
        a_matrix = dgp$A,
        j0_vector = dgp$J0,
        v_bar = settings$v_bar[sim_i],
        alpha = settings$alpha,
        grid0 = theta_index,
        test0 = settings$test_stat[sim_i],
        cvalue = settings$cv[sim_i],
        iv_matrix = settings$iv,
        bootstrap_indices = bootstrap_indices,
      )
    }

    test_vec <- output[, 1]
    cv_vec <- output[, 2]

    results$tn_vector[[theta_index]][, sim_i] <- test_vec

    # Step 2: find confidence intervals using Tn(theta) and c[['value']](theta)

    # Theta values for which the null is not rejected
    cs_vec <- sim$grid_theta[[theta_index]][test_vec <= cv_vec]


    if (length(cs_vec) == 0) {
      # it may be the CI is empty
      # in this case, we report [nan, argmin test statistic]
      results$ci_vector[[theta_index]][sim_i, ] <- c(
        NaN,
        sim$grid_theta[[theta_index]][which.min(test_vec)]
      )
    } else {
      results$ci_vector[[theta_index]][sim_i, ] <- c(min(cs_vec), max(cs_vec))
    }
  }

  # Stop the timer
  temp_timer <- tictoc::toc()
  results$comp_time[sim_i] <- temp_timer$toc - temp_timer$tic
}

# Stop parallel computing
stopImplicitCluster()

## 3 Save results
save(results, file = file.path("_results", paste0(sim$sim_name, ".Rdata")))


# save(fullfile('_results', strcat(sim[['sim_name']], '.mat')), 'dgp', 'settings', 'sim', 'results')
#
## 4 Print table
table_dir <- file.path("_results", "tables-tex")
if (!dir.exists(table_dir)) {
  dir.create(table_dir)
}

# Format CI as [lb, ub]
formatted_ci <- sapply(results$ci_vector, function(ci_theta) {
  apply(ci_theta, 1, function(x) {
    paste0("[", sprintf("%.1f", x[1]), ", ", sprintf("%.1f", x[2]), "]")
  })
})

# Make table as matrix
the_table <- cbind(
  settings$v_bar,
  settings$cv,
  formatted_ci,
  sprintf("%.2f", results$comp_time)
)

# Add colnames
colnames(the_table) <- c(
  "$\\bar{V}$",
  "Crit. Value",
  "$\\theta_1$: Coca-Cola",
  "$\\theta_2$: Energy Brands",
  "Comp. Time"
)

# Save the table
print(
  xtable(the_table, digits = 4),
  include.rownames = FALSE,
  sanitize.colnames.function = identity,
  file = file.path(table_dir, paste0(sim$sim_name, ".tex"))
)
