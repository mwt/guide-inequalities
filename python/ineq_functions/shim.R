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
  # number of products to evaluate one-product deviation
  J0 <- nrow(J0_vec)
  # number of firms
  S0 <- length(unique(J0_vec[, 2]))

  if (S0 != length(theta)) {
    stop("error on dimension of theta")
  } else {
    salida <- rep(0, J0)

    for (jj0 in 1:J0) {
      jj2 <- J0_vec[jj0, 2]
      theta_jj0 <- theta[jj2]
      # as in eq (26)
      salida[jj0] <-
        ((A_vec[jj0] - theta_jj0) * (1 - D_vec[jj0]) - Vbar * D_vec[jj0]) * Z_vec[jj0]
    }
    return(salida)
  }
}
# Moment inequality function defined in eq (27)
# input:
# - A_vec       J0 x 1      vector of estimated revenue differential in a market
# - D_vec       J0 x 1      vector of product portfolio in a market.
# - Z_vec       J0 x 1      vector of instruments in a market
# - J0_vec      J0 x 2      vector of products of coca-cola and energy-product
# - theta  d_theta x 1      parameter of interest
# - Vbar                    tuning parameter as in Assumption 4.2

# output:
# - salida      1 x J0      vector of the moment function.
MomentFunct_U <- function(A_vec,
                          D_vec,
                          Z_vec,
                          J0_vec,
                          theta,
                          Vbar) {
  # number of products to evaluate one-product deviation
  J0 <- nrow(J0_vec)
  # number of firms
  S0 <- length(unique(J0_vec[, 2]))

  if (S0 != length(theta)) {
    stop("error on dimension of theta")
  } else {
    salida <- rep(0, J0)

    for (jj0 in 1:J0) {
      jj2 <- J0_vec[jj0, 2]
      theta_jj0 <- theta[jj2]
      # as in eq (26)
      salida[jj0] <-
        ((A_vec[jj0] + theta_jj0) * D_vec[jj0] - Vbar * (1 - D_vec[jj0])) * Z_vec[jj0]
    }
    return(salida)
  }
}
## compute critical value defined in eq (48) of Section 5 in Canay, Illanes, and Velez (2023)
# input
# - X_data          n x k    matrix of evaluated moment functions
# - BB_input        1 x 1    number of bootstraps
# - alpha_input     1 x 1    significance level
# - beta_input      1 x 1    tuning parameter to select moments
# - rng_seed                 seed for replication purpose

# output
# - c_value         1 x 1    critical value

cvalue_EB2S <- function(X_data,
                        BB_input,
                        alpha_input,
                        beta_input,
                        rng_seed) {
  ## Step 1: paramater setting
  # sample size
  n <- nrow(X_data)
  # number of moments
  k <- ncol(X_data)
  BB <- BB_input
  alpha <- alpha_input
  beta <- beta_input

  if (beta < alpha / 2) {
    # cat('Two step EB-method is running')
  } else {
    stop(sprintf(
      "beta is not lower than alpha/2: fix it! alpha: %s, beta %s",
      alpha,
      beta
    ))
  }

  ## Step 2: Algorithm of the Empirical Bootstrap as in Section 5.2

  # to replicate results
  set.seed(rng_seed, kind = "Mersenne-Twister")
  draws_vector <- matrix(sample.int(n, n * BB, replace = T),
    nrow = n,
    ncol = BB
  )

  # matrix to save components of the empirical bootstrap test statistic
  WEB_matrix <- matrix(NA, BB, k)

  mu_hat <- Rfast::colmeans(X_data)
  # normalize by n instead of n-1 as in matlab code
  sigma_hat <- Rfast::colVars(X_data, std = T) * sqrt((n - 1) / n)

  for (kk in 1:BB) {
    # draw from the empirical distribution
    XX_draw <- X_data[draws_vector[, kk], ]
    # as in eq (45)
    WEB_matrix[kk, ] <-
      sqrt(n) * (1 / n) * (rep(1, n) %*% (XX_draw - rep(1, n) %*% t(mu_hat))) / sigma_hat
  }

  # Take maximum of each sample
  WEB_vector <- Rfast::rowMaxs(WEB_matrix, value = T)
  # Obtain quantile of bootstrap samples
  c_value0 <- Rfast2::Quantile(WEB_vector, 1 - beta)

  test_vector <- sqrt(n) * mu_hat / sigma_hat
  # as in eq (46)
  JJ <- sum(test_vector > (-2 * c_value0))

  if (JJ > 0) {
    WEB_matrix2 <- matrix(0, BB, JJ)
  } else {
    WEB_matrix2 <- matrix(0, BB, 1)
  }

  jj0 <- 0

  for (jj in 1:k) {
    test0 <- test_vector[jj]

    if (test0 > (-2 * c_value0)) {
      jj0 <- jj0 + 1
      # selection of moment inequalities
      WEB_matrix2[, jj0] <- WEB_matrix[, jj]
    }
  }

  # as in eq (47)
  WEB_vector2 <- Rfast::rowMaxs(WEB_matrix2, value = T)

  ## Step 3: Critical value
  # as in eq (48)
  c_value <- Rfast2::Quantile(WEB_vector2, 1 - alpha + 2 * beta)
  return(c_value)
}
## compute critical value defined in eq (40) of Section 5 in Canay, Illanes, and Velez (2023)
# input
# - X_data           n x k    matrix of evaluated moment functions
# - alpha_input      1 x 1    significance level

