#' Compute Test Statistic and Critical Value
#'
#' @param theta a vector containing the parameters of interest.
#' @param w_data an n x k matrix of product portfolio data.
#' @param a_matrix an n x (J0 + 1) matrix of estimated revenue differentials.
#' @param j0_vector a J0 x 2 matrix of ownership by the two firms.
#' @param v_bar a tuning parameter as in Assumption 4.2.
#' @param alpha the significance level.
#' @param grid0 optional vector of length J0 containing the indices of the
#'   products in the market.
#' @param iv_matrix optional n x d_iv matrix of instruments.
#' @param test0 optional test statistic to use. Either "CCK" or "RC-CCK".
#' @param cvalue optional critical value to use. Either "SPUR1", "SN", "SN2S",
#'   or "EB2S".
#' @param account_uncertainty Whether to account for additional uncertainty (as
#'   in Equations 49 and 50). If TRUE, the last two elements of theta are
#'   assumed to be mu.
#' @param bootstrap_replications the number of bootstrap replications.
#'   Required if bootstrap_indices is not specified.
#' @param rng_seed the seed for replication purposes. If not specified, the
#'   seed is not set.
#' @param bootstrap_indices an integer vector of indices to use for the
#'   bootstrap. If this is specified, bootstrap_replications and rng_seed will
#'   be ignored. If this is not specified, bootstrap_replications is required.
#' @param an_vec if using SPUR1, an n-dimensional vector of An values.
#' @param hat_r_inf if using RC-CCK, the lower value of the test statistic.
#' @param dist_data an n x (J + 1) matrix of distances from the product
#'   factories to the cities.
#'
#' @return a vector containing the test statistic and critical value.
#' @export
g_restriction <- function(theta, w_data, a_matrix, j0_vector, v_bar, alpha, grid0 = "all", iv_matrix = NULL, test0 = "CCK", cvalue = "SN", account_uncertainty = FALSE, bootstrap_replications = NULL, rng_seed = NULL, bootstrap_indices = NULL, an_vec = NULL, hat_r_inf = NULL, dist_data = NULL) {
  if (cvalue == "SPUR1" && is.null(an_vec)) {
    stop("an_vec must be provided for SPUR1")
  }
  if (cvalue == "RC-CCK" && is.null(hat_r_inf)) {
    stop("hat_r_inf must be provided for RC-CCK")
  }

  if (account_uncertainty) {
    # assume that the last two elements of theta are mu
    d_theta <- length(theta) - 2
    # raise error if theta does not have at least three elements
    if (d_theta < 1) {
      stop("when account_uncertainty = TRUE, the last two elements of theta must be mu")
    }

    mu <- theta[-(1:d_theta)]
    theta <- theta[1:d_theta]
  }

  x_data <- m_function(
    theta, w_data, a_matrix, j0_vector, v_bar, grid0, iv_matrix, dist_data
  )

  if (account_uncertainty) {
    max_dists <- find_dist(dist_data, j0_vector)
    dist_u1 <- max_dists[, 1] - mu[1]
    dist_u2 <- max_dists[, 2] - mu[2]
    x_data <- cbind(x_data, dist_u1, -dist_u1, dist_u2, -dist_u2)
  }

  n <- nrow(x_data)

  # see Section 4.2.2 in Chernozhukov et al. (2019)
  beta <- alpha / 50

  # Set test statistic
  ## 1. CCK
  ## 2. RC-CCK
  test_stat <-
    switch(test0,
      CCK = sqrt(n) * max(m_hat(x_data)),
      `RC-CCK` = -sqrt(n) * min(pmin(m_hat(-x_data) + hat_r_inf, 0)),
      stop(sprintf("test0 must be one of CCK, RC-CCK. You entered %s.", cvalue))
    )

  # Set critical value
  ## 1. SPUR1 as in Section 4.4 in Andrews and Kwon (2023)
  ##    (note, we use -x_data to match their condition)
  ## 2. SN as in eq (41)
  ## 3. SN2S as in eq (42)
  ## 4. EB2S as in eq (49)
  critical_value <-
    switch(cvalue,
      SN = cvalue_sn(x_data, alpha),
      SN2S = cvalue_sn2s(x_data, alpha, beta),
      EB2S = cvalue_eb2s(
        x_data, alpha, beta, bootstrap_replications, rng_seed, bootstrap_indices
      ),
      SPUR1 = cvalue_spur1(
        -x_data,
        bootstrap_replications,
        alpha,
        an_vec,
        rng_seed,
        bootstrap_indices
      ),
      stop("cvalue must be either SPUR1, SN, SN2S, or EB2S")
    )

  c(test_stat, critical_value)
}
