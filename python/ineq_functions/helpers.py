import numpy as np


def get_bootstrap_indices(
    num_rows: int,
    bootstrap_replications: int | None = None,
    rng_seed: int | None = None,
    bootstrap_indices: np.ndarray | None = None,
) -> np.ndarray:
    """Generate bootstrap indices for the bootstrap replications.

    Parameters
    ----------
    num_rows : int
        Number of rows in the data.
    bootstrap_replications : int, optional
        Number of bootstrap replications. Required if bootstrap_indices
        is not specified.
    rng_seed : int, optional
        Random number generator seed (for replication purposes). If not
        specified, the system seed will be used as-is.
    bootstrap_indices : array_like, optional
        Integer array of shape (bootstrap_replications, n) for the bootstrap
        replications. If this is specified, bootstrap_replications and rng_seed
        will be ignored. If this is not specified, bootstrap_replications is
        required.

    Returns
    -------
    array_like
        Integer array of shape (bootstrap_replications, num_rows) for the
        bootstrap replications.
    """
    # Passthrough if bootstrap_indices is specified
    if bootstrap_indices is not None:
        return bootstrap_indices
    # Generate bootstrap indices if not specified
    if bootstrap_replications is not None:
        if rng_seed is not None:
            np.random.seed(rng_seed)
        return np.random.randint(0, num_rows, size=(bootstrap_replications, num_rows))
    else:
        raise ValueError(
            "bootstrap_replications must be specified if bootstrap_indices is not."
        )
