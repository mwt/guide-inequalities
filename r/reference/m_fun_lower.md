[^ README](../README.md)

# Lower Moment Inequality Function

Lower Moment Inequality Function

    m_fun_lower(
      theta,
      d_matrix,
      a_subset,
      j0_vector,
      v_bar,
      z_matrix = 1,
      dist_subset = NULL
    )

## Arguments

`theta`

a vector containing the parameters of interest.

`d_matrix`

an n x j0 matrix of product portfolio in each market.

`a_subset`

an n x j0 matrix of estimated revenue differential in each market.

`j0_vector`

a j0 x 2 matrix of ownership by the two firms.

`v_bar`

a tuning parameter as in Assumption 4.2.

`z_matrix`

an optional n x j0 matrix of instruments in each market.

`dist_subset`

an optional n x j0 matrix of distance between products in each market.

## Value

a j0-dimensional vector of lower moment inequalities.
