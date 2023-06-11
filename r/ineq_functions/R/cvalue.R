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

  ## Step 2: calculations
  qq <- qnorm(1 - alpha / k)
  # as in eq (40)
  c_sn <- qq / sqrt(1 - qq^2 / n)

  c_value <- c_sn
  return(c_value)
}

#' Stage 2 Critical Value
#'
#' @param x_data an n x k matrix of evaluated moment functions.
#' @param alpha the confidence level required for the first stage test.
#' @param beta the confidence level required for the second stage test.
#'
#' @return a float for the critical value.
#' @export
cvalue_sn2s <- function(x_data, alpha, beta) {
  ## Step 0: parameter setting
  n <- nrow(x_data) # sample size

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
  ## Run the first stage from cvalue_sn
  cvalue0 <- cvalue_sn(x_data, beta) # as in eq (40)

  ## Compute the sample mean of each column of x_data
  mu_hat <- Rfast::colmeans(x_data)

  ## Compute the standard deviation of each column of x_data
  ## normalize by n instead of n-1 as in matlab code
  sigma_hat <- Rfast::colVars(x_data, std = T) * sqrt((n - 1) / n)

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

#' Bootstrap Critical Value
#'
#' @param x_data an n x k matrix of evaluated moment functions.
#' @param alpha the confidence level required for the first stage test.
#' @param beta the confidence level required for the second stage test.
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
cvalue_eb2s <- function(x_data, alpha, beta, bootstrap_replications = NULL, rng_seed = NULL, bootstrap_indices = NULL) {
  # sample size
  n <- nrow(x_data)
  # number of moments
  k <- ncol(x_data)

  if (beta >= alpha / 2) {
    stop(sprintf(
      "beta is not lower than alpha/2: fix it! alpha: %s, beta %s",
      alpha,
      beta
    ))
  }

  # Step 1: Algorithm of the Empirical Bootstrap as in Section 5.2

  ## Compute the mean of each column of x_data
  mu_hat <- Rfast::colsums(x_data) / n
  ## Compute the standard deviation of each column of x_data
  ## (normalize by n instead of n-1 as in MATLAB code)
  sigma_hat <- Rfast::colVars(x_data, std = T) * sqrt((n - 1) / n)

  # to replicate results
  if (is.null(bootstrap_indices)) {
    if (is.null(bootstrap_replications)) {
      stop(
        "bootstrap_replications must be specified if bootstrap_indices is not."
      )
    } else {
      if (!is.null(rng_seed)) {
        set.seed(rng_seed, kind = "Mersenne-Twister")
      }
      # Generate indices if not specified
      bootstrap_indices <- sample.int(
        n,
        n * bootstrap_replications,
        replace = T
      )
    }
  }

  # Indexing trick, the inner matrix has structure:
  # [ Col1 from BB1, Col2 from BB1, ... Col1 from BB2, Col2 from BB2, ... ]
  x_means <- matrix(
    Rfast::colsums(matrix(x_data[bootstrap_indices, ], nrow = n)) / n,
    ncol = k
  )
  # Follow the steps in eq (45)
  # (double transpose is because R broadcasts column vectors)
  WEB_matrix <- t(
    (sqrt(n) * (t(x_means) - mu_hat)) / sigma_hat
  )

  ## Take maximum of each sample
  WEB_vector <- Rfast::rowMaxs(WEB_matrix, value = T)

  ## Obtain quantile of bootstrap samples
  cvalue0 <- Rfast2::Quantile(WEB_vector, 1 - beta)

  ## Studentized statistic for each moment inequality
  test_stat0 <- sqrt(n) * mu_hat / sigma_hat

  # Step 2: Critical value

  ## Selection of moment inequalities that are almost binding as in eq (46)
  almost_binding <- (test_stat0 > (-2 * cvalue0))
  if (any(almost_binding)) {
    WEB_matrix2 <- WEB_matrix[, almost_binding]
    WEB_vector2 <- Rfast::rowMaxs(WEB_matrix2, value = T)
    cvalue1 <- Rfast2::Quantile(WEB_vector2, 1 - alpha + 2 * beta)
  } else {
    cvalue1 <- 0
  }

  return(cvalue1)
}
