## compute critical value defined in eq (41) of section 5 in Canay, Illanes, and Velez (2023)
# input
# - X_data          n x k    matrix of evaluated moment functions
# - alpha     1 x 1    significance level
# - beta      1 x 1    tuning parameter to select moments

# output
# - c_value         1 x 1    critical value

cvalue_SN2S <- function(X_data, alpha, beta) {
  ## Step 0: parameter setting
  n <- nrow(X_data) # sample size

  if (beta < alpha / 2) {
    #     cat('Two step SN-method is running');
  } else {
    stop(sprintf(
      "beta is not lower than alpha/2: fix it! alpha: %s, beta %s",
      alpha,
      beta
    ))
  }

  # Step 1: define set J_SN as almost binding
  ## Run the first stage from cvalue_SN
  cvalue0 <- cvalue_SN(X_data, beta) # as in eq (40)

  ## Compute the sample mean of each column of X_data
  mu_hat <- Rfast::colmeans(X_data)

  ## Compute the standard deviation of each column of X_data
  ## normalize by n instead of n-1 as in matlab code
  sigma_hat <- Rfast::colVars(X_data, std = T) * sqrt((n - 1) / n)

  ## Studentized statistic for each moment inequality
  test_stat0 <- sqrt(n) * mu_hat / sigma_hat

  ## Number of moment inequalities that are almost binding as in eq (39)
  k_hat <- sum(test_stat0 > (-2 * cvalue0))

  ## Step 2: calculate critical value using a subset of moment inequalities

  if (k_hat > 0) {
    qq1 <- qnorm(1 - (alpha - 2 * beta) / k_hat)
    # as in eq (41)
    cvalue1 <- qq1 / sqrt(1 - qq1^2 / n)
  } else {
    cvalue1 <- 0
  }

  return(cvalue1)
}
