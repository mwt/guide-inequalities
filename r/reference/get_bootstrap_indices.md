[^ README](../README.md)

# Get Bootstrap Indices

Get Bootstrap Indices

    get_bootstrap_indices(
      num_rows,
      bootstrap_replications = NULL,
      rng_seed = NULL,
      bootstrap_indices = NULL
    )

## Arguments

`num_rows`

Number of rows in the data.

`bootstrap_replications`

the number of bootstrap replications. Required if bootstrap_indices is not specified.

`rng_seed`

the seed for replication purposes. If not specified, the seed is not set.

`bootstrap_indices`

an integer vector of indices to use for the bootstrap. If this is specified, bootstrap_replications and rng_seed will be ignored. If this is not specified, bootstrap_replications is required.

## Value

an integer vector of indices to use for the bootstrap.
