# Compute a standardized sample mean of the moment functions as in eq (A.13)

# Comments:
# - this function is useful for the procedure in Andrews and Kwon (2023)
# - define X_ij = m_j(W_i,theta), n: sample size, k: number of moments
# - define mu_j as sample mean of X_ij and sigma_j std. of X_ij
# - this function compute the vector mu_j./sigma_j
# input:
# - X_data      n x k            matrix of moment functions
# - xi_draw     n x 1            vector random numbers from 1 to n
# - type        matrix(c(0, 1), nrow = 1, ncol = 2)           bootstrap version 0: no, 1: yes

# output:
# - salida      1 x k
m_hat <- function(X_data, xi_draw = NA, type = 0) {
  n <- nrow(X_data)

  if (type == 1) {
    X_data <- X_data[xi_draw, ]
  }

  mu_hat <- Rfast::colmeans(X_data)
  # normalize by n instead of n-1 as in matlab code
  sigma_hat <- Rfast::colVars(X_data, std = T) * sqrt((n - 1) / n)

  # as in eq (A.13) and similar to eq. (4.2) in Andrews and Kwon (2023)
  return(mu_hat / sigma_hat)
}
