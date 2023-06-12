#' Get Bootstrap Indices
#'
#' @param num_rows Number of rows in the data.
#' @param bootstrap_replications the number of bootstrap replications.
#'   Required if bootstrap_indices is not specified.
#' @param rng_seed the seed for replication purposes. If not specified, the
#'   seed is not set.
#' @param bootstrap_indices an integer vector of indices to use for the
#'   bootstrap. If this is specified, bootstrap_replications and rng_seed will
#'   be ignored. If this is not specified, bootstrap_replications is required.
#'
#' @return an integer vector of indices to use for the bootstrap.
#' @export
get_bootstrap_indices <- function(num_rows, bootstrap_replications = NULL, rng_seed = NULL, bootstrap_indices = NULL) {
    if (!is.null(bootstrap_indices)) {
        return(bootstrap_indices)
    }
    if (!is.null(bootstrap_replications)) {
        if (!is.null(rng_seed)) {
            set.seed(rng_seed, kind = "Mersenne-Twister")
        }
        # Generate indices if not specified
        return(
            sample.int(
                num_rows,
                num_rows * bootstrap_replications,
                replace = TRUE
            )
        )
    } else {
        stop(
            "bootstrap_replications must be specified if bootstrap_indices is not."
        )
    }
}
