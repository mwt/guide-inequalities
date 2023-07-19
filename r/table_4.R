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
require(devtools)

# Install and import package
devtools::install("ineqfunctions", upgrade = "never")

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
dgp$Dist <- dgp$Dist / 1000
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
  x0 = matrix(0, nrow = 4, ncol = 8),
  opt = list(
    algorithm = "NLOPT_LD_SLSQP",
    maxeval = 1e5,
    xtol_rel = 5e-4,
    ftol_rel = 1e-8
  )
)

results <- list(
  ci_vector = lapply(1:8, function(i) {
    matrix(NA, nrow = 4, ncol = 2)
  }),
  comp_time = rep(NA, 4)
)

# Define constraint function
restriction_function <- function(theta, sim_i, theta_index, account_uncertainty) {
  restriction_terms <- ineqfunctions::g_restriction(
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
    account_uncertainty = account_uncertainty,
    dist_data = dgp$Dist,
  )
  restriction_terms[1] - restriction_terms[2]
}

restriction_jac <- function(theta, sim_i, theta_index, account_uncertainty) {
  nloptr::nl.grad(
    x0 = theta,
    fn = restriction_function,
    heps = 1e-6,
    sim_i = sim_i,
    theta_index = theta_index,
    account_uncertainty = account_uncertainty
  )
}

for (sim_i in 1:4) {
  tictoc::tic(paste("Simulation", sim_i))

  # Six dimensional theta confidence intervals
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
        x0 = as.numeric(sim$x0[sim_i,1:6]),
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
        opts = sim$opt,
        sim_i = sim_i,
        theta_index = theta_index,
        account_uncertainty = FALSE
      )

      ci_upper <- nloptr::nloptr(
        x0 = as.numeric(sim$x0[sim_i,1:6]),
        eval_f = function(theta, sim_i, theta_index, account_uncertainty) {
          -theta[theta_index]
        },
        eval_grad_f = function(theta, sim_i, theta_index, account_uncertainty) {
          grad_f <- numeric(6)
          grad_f[theta_index] <- -1
          grad_f
        },
        lb = as.numeric(sim$lb[sim_i, 1:6]),
        ub = as.numeric(sim$ub[sim_i, 1:6]),
        eval_g_ineq = restriction_function,
        eval_jac_g_ineq = restriction_jac,
        opts = sim$opt,
        sim_i = sim_i,
        theta_index = theta_index,
        account_uncertainty = FALSE
      )

      results$ci_vector[[theta_index]][sim_i, 1] <- ci_lower$solution[theta_index]
      results$ci_vector[[theta_index]][sim_i, 2] <- ci_upper$solution[theta_index]
    }
  }

  # Two dimensional theta confidence intervals accounting for uncertainty
  for (theta_index in 1:2) {
    # Call the optimization routine
    ci_lower <- nloptr::nloptr(
      x0 = as.numeric(sim$x0[sim_i,]),
      eval_f = function(theta, sim_i, theta_index, account_uncertainty) {
        sum(theta[((theta_index - 1) * 3 + 1) : ((theta_index) * 3)]) * theta[6 + theta_index]
      },
      eval_grad_f = function(theta, sim_i, theta_index, account_uncertainty) {
        c(
          sapply(1:6, function(j) ifelse(((theta_index - 1) * 3 + 1) <= j & j < ((theta_index - 1) * 3 + 4), theta[6 + theta_index], 0)),
          sapply(7:8, function(j) ifelse(j == (6 + theta_index), sum(theta[((theta_index - 1) * 3 + 1) : ((theta_index - 1) * 3 + 3)]), 0))
        )
      },
      lb = as.numeric(sim$lb[sim_i,]),
      ub = as.numeric(sim$ub[sim_i,]),
      eval_g_ineq = restriction_function,
      eval_jac_g_ineq = restriction_jac,
      opts = sim$opt,
      sim_i = sim_i,
      theta_index = theta_index,
      account_uncertainty = TRUE
    )

    ci_upper <- nloptr::nloptr(
      x0 = as.numeric(sim$x0[sim_i,]),
      eval_f = function(theta, sim_i, theta_index, account_uncertainty) {
        -sum(theta[((theta_index - 1) * 3 + 1) : ((theta_index) * 3)]) * theta[6 + theta_index]
      },
      eval_grad_f = function(theta, sim_i, theta_index, account_uncertainty) {
        -c(
          sapply(1:6, function(j) ifelse(((theta_index - 1) * 3 + 1) <= j & j < ((theta_index - 1) * 3 + 4), theta[6 + theta_index], 0)),
          sapply(7:8, function(j) ifelse(j == (6 + theta_index), sum(theta[((theta_index - 1) * 3 + 1) : ((theta_index - 1) * 3 + 3)]), 0))
        )
      },
      lb = as.numeric(sim$lb[sim_i,]),
      ub = as.numeric(sim$ub[sim_i,]),
      eval_g_ineq = restriction_function,
      eval_jac_g_ineq = restriction_jac,
      opts = sim$opt,
      sim_i = sim_i,
      theta_index = theta_index,
      account_uncertainty = TRUE
    )

    results$ci_vector[[theta_index + 6]][sim_i, 1] <- ci_lower$solution[theta_index]
    results$ci_vector[[theta_index + 6]][sim_i, 2] <- ci_upper$solution[theta_index]

  }

  # Stop the timer
  temp_timer <- tictoc::toc()
  results$comp_time[sim_i] <- temp_timer$toc - temp_timer$tic
}

# 3 Save results
save(results, file = file.path("_results", paste0(sim$sim_name, ".Rdata")))

### 4 Print table
table_dir <- file.path("_results", "tables-tex")
if (!dir.exists(table_dir)) {
  dir.create(table_dir)
}

the_table <- c("Coca-Cola", "", "", "", "Energy Brands", "", "", "")
the_table <- cbind(
  the_table,
  paste0(
    rep(paste0("$\\theta_{", 1:2), each = 4),
    ifelse(1:8 %% 4 == 0, "}$", paste0(",", rep(1:4, 2), "}$"))
  )
)

# Format CI as [lb, ub]
sub_table <- sapply(results$ci_vector, function(ci_theta) {
 apply(ci_theta, 1, function(x) {
   paste0("[", sprintf("%.1f", x[1]), ", ", sprintf("%.1f", x[2]), "]")
 })
})

# the order has the theta_1(mu) and theta_2(mu) at the end
sorted_sub_table <- t(sub_table)[c(1:3,7,4:6,8),]
the_table <- cbind(the_table, sorted_sub_table)
the_table <- rbind(
  the_table,
  c("Comp. Time", "", sprintf("%.2f", results$comp_time))
)
colnames(the_table) <- c(
  " ", "Parameter", "Linear", "Quadratic", "Linear", "Quadratic"
)

# Save the table
print(
  xtable(the_table, digits = 4),
  include.rownames = FALSE,
  sanitize.text.function = identity,
  file = file.path(table_dir, paste0(sim$sim_name, ".tex"))
)
