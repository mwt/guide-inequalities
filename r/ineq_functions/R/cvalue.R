#' Stage 1 Critical Value Backend
#'
#' @param n the sample size.
#' @param k the number of moments.
#' @param alpha the confidence level required.
#'
#' @return a float for the critical value.
base_sn <- function(n, k, alpha) {
  # Obtain the quantile of the standard normal distribution corresponding to
  # the significance level
  z_quantile <- qnorm(1 - alpha / k)

  # Compute the c-value as in eq (41)
  z_quantile / sqrt(1 - z_quantile^2 / n)
}

#' Stage 1 Critical Value
#'
#' @param x_data an n x k matrix of evaluated moment functions.
#' @param alpha the confidence level required.
#'
#' @return a float for the critical value.
#' @export
cvalue_sn <- function(x_data, alpha) {
  ## Step 1: parameter setting
  n <- nrow(x_data) # sample size
  k <- ncol(x_data) # number of moments

  # Compute the c-value as in eq (41)
  base_sn(n, k, alpha)
}

#' Stage 2 Critical Value
#'
#' @param x_data an n x k matrix of evaluated moment functions.
#' @param alpha the confidence level required for the first stage test.
#' @param beta optional confidence level required for the second stage test.
#'
#' @return a float for the critical value.
#' @export
cvalue_sn2s <- function(x_data, alpha, beta = alpha / 50) {
  ## Step 0: parameter setting
  n <- nrow(x_data) # sample size
  k <- ncol(x_data) # number of moments

  # Step 1: define set J_sn as almost binding
  ## Run the first stage from cvalue_sn
  cvalue0 <- base_sn(n, k, beta)

  ## Compute the sample mean of each column of x_data
  mu_hat <- Rfast::colsums(x_data) / n

  ## Compute the standard deviation of each column of x_data
  ## normalize by n instead of n-1 as in matlab code
  sigma_hat <- Rfast::colVars(x_data, std = T) * sqrt((n - 1) / n)

  ## Studentized statistic for each moment inequality
  test_stat0 <- sqrt(n) * mu_hat / sigma_hat

  ## Number of moment inequalities that are almost binding as in eq (40)
  k_hat <- sum(test_stat0 > (-2 * cvalue0))

  # Step 2: calculate critical value using a subset of moment inequalities
  if (k_hat > 0) {
    base_sn(n, k_hat, alpha - 2 * beta) # as in eq (42)
  } else {
    0
  }
}

#' Bootstrap Critical Value
#'
#' @param x_data an n x k matrix of evaluated moment functions.
#' @param alpha the confidence level required for the first stage test.
#' @param beta optional confidence level required for the second stage test.
#' @param bootstrap_replications the number of bootstrap replications.
#'   Required if bootstrap_indices is not specified.
#' @param rng_seed the seed for replication purposes. If not specified, the
#'   seed is not set.
#' @param bootstrap_indices an integer vector of indices to use for the
#'   bootstrap. If this is specified, bootstrap_replications and rng_seed will
#'   be ignored. If this is not specified, bootstrap_replications is required.
#'
#' @return a float for the critical value.
#' @export
cvalue_eb2s <- function(x_data, alpha, beta = alpha / 50, bootstrap_replications = NULL, rng_seed = NULL, bootstrap_indices = NULL) {
  ## Step 0: parameter setting
  n <- nrow(x_data) # sample size
  k <- ncol(x_data) # number of moments

  ## Step 1: Algorithm of the Empirical Bootstrap as in Section 5.2

  # Obtain random numbers for the bootstrap
  bootstrap_indices <- get_bootstrap_indices(
    n, bootstrap_replications, rng_seed, bootstrap_indices
  )

  ## Compute the mean of each column of x_data
  mu_hat <- Rfast::colsums(x_data) / n
  ## Compute the standard deviation of each column of x_data
  ## (normalize by n instead of n-1 as in MATLAB code)
  sigma_hat <- Rfast::colVars(x_data, std = T) * sqrt((n - 1) / n)

  # Indexing trick, the inner matrix has structure:
  # [ Col1 from BB1, Col2 from BB1, ... Col1 from BB2, Col2 from BB2, ... ]
  x_means <- matrix(
    Rfast::colsums(matrix(x_data[bootstrap_indices, ], nrow = n)) / n,
    ncol = k
  )
  # Follow the steps in eq (46)
  # (double transpose is because R broadcasts column vectors)
  web_matrix <- t(
    (sqrt(n) * (t(x_means) - mu_hat)) / sigma_hat
  )

  ## Take maximum of each sample
  web_vector <- Rfast::rowMaxs(web_matrix, value = T)

  ## Obtain quantile of bootstrap samples
  cvalue0 <- Rfast2::Quantile(web_vector, 1 - beta)

  ## Studentized statistic for each moment inequality
  test_stat0 <- sqrt(n) * mu_hat / sigma_hat

  # Step 2: Critical value

  ## Selection of moment inequalities that are almost binding as in eq (47)
  almost_binding <- (test_stat0 > (-2 * cvalue0))
  if (any(almost_binding)) {
    web_matrix2 <- web_matrix[, almost_binding]
    web_vector2 <- Rfast::rowMaxs(web_matrix2, value = T)
    Rfast2::Quantile(web_vector2, 1 - alpha + 2 * beta)
  } else {
    0
  }
}
