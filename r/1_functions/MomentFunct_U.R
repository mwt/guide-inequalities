# Moment inequality function defined in eq (27)
# input:
# - A_subset    J0 x n      vector of estimated revenue differential in a market
# - D_mat       J0 x n      vector of product portfolio in a market.
# - Z_mat       J0 x n      vector of instruments in a market
# - J0_vec      J0 x 2      vector of products of coca-cola and energy-product
# - theta  d_theta x n      parameter of interest
# - Vbar                    tuning parameter as in Assumption 4.2

# output:
# - salida      n x J0      vector of the moment function.
MomentFunct_U <- function(A_subset, D_mat, Z_mat, J0_vec, theta, Vbar) {
  # number of firms
  num_firms <- length(unique(J0_vec[, 2]))

  if (num_firms != length(theta)) {
    stop("error on dimension of theta")
  }

  # Create vector of theta values matched to the firm of each product
  theta_vector <- theta[J0_vec[, 2]]

  # Run equation (27) for each product
  (t(t(A_subset) + theta_vector) * D_mat - Vbar * (1 - D_mat)) * Z_mat
}
