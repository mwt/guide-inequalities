# Moment inequality function defined in eq (26)
# input:
# - A_vec       J0 x 1      vector of estimated revenue differential in a market
# - D_vec       J0 x 1      vector of product portfolio in a market.
# - Z_vec       J0 x 1      vector of instruments in a market
# - J0_vec      J0 x 2      vector of products of coca-cola and energy-product
# - theta  d_theta x 1      parameter of interest
# - Vbar                    tuning parameter as in Assumption 4.2

# output:
# - salida      1 x J0      vector of the moment function.
MomentFunct_L <- function(A_vec, D_vec, Z_vec, J0_vec, theta, Vbar) {
  # number of firms
  num_firms <- length(unique(J0_vec[, 2]))

  if (num_firms != length(theta)) {
    stop("error on dimension of theta")
  }

  # Create vector of theta values matched to the firm of each product
  theta_vector <- theta[J0_vec[, 2]]

  # Run equation (26) for each product
  ((A_vec - theta_vector) * (1 - D_vec) - Vbar * D_vec) * Z_vec
}
