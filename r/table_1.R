# Table 1 in Section 8.1 in Canay, Illanes and Velez (2023)

# Inputs

# ../data/                               fake data
#  - A[['csv']]               n  x (1+J0)     matrix of revenue differential
#  - D[['csv']]               n  x (1+J)      matrix of all product portfolio
#  - J0[['csv']]              J0 x 2          matrix of ownership by two firms

# G_restriction[['m']]                        find test statistic and c. value
#  - m_function                          compute (26)-(27)
#  - m_hat                               compute a version of (38)
#  - cvalue_SN2S                         compute c. value as in (41)
#  - cvalue_EB2S                         compute c. value as in (48)

# output

# '_results/tables-tex/table_1[['time']]'       confidence intervals and comp[['time']]

# comment:
# the first column of A_matrix and D_matrix were used to index the markets,
# these first columns are useless in the rest of the code.
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
datasets <- c("A", "D", "J0")
data_path <- file.path("..", "data")
dgp <- sapply(datasets, function(dataset) {
  unname(as.matrix(readr::read_csv(
    file.path(data_path, paste0(dataset, ".csv")),
    col_names = F,
    show_col_types = F
  )))
}, simplify = F)

dgp$num_market <- nrow(dgp$A)
dgp$num_product <- nrow(dgp$D) - 1
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
  alpha = rep(0.05, 4),
  # no IVs
  IV = NULL
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
  num_boots = 1000,
  num_robots = 4,
  sim_name = "table_1"
)

results <- list(
  CI_vec = list(matrix(NA, 4, 2), matrix(NA, 4, 2)),
  Tn_vec = lapply(sim$grid_theta, function(grid) {
    matrix(NA, nrow = length(grid), ncol = 4)
  }),
  comp_time = rep(NA, 4)
)

# Parallel computing
cl <- parallel::makePSOCKcluster(sim$num_robots)
doParallel::registerDoParallel(cl)

## 2 Computation
#  two steps:
#             i) compute test statistic and critical value
#            ii) conlist() confidence interevals

for (sim0 in 1:4) {
  tictoc::tic(paste0("case ", sim0))

  for (theta_index in 1:2) {
    # Temporary in-loop variables (for each theta)
    gridsize <- length(sim$grid_theta[[theta_index]])

    # Step 1: find test stat. Tn(theta) and c.value(theta) using G_restriction
    test_H0 <- foreach::foreach(
      theta = sim$grid_theta[[theta_index]],
      .combine = "rbind"
    ) %dopar% {
      theta0 <- numeric(2)
      theta0[theta_index] <- theta

      # test_H0: [T_n, c_value]
      G_restriction(
        W_data = dgp$W_data,
        A_matrix = dgp$A,
        theta0 = theta0,
        J0_vec = dgp$J0,
        Vbar = settings$Vbar[[sim0]],
        IV_matrix = settings$IV[[sim0]],
        grid0 = theta_index,
        test0 = settings$test_stat[[sim0]],
        cvalue = settings$cv[[sim0]],
        alpha_input = settings$alpha[[sim0]],
        num_boots = sim$num_boots,
        rng_seed = sim$rng_seed
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
  formated_CI,
  sprintf("%.2f", results$comp_time)
)

# Add colnames
colnames(the_table) <- c(
  "$\\Bar{V}$",
  "$\\theta_1$: Coca-Cola",
  "$\\theta_2$: Energy Brands",
  "Comp. Time"
)

# Save the table
print(
  xtable(the_table, digits = 4),
  include.rownames = F,
  sanitize.colnames.function = identity,
  file = file.path(table_dir, paste0(sim$sim_name, ".tex"))
)
