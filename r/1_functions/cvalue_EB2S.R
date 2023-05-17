## compute critical value defined in eq (48) of Section 5 in Canay, Illanes, and Velez (2023)
# input
# - X_data          n x k    matrix of evaluated moment functions
# - bootstrap_replications        1 x 1    number of bootstraps
# - alpha     1 x 1    significance level
# - beta      1 x 1    tuning parameter to select moments
# - rng_seed                 seed for replication purpose

# output
# - c_value         1 x 1    critical value

cvalue_EB2S <- function(X_data, alpha, beta, bootstrap_replications=NULL, rng_seed=NULL, bootstrap_indices=NULL) {
  # sample size
  n <- nrow(X_data)
  # number of moments
  k <- ncol(X_data)

  if (beta >= alpha / 2) {
    stop(sprintf(
      "beta is not lower than alpha/2: fix it! alpha: %s, beta %s",
      alpha,
      beta
    ))
  }

  # Step 1: Algorithm of the Empirical Bootstrap as in Section 5.2
  
  ## Compute the mean of each column of X_data
  mu_hat <- Rfast::colsums(X_data)/n
  ## Compute the standard deviation of each column of X_data 
  ## (normalize by n instead of n-1 as in MATLAB code)
  sigma_hat <- Rfast::colVars(X_data, std = T) * sqrt((n - 1) / n)

  # to replicate results
  if(is.null(bootstrap_indices)) {
    if(is.null(bootstrap_replications)) {
      stop(
        "bootstrap_replications must be specified if bootstrap_indices is not."
      )
    } else {
      if(!is.null(rng_seed)){
        set.seed(rng_seed, kind = "Mersenne-Twister")
      }
      # Generate indices if not specified
      BB <- bootstrap_replications
      bootstrap_indices <- 
        matrix(sample.int(n, n * BB, replace = T), nrow = n, ncol = BB)
    }
  } else {
    BB <- ncol(bootstrap_indices)
  }

  # matrix to save components of the empirical bootstrap test statistic
  WEB_matrix <- matrix(NA, BB, k)
  for (kk in 1:BB) {
    # draw from the empirical distribution
    XX_draw <- X_data[bootstrap_indices[, kk], ]
    # as in eq (45)
    # (double transpose is because R broadcasts column vectors)
    WEB_matrix[kk, ] <- t(
      sqrt(n) * (1 / n) * Rfast::rowsums((t(XX_draw) - mu_hat)) / sigma_hat
    )
  }
    
  ## We could do something vectorized instead of the above loop, e.g.
  ## Indexing trick, stricture is now:
  ## [ Col1 from BB1, Col2 from BB1, ... Col1 from BB2, Col2 from BB2, ... ]
  #  X_samples <- matrix(X_data[bootstrap_indices, ], nrow = n)
  #  X_means <- matrix(Rfast::colsums(X_samples)/n, nrow = BB, ncol = k, byrow = F)
  ## Follow the steps in eq (45)
  ## (double transpose is because R broadcasts column vectors)
  #  WEB_matrix <- t(
  #   (sqrt(n) * (t(X_means) - mu_hat)) / sigma_hat
  #  )
  ## However, this is actually significantly slower than just looping
    
  ## Take maximum of each sample
  WEB_vector <- Rfast::rowMaxs(WEB_matrix, value = T)
  
  ## Obtain quantile of bootstrap samples
  cvalue0 <- Rfast2::Quantile(WEB_vector, 1 - beta)
  
  ## Studentized statistic for each moment inequality
  test_stat0 <- sqrt(n) * mu_hat / sigma_hat
  
  # Step 2: Critical value

  ## Selection of moment inequalities that are almost binding as in eq (46)
  almost_binding <- (test_stat0 > (-2 * cvalue0))
  if (any(almost_binding)){
    WEB_matrix2 <- WEB_matrix[, almost_binding]
    WEB_vector2 <- Rfast::rowMaxs(WEB_matrix2, value = T)
    cvalue1 <- Rfast2::Quantile(WEB_vector2, 1 - alpha + 2 * beta)
  } else {
    cvalue1 <- 0
  }
  
  return(cvalue1)
}
