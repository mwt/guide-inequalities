% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/moment.R
\name{m_function}
\alias{m_function}
\title{Moment Inequality Function}
\usage{
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
}
\arguments{
\item{theta}{a vector containing the parameters of interest.}

\item{w_data}{an n x k matrix of product portfolio data.}

\item{a_matrix}{an n x (num_products + 1) matrix of estimated revenue differentials.}

\item{j0_vector}{a num_products x 2 matrix of ownership by the two firms.}

\item{v_bar}{a tuning parameter as in Assumption 4.2.}

\item{grid0}{optional vector of length num_products containing the indices of the
products in the market.}

\item{iv_matrix}{optional n x d_iv matrix of instruments.}

\item{dist_data}{an n x (J + 1) matrix of distances from the product
factories to the cities.}
}
\value{
a matrix of the moment functions with n rows.
}
\description{
Moment Inequality Function
}
