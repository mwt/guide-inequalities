## compute critical value defined in eq (48) of Section 5 in Canay, Illanes, and Velez (2023)
# input
# - X_data          n x k    matrix of evaluated moment functions
# - BB_input        1 x 1    number of bootstraps
# - alpha_input     1 x 1    significance level
# - beta_input      1 x 1    tuning parameter to select moments
# - rng_seed                 seed for replication purpose

# output
# - c_value         1 x 1    critical value

cvalue_EB2S <- function(X_data,
                        BB_input,
                        alpha_input,
                        beta_input,
                        rng_seed) {
  ## Step 1: paramater setting
  # sample size
  n <- nrow(X_data)
  # number of moments
  k <- ncol(X_data)
  BB <- BB_input
  alpha <- alpha_input
  beta <- beta_input

  if (beta < alpha / 2) {
    # cat('Two step EB-method is running')
  } else {
    stop(sprintf(
      "beta is not lower than alpha/2: fix it! alpha: %s, beta %s",
      alpha,
      beta
    ))
  }

  ## Step 2: Algorithm of the Empirical Bootstrap as in Section 5.2

  # to replicate results
  set.seed(rng_seed, kind = "Mersenne-Twister")
  draws_vector <- matrix(sample.int(n, n * BB, replace = T),
    nrow = n,
    ncol = BB
  )

  # matrix to save components of the empirical bootstrap test statistic
  WEB_matrix <- matrix(NA, BB, k)

  mu_hat <- Rfast::colmeans(X_data)
  # normalize by n instead of n-1 as in matlab code
  sigma_hat <- Rfast::colVars(X_data, std = T) * sqrt((n - 1) / n)

  for (kk in 1:BB) {
    # draw from the empirical distribution
    XX_draw <- X_data[draws_vector[, kk], ]
    # as in eq (45)
    WEB_matrix[kk, ] <-
      sqrt(n) * (1 / n) * (rep(1, n) %*% (XX_draw - rep(1, n) %*% t(mu_hat))) / sigma_hat
  }

  # Take maximum of each sample
  WEB_vector <- Rfast::rowMaxs(WEB_matrix, value = T)
  # Obtain quantile of bootstrap samples
  c_value0 <- Rfast2::Quantile(WEB_vector, 1 - beta)

  test_vector <- sqrt(n) * mu_hat / sigma_hat
  # as in eq (46)
  JJ <- sum(test_vector > (-2 * c_value0))

  if (JJ > 0) {
    WEB_matrix2 <- matrix(0, BB, JJ)
  } else {
    WEB_matrix2 <- matrix(0, BB, 1)
  }

  jj0 <- 0

  for (jj in 1:k) {
    test0 <- test_vector[jj]

    if (test0 > (-2 * c_value0)) {
      jj0 <- jj0 + 1
      # selection of moment inequalities
      WEB_matrix2[, jj0] <- WEB_matrix[, jj]
    }
  }

  # as in eq (47)
  WEB_vector2 <- Rfast::rowMaxs(WEB_matrix2, value = T)

  ## Step 3: Critical value
  # as in eq (48)
  c_value <- Rfast2::Quantile(WEB_vector2, 1 - alpha + 2 * beta)
  return(c_value)
}
## compute critical value defined in eq (40) of Section 5 in Canay, Illanes, and Velez (2023)
# input
# - X_data           n x k    matrix of evaluated moment functions
# - alpha_input      1 x 1    significance level

# output
# - c_value    1 x 1    critical value

cvalue_SN <- function(X_data, alpha_input) {
  ## Step 1: parameter setting
  n <- nrow(X_data) # sample size
  k <- ncol(X_data) # number of moments

  ## Step 2: calculations
  qq <- qnorm(1 - alpha_input / k)
  # as in eq (40)
  c_sn <- qq / sqrt(1 - qq^2 / n)

  c_value <- c_sn
  return(c_value)
}
## compute critical value defined in eq (41) of section 5 in Canay, Illanes, and Velez (2023)
# input
# - X_data          n x k    matrix of evaluated moment functions
# - alpha_input     1 x 1    significance level
# - beta_input      1 x 1    tuning parameter to select moments

# output
# - c_value         1 x 1    critical value

cvalue_SN2S <- function(X_data, alpha_input, beta_input) {
  ## Step 0: parameter setting
  n <- nrow(X_data) # sample size
  k <- ncol(X_data) # number of moments
  alpha <- alpha_input
  beta <- beta_input

  if (beta < alpha / 2) {
    #     cat('Two step SN-method is running');
  } else {
    stop(sprintf(
      "beta is not lower than alpha/2: fix it! alpha: %s, beta %s",
      alpha,
      beta
    ))
  }

  ## Step 1: define set J_SN as almost binding

  c_sn0 <- cvalue_SN(X_data, beta) # as in eq (40)
  # number of moments inequalities that are almost binding
  contar <- 0

  for (jj in 1:k) {
    mu_hat <- mean(X_data[, jj])
    sigma_hat <- sd(X_data[, jj])

    # Studentized statistic for each moment inequality
    test0 <- sqrt(n) * mu_hat / sigma_hat

    if (test0 > (-2 * c_sn0)) {
      # moments inequalities that are almost binding
      contar <- contar + 1
    }
  }

  # as in eq (39)
  k_hat <- contar

  ## Step 2: calculate critical value using a subset of moment inequalities

  if (k_hat > 0) {
    qq1 <- qnorm(1 - (alpha - 2 * beta) / k_hat)
    # as in eq (41)
    c_sn1 <- qq1 / sqrt(1 - qq1^2 / n)
  } else {
    c_sn1 <- 0
  }

  c_value <- c_sn1
  return(c_value)
}