# output
# - c_value    1 x 1    critical value

cvalue_SN <- function(X_data, alpha_input) {
  ## Step 1: parameter setting
  n <- nrow(X_data) # sample size
  k <- ncol(X_data) # number of moments

  ## Step 2: calculations
  qq <- qnorm(1 - alpha_input / k)
  # as in eq (40)
  c_sn <- qq / sqrt(1 - qq^2 / n)

  c_value <- c_sn
  return(c_value)
}
## compute critical value defined in eq (41) of section 5 in Canay, Illanes, and Velez (2023)
# input
# - X_data          n x k    matrix of evaluated moment functions
# - alpha_input     1 x 1    significance level
# - beta_input      1 x 1    tuning parameter to select moments

# output
# - c_value         1 x 1    critical value

cvalue_SN2S <- function(X_data, alpha_input, beta_input) {
  ## Step 0: parameter setting
  n <- nrow(X_data) # sample size
  k <- ncol(X_data) # number of moments
  alpha <- alpha_input
  beta <- beta_input

  if (beta < alpha / 2) {
    #     cat('Two step SN-method is running');
  } else {
    stop(sprintf(
      "beta is not lower than alpha/2: fix it! alpha: %s, beta %s",
      alpha,
      beta
    ))
  }

  ## Step 1: define set J_SN as almost binding

  c_sn0 <- cvalue_SN(X_data, beta) # as in eq (40)
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
    c_sn1 <- qq1 / sqrt(1 - qq1^2 / n)
  } else {
    c_sn1 <- 0
  }

  c_value <- c_sn1
  return(c_value)
}
# Moment inequality function defined in eq (28)

# there are four main steps
# step 1: select moments with non-zero variance using ml_indx & mu_indx
# step 2: compute all the moment functions
# step 3: select the cumputed moments using ml_indx & mu_indx defined in step 1

# comment:
# - all the inputs are included in 'Amatrix200701_fake.mat'.
# - W_data = D_matrix(:,2:end);
# - J1 is the number of moments w/ no zero variance, see section 8.1.
# - n is the number of markets
# input:
# - W_data          n  x J          matrix of all product portfolio
# - A_matrix        n  x (1+J0)     matrix of revenue differential
# - theta      d_theta x 1          parameter of interest
# - J0_vec          J0 x 2          matrix of ownership by two firms
# - Vbar                            tuning parameter as in Assumption 4.2
# - IV_matrix   matrix(c(NA, NA, NA, NA), nrow = 1, ncol = 1)      instruments (empty if no instruments)
# - grid0       matrix(c(1, 2, NA), nrow = 1, ncol = 3)       searching direction

# output:
# - salida          n x J1          vector of the moment function.

