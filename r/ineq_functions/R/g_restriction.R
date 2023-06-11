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

  x_data <- m_function(
    theta, w_data, a_matrix, j0_vector, v_bar, grid0, iv_matrix
  )
  m_hat0 <- m_hat(x_data)
  n <- nrow(x_data)

  # see Section 4.2.2 in Chernozhukov et al. (2019)
  beta <- alpha / 50

  # Set test statistic
  ## 1. CCK
  ## 2. RC-CCK
  test_stat <-
    switch(test0,
      CCK = max(sqrt(n) * m_hat0),
      `RC-CCK` = max(-min(sqrt(n) * (m_hat0 + hat_r_inf), 0)),
      stop(sprintf("test0 must be one of CCK, RC-CCK. You entered %s.", cvalue))
    )

  # Set critical value
  ## 1. SPUR1 as in Section 4.4 in Andrews and Kwon (2023)
  ##    (note, we use -x_data to match their condition)
  ## 2. SN as in eq (40)
  ## 3. SN2S as in eq (41)
  ## 4. EB2S as in eq (48)
  critical_value <-
    switch(cvalue,
      SPUR1 = cvalue_spur1(-x_data, bootstrap_replications, alpha, an_vec, rng_seed),
      SN = cvalue_sn(x_data, alpha),
      SN2S = cvalue_sn2s(x_data, alpha, beta),
      EB2S = cvalue_eb2s(x_data, alpha, beta, bootstrap_replications, rng_seed, bootstrap_indices),
      stop(
        sprintf(
          "cvalue must be one of SPUR1, SN, SN2S, EB2S. You entered %s.",
          cvalue
        )
      )
    )
  return(c(test_stat, critical_value))
}
