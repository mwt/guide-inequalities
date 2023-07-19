# Compute Test Statistic and Critical Value

Compute Test Statistic and Critical Value

    g_restriction(
      theta,
      w_data,
      a_matrix,
      j0_vector,
      v_bar,
      alpha,
      grid0 = "all",
      iv_matrix = NULL,
      test0 = "CCK",
      cvalue = "SN",
      account_uncertainty = FALSE,
      bootstrap_replications = NULL,
      rng_seed = NULL,
      bootstrap_indices = NULL,
      an_vec = NULL,
      hat_r_inf = NULL,
      dist_data = NULL
    )

## Arguments

`theta`

a vector containing the parameters of interest.

`w_data`

an n x k matrix of product portfolio data.

`a_matrix`

an n x (J0 + 1) matrix of estimated revenue differentials.

`j0_vector`

a J0 x 2 matrix of ownership by the two firms.

`v_bar`

a tuning parameter as in Assumption 4.2.

`alpha`

the significance level.

`grid0`

optional vector of length J0 containing the indices of the products in the market.

`iv_matrix`

optional n x d_iv matrix of instruments.

`test0`

optional test statistic to use. Either "CCK" or "RC-CCK".

`cvalue`

optional critical value to use. Either "SPUR1", "SN", "SN2S", or "EB2S".

`account_uncertainty`

Whether to account for additional uncertainty (as in Equations 49 and 50). If TRUE, the last two elements of theta are assumed to be mu.

`bootstrap_replications`

the number of bootstrap replications. Required if bootstrap_indices is not specified.

`rng_seed`

the seed for replication purposes. If not specified, the seed is not set.

`bootstrap_indices`

an integer vector of indices to use for the bootstrap. If this is specified, bootstrap_replications and rng_seed will be ignored. If this is not specified, bootstrap_replications is required.

`an_vec`

if using SPUR1, an n-dimensional vector of An values.

`hat_r_inf`

if using RC-CCK, the lower value of the test statistic.

`dist_data`

an n x (J + 1) matrix of distances from the product factories to the cities.

## Value

a vector containing the test statistic and critical value.
