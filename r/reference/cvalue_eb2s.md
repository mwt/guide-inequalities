[^ README](../README.md)

# Bootstrap Critical Value

Bootstrap Critical Value

    cvalue_eb2s(
      x_data,
      alpha,
      beta = alpha/50,
      bootstrap_replications = NULL,
      rng_seed = NULL,
      bootstrap_indices = NULL
    )

## Arguments

`x_data`

an n x k matrix of evaluated moment functions.

`alpha`

the confidence level required for the first stage test.

`beta`

optional confidence level required for the second stage test.

`bootstrap_replications`

the number of bootstrap replications. Required if bootstrap_indices is not specified.

`rng_seed`

the seed for replication purposes. If not specified, the seed is not set.

`bootstrap_indices`

an integer vector of indices to use for the bootstrap. If this is specified, bootstrap_replications and rng_seed will be ignored. If this is not specified, bootstrap_replications is required.

## Value

a float for the critical value.
