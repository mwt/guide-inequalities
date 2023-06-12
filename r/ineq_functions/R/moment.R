#' Standardized Sample Mean of Moment Functions
#'
#' @param x_data an n x k matrix of evaluated moment functions.
#' @param MARGIN a vector giving the subscripts which the function will be
#'   applied over. E.g., for a matrix 1 indicates rows, 2 indicates columns.
#'
#' @return a vector of the standardized sample mean of the moment functions.
#' @export
m_hat <- function(x_data, MARGIN = 2) {
  if (MARGIN == 1) {
    n <- ncol(x_data)
    mean_operation <- Rfast::rowmeans
    var_operation <- Rfast::rowVars
  } else if (MARGIN == 2) {
    n <- nrow(x_data)
    mean_operation <- Rfast::colmeans
    var_operation <- Rfast::colVars
  } else {
    stop("MARGIN must be 1 or 2.")
  }

  mu_hat <- mean_operation(x_data)
  # normalize by n instead of n-1 as in matlab code
  sigma_hat <- var_operation(x_data, std = T) * sqrt((n - 1) / n)

  # Work around to set 0/0 = 0
  m_hat0 <- numeric(length = length(mu_hat))
  # as in eq (A.13) and similar to eq. (4.2) in Andrews and Kwon (2023)
  m_hat0[mu_hat != 0] <- mu_hat[mu_hat != 0] / sigma_hat[mu_hat != 0]

  m_hat0
}

#' Moment Inequality Function
#'
#' @param theta a vector containing the parameters of interest.
#' @param w_data an n x k matrix of product portfolio data.
#' @param a_matrix an n x (num_products + 1) matrix of estimated revenue differentials.
#' @param j0_vector a num_products x 2 matrix of ownership by the two firms.
#' @param v_bar a tuning parameter as in Assumption 4.2.
#' @param grid0 optional vector of length num_products containing the indices of the
#'   products in the market.
#' @param iv_matrix optional n x d_iv matrix of instruments.
#' @param dist_data an n x (J + 1) matrix of distances from the product
#'   factories to the cities.
#'
#' @return
#' @export
m_function <- function(theta, w_data, a_matrix, j0_vector, v_bar, grid0 = "all", iv_matrix = NULL, dist_data = NULL) {
  n <- nrow(a_matrix)
  num_products <- nrow(j0_vector)

  if (nrow(w_data) != n) {
    stop("w_data must have the same number of rows as a_matrix")
  }

  ## step 1: select moments with non-zero variance using ml_indx & mu_indx
  #          the procedure follows the discussion of section 8.1

  # Take sum of columns of w_data
  aux1 <- Rfast::colsums(w_data)
  aux1 <- aux1[j0_vector[, 1]]

  if (grid0 == "all") {
    ml_indx <- (1:num_products)[aux1 < n]
    mu_indx <- (1:num_products)[aux1 > 0]
  } else if (grid0 %in% 1:2) {
    ml_indx <- (1:num_products)[aux1 < n & j0_vector[, 2] == grid0]
    mu_indx <- (1:num_products)[aux1 > 0 & j0_vector[, 2] == grid0]
  } else {
    stop(sprintf("grid 0 must be one of all,0,1. You entered %s.", grid0))
  }

  # Subset vector of estimated revenue differential in market i
  a_subset <- a_matrix[, 2:(num_products + 1)]
  # Subset vector of product portfolio of coca-cola and
  # energy-products in market i
  d_matrix <- w_data[, j0_vector[, 1]]

  if (is.null(dist_data)) {
    dist_subset <- NULL
  } else {
    # Note that we skip the first column of dist_data
    dist_subset <- dist_data[, j0_vector[, 1] + 1]
  }

  ## step 2: compute all the moment functions
  if (is.null(iv_matrix)) {
    # Create dummy IV vector
    z_matrix <- 1

    ml_vec <- m_fun_lower(
      theta, d_matrix, a_subset, j0_vector, v_bar, z_matrix, dist_subset
    )
    mu_vec <- m_fun_upper(
      theta, d_matrix, a_subset, j0_vector, v_bar, z_matrix, dist_subset
    )

    # Create x_data
    x_data <- cbind(ml_vec[, ml_indx], mu_vec[, mu_indx])
  } else {
    # Create dummy IV "matrix"
    z0_matrix <- 1
    # employment rate
    z3_matrix <- as.numeric(iv_matrix[, 2] > median(iv_matrix[, 2]))
    # average income in market
    z5_matrix <- as.numeric(iv_matrix[, 3] > median(iv_matrix[, 3]))
    # median income in market
    z7_matrix <- as.numeric(iv_matrix[, 4] > median(iv_matrix[, 4]))

    # Compute lower and upper bounds
    ml_vec0 <- m_fun_lower(
      theta, d_matrix, a_subset, j0_vector, v_bar, z0_matrix, dist_subset
    )
    mu_vec0 <- m_fun_upper(
      theta, d_matrix, a_subset, j0_vector, v_bar, z0_matrix, dist_subset
    )

    ml_vec3 <- m_fun_lower(
      theta, d_matrix, a_subset, j0_vector, v_bar, z3_matrix, dist_subset
    )
    mu_vec3 <- m_fun_upper(
      theta, d_matrix, a_subset, j0_vector, v_bar, z3_matrix, dist_subset
    )

    ml_vec5 <- m_fun_lower(
      theta, d_matrix, a_subset, j0_vector, v_bar, z5_matrix, dist_subset
    )
    mu_vec5 <- m_fun_upper(
      theta, d_matrix, a_subset, j0_vector, v_bar, z5_matrix, dist_subset
    )

    ml_vec7 <- m_fun_lower(
      theta, d_matrix, a_subset, j0_vector, v_bar, z7_matrix, dist_subset
    )
    mu_vec7 <- m_fun_upper(
      theta, d_matrix, a_subset, j0_vector, v_bar, z7_matrix, dist_subset
    )

    # Create x_data
    x_data <- cbind(
      ml_vec0[, ml_indx],
      mu_vec0[, mu_indx],
      ml_vec3[, ml_indx],
      mu_vec3[, mu_indx],
      ml_vec5[, ml_indx],
      mu_vec5[, mu_indx],
      ml_vec7[, ml_indx],
      mu_vec7[, mu_indx]
    )
  }

  x_data
}