m_function <- function(W_data,
                       A_matrix,
                       theta,
                       J0_vec,
                       Vbar,
                       IV_matrix,
                       grid0) {
  n <- nrow(A_matrix)
  J0 <- nrow(J0_vec)

  # Initialize output
  X_data <- NULL

  if (nrow(W_data) != n) {
    stop(sprintf("Wrong number of observations! %s != %s.", nrow(A_matrix), n))
  }

  ## step 1: select moments with non-zero variance using ml_indx & mu_indx
  #          the procedure follows the discussion of section 8.1

  aux1 <- Rfast::colsums(W_data)
  aux1 <- aux1[J0_vec[, 1]]

  if (grid0 == "all") {
    # include all the possible moments generated by products of coca-cola or energy-products
    ml_indx <- (1:J0)[aux1 < n]
    mu_indx <- (1:J0)[aux1 > 0]
  } else if (grid0 %in% 1:2) {
    # include only the possible moments generated by coca-cola (grid0=1) or energy-products (grid0=2)
    ml_indx <- (1:J0)[aux1 < n & J0_vec[, 2] == grid0]
    mu_indx <- (1:J0)[aux1 > 0 & J0_vec[, 2] == grid0]
  } else {
    stop(sprintf("grid 0 must be one of all,0,1. You entered %s.", grid0))
  }

  ## step 2: compute all the moment functions
  if (is.null(IV_matrix)) {
    Z_vec <- rep(1, J0)

    for (mm0 in 1:n) {
      # vector of estimated revenue differential in market mm0
      A_vec <- A_matrix[mm0, 2:(J0 + 1)]
      # vector of product portfolio of coca-cola and energy-products in market mm0
      D_vec <- W_data[mm0, J0_vec[, 1]]

      ml_vec <-
        MomentFunct_L(A_vec, D_vec, Z_vec, J0_vec, theta, Vbar)
      mu_vec <-
        MomentFunct_U(A_vec, D_vec, Z_vec, J0_vec, theta, Vbar)

      X_data <- rbind(X_data, c(ml_vec[ml_indx], mu_vec[mu_indx]))
    }
  } else {
    Z_vec <- rep(1, J0)
    # employment rate
    Z3_vec <-
      as.numeric(IV_matrix[, 2] > median(IV_matrix[, 2]))
    # average income in market
    Z5_vec <-
      as.numeric(IV_matrix[, 3] > median(IV_matrix[, 3]))
    # median income in market
    Z7_vec <-
      as.numeric(IV_matrix[, 4] > median(IV_matrix[, 4]))

    for (mm0 in 1:n) {
      # vector of estimated revenue differential in market mm0
      A_vec <- A_matrix[mm0, 2:(J0 + 1)]
      # vector of product portfolio of coca-cola and energy-products in market mm0
      D_vec <- W_data[mm0, J0_vec[, 1]]

      ml_vec <-
        MomentFunct_L(A_vec, D_vec, Z_vec, J0_vec, theta, Vbar)
      ml_vec3 <-
        MomentFunct_L(A_vec, D_vec, Z3_vec, J0_vec, theta, Vbar)
      ml_vec5 <-
        MomentFunct_L(A_vec, D_vec, Z5_vec, J0_vec, theta, Vbar)
      ml_vec7 <-
        MomentFunct_L(A_vec, D_vec, Z7_vec, J0_vec, theta, Vbar)

      mu_vec <-
        MomentFunct_U(A_vec, D_vec, Z_vec, J0_vec, theta, Vbar)
      mu_vec3 <-
        MomentFunct_U(A_vec, D_vec, Z3_vec, J0_vec, theta, Vbar)
      mu_vec5 <-
        MomentFunct_U(A_vec, D_vec, Z5_vec, J0_vec, theta, Vbar)
      mu_vec7 <-
        MomentFunct_U(A_vec, D_vec, Z7_vec, J0_vec, theta, Vbar)

      X_data <- rbind(
        X_data,
        c(
          ml_vec[ml_indx],
          mu_vec[mu_indx],
          ml_vec3[ml_indx],
          mu_vec3[mu_indx],
          ml_vec5[ml_indx],
          mu_vec5[mu_indx],
          ml_vec7[ml_indx],
          mu_vec7[mu_indx]
        )
      )
    }
  }

  ## step 3: select the computed moments using ml_indx & mu_indx defined in step 1
  salida <- X_data
  return(salida)
}
# Compute a standarized sample mean of the moment functions as in eq (A.13)

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
m_hat <- function(X_data,
                  xi_draw = NA,
                  type = 0) {
  n <- nrow(X_data)

  if (type == 1) {
    X_data <- X_data[xi_draw, ]
  }

  Xmean <- Rfast::colmeans(X_data)
  # normalize by n instead of n-1 as in matlab code
  Xstd <- Rfast::colVars(X_data, std = T) * sqrt((n - 1) / n)

  # as in eq (A.13) and similar to eq. (4.2) in Andrews and Kwon (2023)
  Xhat <- Xmean / Xstd

  return(Xhat)
}
