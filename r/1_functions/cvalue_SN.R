## compute critical value defined in eq (40) of Section 5 in Canay, Illanes, and Velez (2023)
# input
# - X_data           n x k    matrix of evaluated moment functions
# - alpha_input      1 x 1    significance level

# output
# - c_value    1 x 1    critical value

cvalue_SN <- function(X_data, alpha_input)
{
  ## Step 1: parameter setting
  n <- nrow(X_data)# sample size
  k <- ncol(X_data)# number of moments
  
  ## Step 2: calculations
  qq <- qnorm(1 - alpha_input / k)
  # as in eq (40)
  c_sn <- qq / sqrt(1 - qq ^ 2 / n)
  
  c_value <- c_sn
  return(c_value)
}
