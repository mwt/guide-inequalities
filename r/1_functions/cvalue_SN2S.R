## compute critical value defined in eq (41) of section 5 in Canay, Illanes, and Velez (2023)
# input
# - X_data          n x k    matrix of evaluated moment functions
# - alpha_input     1 x 1    significance level
# - beta_input      1 x 1    tuning parameter to select moments

# output
# - c_value         1 x 1    critical value

cvalue_SN2S <- function(X_data, alpha_input, beta_input)
{
  ## Step 0: parameter setting
  n <- nrow(X_data)# sample size
  k <- ncol(X_data)# number of moments
  alpha <- alpha_input
  beta <- beta_input
  
  if (beta < alpha / 2) {
    #     cat('Two step SN-method is running');
  } else {
    cat('beta is not lower than alpha/2: fix it!')
    cat('alpha is...')
    cat(alpha)
    cat('and beta is...')
    cat(beta)
    return()
  }
  
  ## Step 1: define set J_SN as almost binding
  
  c_sn0 <- cvalue_SN(X_data, beta)# as in eq (40)
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
    c_sn1 <- qq1 / sqrt(1 - qq1 ^ 2 / n)
  } else {
    c_sn1 <- 0
  }
  
  c_value <- c_sn1
  return(c_value)
}
