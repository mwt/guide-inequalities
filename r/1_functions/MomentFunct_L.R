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
MomentFunct_L <- function(A_vec, D_vec, Z_vec, J0_vec, theta, Vbar)
{
  # number of products to evaluate one-product deviation
  J0 <- nrow(J0_vec)
  # number of firms
  S0 <- length(unique(J0_vec[, 2]))
  
  if (S0 != length(theta)) {
    cat('error on dimension of theta')
    return()
  } else {
    salida <- rep(0, J0)
    
    for (jj0 in 1:J0) {
      jj2 <- J0_vec[jj0, 2]
      theta_jj0 <- theta[jj2]
      # as in eq (26)
      salida[jj0] <-
        ((A_vec[jj0] - theta_jj0) * (1 - D_vec[jj0]) - Vbar * D_vec[jj0]) %*% Z_vec[jj0]
    }
    return(salida)
  }
}
