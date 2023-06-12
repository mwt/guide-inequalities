# Table 1 in Section 8.1 in Canay, Illanes and Velez (2023)

if (!dir.exists("_results")) {
  dir.create("_results")
}

# Import packages and functions
require(readr)
require(tictoc)
require(Rfast)
require(Rfast2)
require(nloptr)
require(xtable)
# Quick hack to load functions (temporary)
invisible(lapply(
  list.files(
    path = file.path("ineq_functions", "R"),
    full.names = T,
    pattern = "\\.R$"
  ),
  source
))

# Import data
datasets <- c("A", "D", "J0", "Dist")
data_path <- file.path("..", "data")
dgp <- sapply(datasets, function(dataset) {
  unname(as.matrix(readr::read_csv(
    file.path(data_path, paste0(dataset, ".csv")),
    col_names = F,
    show_col_types = F
  )))
}, simplify = F)
dgp$W <- dgp$W / 1000
dgp$W <- dgp$D[, -1]

# Settings (cell arrays are used to loop over each of the four different specifications)
settings <- list(
  v_bar = c(500, 500, 1000, 1000),
  test_stat = c("CCK", "CCK", "CCK", "CCK"),
  cv = c("SN", "SN", "SN", "SN"),
  alpha = 0.05,
  iv = NULL
)

# Technical settings (lists are used to loop over the two parameters: theta1 and theta2)
sim <- list(
  sim_name = "table_4",
  lb = rbind(
    c(-40, -20, 0, -40, -20, 0, 0, 0),
    c(-40, -20, -10, -40, -20, -10, 0, 0),
    c(-40, -20, 0, -40, -20, 0, 0, 0),
    c(-40, -20, -10, -40, -20, -10, 0, 0)
  ),
  ub = rbind(
    c(100, 50, 0, 100, 50, 0, 3, 2),
    c(100, 50, 10, 100, 50, 10, 3, 2),
    c(100, 50, 0, 100, 50, 0, 3, 2),
    c(100, 50, 10, 100, 50, 10, 3, 2)
  ),
  x0 = matrix(0, nrow = 4, ncol = 8)
)

results <- list(
  ci_vector = lapply(1:8, function(i) {
    matrix(NA, nrow = 4, ncol = 2)
  }),
  comp_time = rep(NA, 4)
)

# Define constraint function
restriction_function <- function(theta, sim_i, theta_index, account_uncertainty) {
  restriction_terms <- g_restriction(
    theta = theta,
    w_data = dgp$W,
    a_matrix = dgp$A,
    j0_vector = dgp$J0,
    v_bar = settings$v_bar[sim_i],
    alpha = settings$alpha,
    grid0 = "all",
    test0 = settings$test_stat[sim_i],
    cvalue = settings$cv[sim_i],
    iv_matrix = settings$iv,
    dist_data = dgp$Dist,
  )
  restriction_terms[1] - restriction_terms[2]
}

restriction_jac <- function(theta, sim_i, theta_index, account_uncertainty) {
  nloptr::nl.grad(
    x0 = theta,
    fn = restriction_function,
    heps = 1e-12,
    sim_i = sim_i,
    theta_index = theta_index,
    account_uncertainty = account_uncertainty
  )
}

for (sim_i in 1:4) {
  tictoc::tic(paste("Simulation", sim_i))

  for (theta_index in 1:6) {
    if (sim$lb[sim_i, theta_index] == sim$ub[sim_i, theta_index]) {
      # If the bounds are equal, then theta is fixed
      results$ci_vector[[theta_index]][sim_i, ] <- c(
        sim$lb[sim_i, theta_index],
        sim$ub[sim_i, theta_index]
      )
    } else {
      # Call the optimization routine
      ci_lower <- nloptr::nloptr(
        x0 = sim$x0[sim_i, 1:6],
        eval_f = function(theta, sim_i, theta_index, account_uncertainty) {
          theta[theta_index]
        },
        eval_grad_f = function(theta, sim_i, theta_index, account_uncertainty) {
          grad_f <- numeric(6)
          grad_f[theta_index] <- 1
          grad_f
        },
        lb = sim$lb[sim_i, 1:6],
        ub = sim$ub[sim_i, 1:6],
        eval_g_ineq = restriction_function,
        eval_jac_g_ineq = restriction_jac,
        opts = list(algorithm = "NLOPT_LD_SLSQP", maxeval = 100000, xtol_rel = 1e-8),
        sim_i = sim_i,
        theta_index = theta_index,
        account_uncertainty = FALSE
      )

      ci_upper <- nloptr::nloptr(
        x0 = sim$x0[sim_i, 1:6],
        eval_f = function(theta, sim_i, theta_index, account_uncertainty) {
          -theta[theta_index]
        },
        eval_grad_f = function(theta, sim_i, theta_index, account_uncertainty) {
          grad_f <- numeric(6)
          grad_f[theta_index] <- -1
          grad_f
        },
        lb = sim$lb[sim_i, 1:6],
        ub = sim$ub[sim_i, 1:6],
        eval_g_ineq = restriction_function,
        eval_jac_g_ineq = restriction_jac,
        opts = list(algorithm = "NLOPT_LD_SLSQP", maxeval = 100000, xtol_rel = 1e-8),
        sim_i = sim_i,
        theta_index = theta_index,
        account_uncertainty = FALSE
      )

      results$ci_vector[[theta_index]][sim_i, 1] <- ci_lower$solution[theta_index]
      results$ci_vector[[theta_index]][sim_i, 2] <- ci_upper$solution[theta_index]
    }
  }
  # Stop the timer
  temp_timer <- tictoc::toc()
  results$comp_time[sim_i] <- temp_timer$toc - temp_timer$tic
}

print(results$ci_vector)

## 3 Save results
# save(results, file = file.path("_results", paste0(sim$sim_name, ".Rdata")))
#
#
## save(fullfile('_results', strcat(sim[['sim_name']], '.mat')), 'dgp', 'settings', 'sim', 'results')
##
### 4 Print table
# table_dir <- file.path("_results", "tables-tex")
# if (!dir.exists(table_dir)) {
#  dir.create(table_dir)
# }
#
## Format CI as [lb, ub]
# formatted_ci <- sapply(results$ci_vector, function(ci_theta) {
#  apply(ci_theta, 1, function(x) {
#    paste0("[", sprintf("%.1f", x[1]), ", ", sprintf("%.1f", x[2]), "]")
#  })
# })
#
## Make table as matrix
# the_table <- cbind(
#  settings$v_bar,
#  settings$cv,
#  formatted_ci,
#  sprintf("%.2f", results$comp_time)
# )
#
## Add colnames
# colnames(the_table) <- c(
#  "$\\Bar{V}$",
#  "Crit. Value",
#  "$\\theta_1$: Coca-Cola",
#  "$\\theta_2$: Energy Brands",
#  "Comp. Time"
# )
#
## Save the table
# print(
#  xtable(the_table, digits = 4),
#  include.rownames = FALSE,
#  sanitize.colnames.function = identity,
#  file = file.path(table_dir, paste0(sim$sim_name, ".tex"))
# )
