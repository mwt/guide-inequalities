# This function find the test statistic and critical value as in Section 5
# - the test statistic is as in eq. (38)
# - the critical value is as in eq. (40), (41) and (48)
#
# Comment:
# - it also includes the re-centered test statistic as in section 8.2.2
#   and critical value SPUR1 as in Appendix Section C.
# - the implicit reference for equations is Canay, Illanes, and Velez (2023)
# input:
# - W_data              n  x J              matrix of all product portfolio
# - A_matrix            n  x (1+J0)         matrix of revenue differential
# - theta0         d_theta x 1              parameter of interest
# - J0_vec              J0 x 2              matrix of ownership by two firms (coca-cola, energy-brands)
# - Vbar                                    tuning parameter as in Assumption 4.2
# - IV_matrix   matrix(c(NA, NA, NA, NA), nrow = 1, ncol = 1)              instruments (empty if no instruments)
# - grid0       matrix(c(1, 2, NA), nrow = 1, ncol = 3)               searching direction
# - test0       matrix(c(NA, NA), nrow = 1, ncol = 1)            two possible type of tests
# - cvalue   matrix(c(NA, NA, NA, NA), nrow = 1, ncol = 4)  four possible type of critical values
# - alpha_input           1 x 1             level of tests
# - num_boots             1 x 1             number of bootstrap draws
# - rng_seed                                seed for replication purpose
#
# - An_vec        num_boots x 1             vector as in eq. (4.25) in Andrews and Kwon (2023), only useful to compute c.value SPUR1
# - hat_r_inf             1 x 1             lower value of the test as in eq. (4.4)  in Andrews and Kwon (2023), only useful to recenter the test (RC-CCK)

# output:
# - salida                1 x 2             (test, cvalue)

G_restriction <- function(W_data,
                          A_matrix,
                          theta0,
                          J0_vec,
                          Vbar,
                          IV_matrix,
                          grid0,
                          test0,
                          cvalue,
                          alpha_input,
                          num_boots,
                          rng_seed,
                          An_vec = NA,
                          hat_r_inf = NA)
{
  if (is.na(An_vec) && is.na(hat_r_inf)) {
    if (test0 == 'CCK') {
      X_data <-
        m_function(W_data, A_matrix, theta0, J0_vec, Vbar, IV_matrix, grid0)
      m_hat0 <- m_hat(X_data)
      n <- (dim(X_data)[1])
      
      T_n <- sqrt(n) * m_hat0
      # as in eq (38)
      T_n <- max(T_n)
      
      if (cvalue == 'SN') {
        # as in eq (40)
        c_value <- cvalue_SN(X_data, alpha)
      }
      
      if (cvalue == 'SN2S') {
        # see Section 4.2.2 in Chernozhukov et al. (2019)
        beta_input <- alpha_input / 50
        # as in eq (41)
        c_value <- cvalue_SN2S(X_data, alpha_input, beta_input)
      }
      
      if (cvalue == 'EB2S') {
        # see Section 4.2.2 in Chernozhukov et al. (2019)
        beta_input <- alpha_input / 50
        # as in eq (48)
        c_value <-
          cvalue_EB2S(X_data, num_boots, alpha_input, beta_input, rng_seed)
      }
      
      salida <- c(T_n, c_value)
      return(salida)
    }
    
  } else if (is.numeric(An_vec) && is.numeric(hat_r_inf)) {
    if (test0 == 'RC-CCK') {
      # in order to use the same condition on the moments as in eq. (3.1) in Andrews and Kwon (2023)
      X_data <-
        -m_function(W_data, A_matrix, theta0, J0_vec, Vbar, IV_matrix, grid0)
      # as in eq. (4.2) in Andrews and Kwon (2023)
      m_hat0 <- m_hat(X_data)
      n <- (dim(X_data)[1])
      
      # re-centering step as in (4.5) in  Andrews and Kwon (2023)
      S_n <- sqrt(n) * (m_hat0 + hat_r_inf)
      # = max(-S_n) = T_n recentered, since by definition S_n <=0
      S_n <- max(-min(S_n, 0))
      
      if (cvalue == 'SPUR1') {
        # compute the critical value presented in Section 4.4 in Andrews and Kwon (2023)
        c_value <-
          cvalue_SPUR1(X_data, num_boots, alpha_input, An_vec, rng_seed)
      }
      
      if (cvalue == 'SN2S') {
        beta_input <- alpha_input / 50
        X_data <-
          m_function(W_data, A_matrix, theta0, J0_vec, Vbar, IV_matrix, grid0)
        # as in eq (41)
        c_value <- cvalue_SN2S(X_data, alpha_input, beta_input)
      }
      
      if (cvalue == 'EB2S') {
        beta_input <- alpha_input / 50
        X_data <-
          m_function(W_data, A_matrix, theta0, J0_vec, Vbar, IV_matrix, grid0)
        # as in eq (48)
        c_value <-
          cvalue_EB2S(X_data, num_boots, alpha_input, beta_input, rng_seed)
      }
      
      salida <- c(S_n, c_value)
      return(salida)
    }
    
  } else {
    cat('goal!')
    stop('there are typos in the number of inputs! ')
    
  }
  
}
