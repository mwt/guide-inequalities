# Table 2 in Section 8.2.1 in Canay, Illanes and Velez (2023)

if (!dir.exists("_results")) {
  dir.create("_results")
}

# Import packages and functions
require(readr)
require(tictoc)
require(foreach)
require(Rfast)
require(Rfast2)
require(foreach)
require(doParallel)
require(xtable)
# Quick hack to load functions (temporary)
invisible(lapply(
  list.files(
    path = "1_functions",
    full.names = T,
    pattern = "\\.R$"
  ),
  source
))

# Import data
datasets <- c("A", "D", "IV", "J0")
data_path <- file.path("..", "data")
dgp <- sapply(datasets, function(dataset) {
  unname(as.matrix(readr::read_csv(
    file.path(data_path, paste0(dataset, ".csv")),
    col_names = F,
    show_col_types = F
  )))
}, simplify = F)
dgp$W_data <- dgp$D[, -1]

# Settings (cell arrays are used to loop over each of the four different specifications)
settings <- list(
  # Vbar is defined in Assumption 4.2 and appears in eq. (26)-(27).
  Vbar = c(500, 500, 1000, 1000),
  # CCK as in eq. (38).
  test_stat = rep("CCK", 4),
  # Critical values as in eq. (41) and (47).
  cv = rep(c("SN2S", "EB2S"), 2),
  # significance level
  alpha = 0.05,
  # no IVs
  IV = dgp$IV
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
  sim_name = "table_2"
)

results <- list(
  CI_vec = list(matrix(NA, 4, 2), matrix(NA, 4, 2)),
  Tn_vec = lapply(sim$grid_theta, function(grid) {
    matrix(NA, nrow = length(grid), ncol = 4)
  }),
  comp_time = rep(NA, 4)
)

# Generate bootstrap indices
# number of markets
n <- nrow(dgp$A)
set.seed(sim$rng_seed, kind = "Mersenne-Twister")
bootstrap_indices <- sample.int(n, n * sim$bootstrap_replications, replace = T)

# Parallel computing
cl <- parallel::makePSOCKcluster(sim$num_robots)
doParallel::registerDoParallel(cl)

## 2 Computation
#  two steps:
#             i) compute test statistic and critical value
#            ii) conlist() confidence interevals

for (sim0 in 1:4) {
  tictoc::tic(paste("Simulation", sim0))

  for (theta_index in 1:2) {
    # Temporary in-loop variables (for each theta)
    gridsize <- length(sim$grid_theta[[theta_index]])

    # Step 1: find test stat. Tn(theta) and c.value(theta) using G_restriction
    test_H0 <- foreach::foreach(
      theta_i = sim$grid_theta[[theta_index]],
      .combine = "rbind"
    ) %dopar% {
      theta <- numeric(2)
      theta[theta_index] <- theta_i

      # test_H0: [T_n, c_value]
      G_restriction(
        W_data = dgp$W_data,
        A_matrix = dgp$A,
        theta = theta,
        J0_vec = dgp$J0,
        Vbar = settings$Vbar[sim0],
        IV_matrix = settings$IV,
        grid0 = theta_index,
        test0 = settings$test_stat[sim0],
        cvalue = settings$cv[sim0],
        alpha = settings$alpha,
        bootstrap_indices = bootstrap_indices,
      )
    }

    Test_vec <- test_H0[, 1]
    cv_vec <- test_H0[, 2]

    results$Tn_vec[[theta_index]][, sim0] <- Test_vec

    # Step 2: find confidence intervals using Tn(theta) and c[['value']](theta)

    # Theta values for which the null is not rejected
    CS_vec <- sim$grid_theta[[theta_index]][Test_vec <= cv_vec]


    if (length(CS_vec) == 0) {
      # it may be the CI is empty
      # in this case, we report [nan, argmin test statistic]
      results$CI_vec[[theta_index]][sim0, ] <- c(
        NaN,
        sim$grid_theta[[theta_index]][which.min(Test_vec)]
      )
    } else {
      results$CI_vec[[theta_index]][sim0, ] <- c(min(CS_vec), max(CS_vec))
    }
  }

  # Stop the timer
  temp_timer <- tictoc::toc()
  results$comp_time[sim0] <- temp_timer$toc - temp_timer$tic
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
formated_CI <- sapply(results$CI_vec, function(CI_mat) {
  apply(CI_mat, 1, function(CI_row) {
    paste0("[", CI_row[1], ", ", CI_row[2], "]")
  })
})

# Make table as matrix
the_table <- cbind(
  settings$Vbar,
  settings$cv,
  formated_CI,
  sprintf("%.2f", results$comp_time)
)

# Add colnames
colnames(the_table) <- c(
  "$\\Bar{V}$",
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
