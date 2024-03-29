% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/moment.R
\name{m_fun_upper}
\alias{m_fun_upper}
\title{Upper Moment Inequality Function}
\usage{
m_fun_upper(
  theta,
  d_matrix,
  a_subset,
  j0_vector,
  v_bar,
  z_matrix = 1,
  dist_subset = NULL
)
}
\arguments{
\item{theta}{a vector containing the parameters of interest.}

\item{d_matrix}{an n x j0 matrix of product portfolio in each market.}

\item{a_subset}{an n x j0 matrix of estimated revenue differential in each
market.}

\item{j0_vector}{a j0 x 2 matrix of ownership by the two firms.}

\item{v_bar}{a tuning parameter as in Assumption 4.2.}

\item{z_matrix}{an optional n x j0 matrix of instruments in each market.}

\item{dist_subset}{an optional n x j0 matrix of distance between products in
each market.}
}
\value{
a j0-dimensional vector of upper moment inequalities.
}
\description{
Upper Moment Inequality Function
}
