[⮝ README](../README.md)

# Moment Inequality Function

Moment Inequality Function

    m_function(
      theta,
      w_data,
      a_matrix,
      j0_vector,
      v_bar,
      grid0 = "all",
      iv_matrix = NULL,
      dist_data = NULL
    )

## Arguments

`theta`

a vector containing the parameters of interest.

`w_data`

an n x k matrix of product portfolio data.

`a_matrix`

an n x (num_products + 1) matrix of estimated revenue differentials.

`j0_vector`

a num_products x 2 matrix of ownership by the two firms.

`v_bar`

a tuning parameter as in Assumption 4.2.

`grid0`

optional vector of length num_products containing the indices of the products in the market.

`iv_matrix`

optional n x d_iv matrix of instruments.

`dist_data`

an n x (J + 1) matrix of distances from the product factories to the cities.

## Value

a matrix of the moment functions with n rows.
