# This function finds the test statistic and critical value as in Section 5
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
                          An_vec = NULL,
                          hat_r_inf = NULL) {
  if ((cvalue == "SPUR1" || test0 == "RC-CCK") && (is.null(An_vec) || is.null(hat_r_inf))) {
    stop("SPUR1 requires An_vec and hat_r_inf to be defined")
  }

  X_data <- m_function(W_data, A_matrix, theta0, J0_vec, Vbar, IV_matrix, grid0)
  m_hat0 <- m_hat(X_data)
  n <- nrow(X_data)

  # see Section 4.2.2 in Chernozhukov et al. (2019)
  beta_input <- alpha_input / 50

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
  ##    (note, we use -X_data to match their condition)
  ## 2. SN as in eq (40)
  ## 3. SN2S as in eq (41)
  ## 4. EB2S as in eq (48)
  critical_value <-
    switch(cvalue,
      SPUR1 = cvalue_SPUR1(-X_data, num_boots, alpha_input, An_vec, rng_seed),
      SN = cvalue_SN(X_data, alpha_input),
      SN2S = cvalue_SN2S(X_data, alpha_input, beta_input),
      EB2S = cvalue_EB2S(X_data, num_boots, alpha_input, beta_input, rng_seed),
      stop(
        sprintf(
          "cvalue must be one of SPUR1, SN, SN2S, EB2S. You entered %s.",
          cvalue
        )
      )
    )
  return(c(test_stat, critical_value))
}