#' Lower Moment Inequality Function
#'
#' @param theta a vector containing the parameters of interest.
#' @param d_matrix an n x j0 matrix of product portfolio in each market.
#' @param a_subset an n x j0 matrix of estimated revenue differential in each
#'   market.
#' @param j0_vector a j0 x 2 matrix of ownership by the two firms.
#' @param v_bar a tuning parameter as in Assumption 4.2.
#' @param z_matrix an optional n x j0 matrix of instruments in each market.
#' @param dist_subset an optional n x j0 matrix of distance between products in
#'   each market.
#'
#' @return a j0-dimensional vector of lower moment inequalities.
#' @export
m_fun_lower <- function(theta, d_matrix, a_subset, j0_vector, v_bar, z_matrix = 1, dist_subset = NULL) {
  # number of firms
  num_firms <- length(unique(j0_vector[, 2]))

  if (is.null(dist_subset)) {
    # Check that theta is a vector of length num_firms
    if (num_firms != length(theta)) {
      stop("theta must have the same number of elements as num_firms")
    }
    # Create vector of theta values matched to the firm of each product
    theta_vector <- theta[j0_vector[, 2]]
  } else {
    # Reshape theta to be num_firms x 3
    theta <- matrix(theta, num_firms, 3)
    # Create g_theta vector as in Section 8.2.3
    theta_vector <- (
      theta[j0_vector[, 2], 0] +
        theta[j0_vector[, 2], 1] * dist_subset +
        theta[j0_vector[, 2], 2] * (dist_subset^2)
    )
  }

  # Run equation (26) for each product
  (t(t(a_subset) - theta_vector) * (1 - d_matrix) - v_bar * d_matrix) * z_matrix
}

#' Upper Moment Inequality Function
#'
#' @param theta a vector containing the parameters of interest.
#' @param d_matrix an n x j0 matrix of product portfolio in each market.
#' @param a_subset an n x j0 matrix of estimated revenue differential in each
#'   market.
#' @param j0_vector a j0 x 2 matrix of ownership by the two firms.
#' @param v_bar a tuning parameter as in Assumption 4.2.
#' @param z_matrix an optional n x j0 matrix of instruments in each market.
#' @param dist_subset an optional n x j0 matrix of distance between products in
#'   each market.
#'
#' @return a j0-dimensional vector of upper moment inequalities.
#' @export
m_fun_upper <- function(theta, d_matrix, a_subset, j0_vector, v_bar, z_matrix = 1, dist_subset = NULL) {
  # Moment function upper is moment function lower with two substitutions:
  # 1. theta is negated
  # 2. d_matrix replaced with 1 - d_matrix
  m_fun_lower(
    a_subset = a_subset,
    d_matrix = 1 - d_matrix,
    z_matrix = z_matrix,
    j0_vector = j0_vector,
    theta = -theta,
    v_bar = v_bar,
    dist_subset = dist_subset
  )
}
