# Python Code for "A User's Guide for Inference in Models Defined by Moment Inequalities"

This folder contains PYTHON to replicate the results in the paper "A User's Guide for Inference in Models Defined by Moment Inequalities" by Canay, Illanes, and Velez available [here](https://faculty.wcas.northwestern.edu/iac879/wp/inequalities-guide.pdf). The code is organized with five table files and a folder with auxiliary functions.

## Table Files

The table files are:

- `table_1a.m`: Replicates Table 1, Panel A in Section 8.1.
- `table_1b.m`: Replicates Table 1, Panel B in Section 8.1.
- `table_2.m`: Replicates Table 2 in Section 8.2.1.
- `table_3.m`: Replicates Table 3 in Section 8.2.2.
- `table_4.m`: Replicates Table 4 in Section 8.2.3.

## Library Modules

The modules are contained in the folder `ineq_functions` and have the following dependency structure:

* [ineq\_functions.g\_restriction](#ineq_functions.g_restriction)
  * [g\_restriction](#ineq_functions.g_restriction)
  * [g\_restriction\_diff](#ineq_functions.g_restriction_diff)
* [ineq\_functions.moment](#ineq_functions.moment)
  * [m\_hat](#ineq_functions.moment.m_hat)
  * [m\_function](#ineq_functions.moment.m_function)
  * [m\_fun\_lower](#ineq_functions.moment.m_fun_lower)
  * [m\_fun\_upper](#ineq_functions.moment.m_fun_upper)
  * [find\_dist](#ineq_functions.moment.find_dist)
* [ineq\_functions.cvalue](#ineq_functions.cvalue)
  * [base\_sn](#ineq_functions.cvalue.base_sn)
  * [cvalue\_sn](#ineq_functions.cvalue.cvalue_sn)
  * [cvalue\_sn2s](#ineq_functions.cvalue.cvalue_sn2s)
  * [cvalue\_eb2s](#ineq_functions.cvalue.cvalue_eb2s)
* [ineq\_functions.andrews\_kwon](#ineq_functions.andrews_kwon)
  * [rhat](#ineq_functions.andrews_kwon.rhat)
  * [compute\_an\_vec](#ineq_functions.andrews_kwon.compute_an_vec)
  * [an\_star](#ineq_functions.andrews_kwon.an_star)
  * [cvalue\_spur1](#ineq_functions.andrews_kwon.cvalue_spur1)
  * [std\_b\_vec](#ineq_functions.andrews_kwon.std_b_vec)
  * [tn\_star](#ineq_functions.andrews_kwon.tn_star)

### Submodule `g_restriction`

<a id="ineq_functions.g_restriction"></a>

#### `g_restriction`

```python
def g_restriction(theta: np.ndarray,
                  w_data: np.ndarray,
                  a_matrix: np.ndarray,
                  j0_vector: np.ndarray,
                  v_bar: float,
                  alpha: float,
                  grid0: int | str = "all",
                  iv_matrix: np.ndarray | None = None,
                  test0: str = "CCK",
                  cvalue: str = "SN",
                  account_uncertainty: bool = False,
                  bootstrap_replications: int | None = None,
                  rng_seed: int | None = None,
                  bootstrap_indices: np.ndarray | None = None,
                  an_vec: np.ndarray | None = None,
                  hat_r_inf: float | None = None,
                  dist_data: np.ndarray | None = None) -> list[float, float]
```

> This high-level function parses arguments and calls the appropriate
> function for the test statistic and critical value.
> 
> Parameters
> ----------
>
> theta : array_like
>     d_theta x 1 parameter of interest.
>
> w_data : array_like
>     n x j0 matrix of product portfolio.
>
> a_matrix : array_like
>     n x (j0 + 1) matrix of estimated revenue differentials.
>
> j0_vector : array_like
>     j0 x 2 matrix of ownership by two firms.
>
> v_bar : float
>     Tuning parameter as in Assumption 4.2.
>
> alpha : float
>     Significance level.
>
> grid0 : {1, 2, 'all'}
>     Grid direction to use for the estimation of the model.
>
> iv_matrix : array_like or None
>     n x d_IV matrix of instruments or None if no instruments are used.
>
> test0 : {'CCK', 'RC-CCK'}
>     Test statistic to use.
>
> cvalue : {'SPUR1', 'SN', 'SN2S', 'EB2S'}
>     Critical value to use.
>
> account_uncertainty : bool, default False
>     Whether to account for additional uncertainty (as in Equations 49 and
>     50). If True, the last two elements of theta are assumed to be mu.
>
> bootstrap_replications : int, optional
>     Number of bootstrap replications. Required if bootstrap_indices
>     is not specified.
>
> rng_seed : int, optional
>     Random number generator seed (for replication purposes). If not
>     specified, the system seed will be used as-is.
>
> bootstrap_indices : array_like, optional
>     Integer array of shape (bootstrap_replications, n) for the bootstrap
>     replications. If this is specified, bootstrap_replications and rng_seed
>     will be ignored. If this is not specified, bootstrap_replications is
>     required.
>
> an_vec : array_like, optional
>     If using SPUR 1, a n x 1 vector of An values as in eq. (4.25) in
>     Andrews and Kwon (2023).
>
> hat_r_inf : float, optional
>     If using RC-CCK, the lower value of the test as in eq. (4.4) in
>     Andrews and Kwon (2023).
>
> dist_data : array_like, optional
>     n x (J + 1) matrix of distances between product factories and cities.
> 
> Returns
> -------
>
> test_stat : float
>     The specified test statistic.
>
> critical_value : float
>     The critical value.
> 
> Notes
> -----
>   - The test statistic is defined in eq (38)
>   - The possible critical values are defined in eq (40), (41), and (48)
>   - This function also includes the re-centered test statistic as in
>     Section 8.2.2 and critical value SPUR1 as in Appendix Section C.

<a id="ineq_functions.g_restriction_diff"></a>

#### `g_restriction_diff`

```python
def g_restriction_diff(*args, **kwargs)
```

> Wrapper function for :func:`g_restriction` to be used with scipy.optimize

### Submodule `moment`

<a id="ineq_functions.moment.m_hat"></a>

#### `m_hat`

```python
def m_hat(x_data: np.ndarray, axis: int = 0) -> np.ndarray
```

> Compute a standardized sample mean of the moment functions as in eq (A.13)
> 
> Parameters
> ----------
>
> x_data : array_like
>     n x k matrix of the moment functions with n rows (output of
>     :func:`ineq_functions.m_function`).
>
> axis : int, default=0
>     Axis along which the mean and standard deviation are computed.
> 
> Returns
> -------
> array_like
>     Vector of the standardized sample mean of the moment functions.
> 
> Notes
> -----
>   - this function is useful for the procedure in Andrews and Kwon (2023)
>   - define :math:`x_{ij} = m_j(w_i,theta)`, n: sample size, k: number of moments
>   - define :math:`mu_j` as sample mean of :math:`x_{ij}` and
>     :math:`sigma_j` std. of :math:`x_ij`
>   - this function computes the vector :math:`mu_j / sigma_j`

<a id="ineq_functions.moment.m_function"></a>

#### `m_function`

```python
def m_function(theta: np.ndarray,
               w_data: np.ndarray,
               a_matrix: np.ndarray,
               j0_vector: np.ndarray,
               v_bar: float,
               grid0: int | str = "all",
               iv_matrix: np.ndarray | None = None,
               dist_data: np.ndarray | None = None) -> np.ndarray
```

> Moment inequality function defined in eq (28)
> 
> There are four main steps:
>  1. Select moments with non-zero variance using ml_indx & mu_indx.
>  2. Compute all the moment functions.
>  3. Select the computed moment functions using ml_indx & mu_indx.
> 
> Parameters
> ----------
>
> theta : array_like
>     d_theta x 1 parameter of interest.
>
> w_data : array_like
>     n x j0 matrix of product portfolio.
>
> a_matrix : array_like
>     n x (j0 + 1) matrix of estimated revenue differentials.
>
> j0_vector : array_like
>     j0 x 2 matrix of ownership by two firms.
>
> v_bar : float
>     Tuning parameter as in Assumption 4.2
>
> grid0 : {1, 2, 'all'}, default='all'
>     Grid direction to use for the estimation of the model.
>
> iv_matrix : array_like, optional
>     n x d_IV matrix of instruments or None if no instruments are used.
>
> dist_data : array_like, optional
>     n x (J + 1) matrix of distances between product factories and cities.
> 
> Returns
> -------
> array_like
>     Matrix of the moment functions with n rows.

<a id="ineq_functions.moment.m_fun_lower"></a>

#### `m_fun_lower`

```python
def m_fun_lower(theta: np.ndarray,
                d_matrix: np.ndarray,
                a_subset: np.ndarray,
                j0_vector: np.ndarray,
                v_bar: float,
                z_matrix: np.ndarray,
                dist_subset: np.ndarray | None = None) -> np.ndarray
```

> Moment inequality function defined in eq (26)
> 
> Parameters
> ----------
>
> theta : array_like
>     d_theta x 1 parameter of interest.
>
> d_matrix : array_like
>     n X j0 matrix of product portfolio in a market.
>
> a_subset : array_like
>     n X j0 matrix of estimated revenue differential in a market.
>
> j0_vector : array_like
>     j0 x 2 array of products of coca-cola and energy-product.
>
> v_bar : float
>     Tuning parameter as in Assumption 4.2.
>
> z_matrix : array_like
>     n X j0 matrix of instruments in a market.
>
> dist_subset : array_like, optional
>     n x j0 matrix of distance between products in a market, by default None.
> 
> Returns
> -------
> array_like
>     1 x j0 vector of the moment function.

<a id="ineq_functions.moment.m_fun_upper"></a>

#### `m_fun_upper`

```python
def m_fun_upper(theta: np.ndarray,
                d_matrix: np.ndarray,
                a_subset: np.ndarray,
                j0_vector: np.ndarray,
                v_bar: float,
                z_matrix: np.ndarray,
                dist_subset: np.ndarray | None = None) -> np.ndarray
```

> Moment inequality function defined in eq (27)
> 
> Parameters
> ----------
>
> theta : array_like
>     d_theta x 1 parameter of interest.
>
> d_matrix : array_like
>     n X j0 matrix of product portfolio in a market.
>
> a_subset : array_like
>     n X j0 matrix of estimated revenue differential in a market.
>
> j0_vector : array_like
>     j0 x 2 array of products of coca-cola and energy-product.
>
> v_bar : float
>     Tuning parameter as in Assumption 4.2.
>
> z_matrix : array_like
>     n X j0 matrix of instruments in a market.
>
> dist_subset : array_like, optional
>     n x j0 matrix of distance between products in a market, by default None.
> 
> Returns
> -------
> array_like
>     1 x j0 vector of the moment function.
> 
> Notes
> -----
> Calls m_fun_lower with two substitutions:
> 1. theta is negated
> 2. d_matrix replaced with 1 - d_matrix

<a id="ineq_functions.moment.find_dist"></a>

#### `find_dist`

```python
def find_dist(dist_data: np.ndarray, j0_vector: np.ndarray) -> np.ndarray
```

> Find maximum distance from each firm's factory to the market.
> 
> Parameters
> ----------
>
> dist_data : array_like
>     n x j0 matrix of distance between products in a market.
>
> j0_vector : array_like
>     j0 x 2 array of products of coca-cola and energy-product.
> 
> Returns
> -------
>
> coke_max_dist : array_like
>     n dimensional vector of maximum distance from coca-cola factory to
>     each market.
>
> ener_max_dist : array_like
>     n dimensional vector of maximum distance from energy-product factory
>     to each market.
> 
> Notes
> -----
> This function is used only in Table 4.

### Submodule `cvalue`

<a id="ineq_functions.cvalue.base_sn"></a>

#### `base_sn`

```python
def base_sn(n: int, k: int, alpha: float) -> float
```

> Base function for the SN test statistic defined in eq (40) of
> Section 5 in Canay, Illanes, and Velez (2023). This function is called
> by the other cvalue functions. It is not exported. Function
> :func:`ineq_functions.cvalue.cvalue_sn` is a convenience wrapper that sets
> n and k based on the dimensions of the input matrix.
> 
> Parameters
> ----------
>
> n : int
>     Sample size.
>
> k : int
>     Number of moments.
>
> alpha : float
>     Significance level.
> 
> Returns
> -------
> float
>     The SN critical value.

<a id="ineq_functions.cvalue.cvalue_sn"></a>

#### `cvalue_sn`

```python
def cvalue_sn(x_data: np.ndarray, alpha: float) -> float
```

> Calculate the c-value for the SN test statistic defined in eq (40) of
> Section 5 in Canay, Illanes, and Velez (2023). This is a convenience
> wrapper for :func:`ineq_functions.cvalue.base_sn` that sets n and k based
> on the dimensions of the input matrix.
> 
> Parameters
> ----------
>
> x_data : array_like
>     Matrix of the moment functions with n rows (output of
>     :func:`ineq_functions.m_function`).
>
> alpha : float
>     Significance level.
> 
> Returns
> -------
> float
>     The c-value for the SN test statistic.

<a id="ineq_functions.cvalue.cvalue_sn2s"></a>

#### `cvalue_sn2s`

```python
def cvalue_sn2s(x_data: np.ndarray,
                alpha: float,
                beta: float | None = None) -> float
```

> Calculate the c-value for the SN2S test statistic defined in eq (41) of
> Section 5 in Canay, Illanes, and Velez (2023).
> 
> Parameters
> ----------
>
> x_data : array_like
>     n x k matrix of the moment functions with n rows (output of
>     :func:`ineq_functions.m_function`).
>
> alpha : float
>     Significance level for the first stage test.
>
> beta : float, default: alpha / 50
>     Significance level for the second stage test.
> 
> Returns
> -------
> float
>     The c-value for the SN2S test statistic.

<a id="ineq_functions.cvalue.cvalue_eb2s"></a>

#### `cvalue_eb2s`

```python
def cvalue_eb2s(x_data: np.ndarray,
                alpha: float,
                beta: float | None = None,
                bootstrap_replications: int | None = None,
                rng_seed: int | None = None,
                bootstrap_indices: np.ndarray | None = None) -> float
```

> Calculate the c-value for the EB2S test statistic defined in eq (48) of
> Section 5 in Canay, Illanes, and Velez (2023).
> 
> Parameters
> ----------
>
> x_data : array_like
>     n x k matrix of the moment functions with n rows (output of
>     :func:`ineq_functions.m_function`).
>
> alpha : float
>     Significance level for the first stage test.
>
> beta : float, default: alpha / 50
>     Significance level for the second stage test.
>
> bootstrap_replications : int, optional
>     Number of bootstrap replications. Required if bootstrap_indices
>     is not specified.
>
> rng_seed : int, optional
>     Random number generator seed (for replication purposes). If not
>     specified, the system seed will be used as-is.
>
> bootstrap_indices : array_like, optional
>     Integer array of shape (bootstrap_replications, n) for the bootstrap
>     replications. If this is specified, bootstrap_replications and rng_seed
>     will be ignored. If this is not specified, bootstrap_replications is
>     required.
> 
> Returns
> -------
> float
>     The c-value for the EB2S test statistic.

### Submodule `andrews_kwon`

<a id="ineq_functions.andrews_kwon.rhat"></a>

#### `rhat`

```python
def rhat(
    w_data: np.ndarray,
    a_matrix: np.ndarray,
    theta: np.ndarray,
    j0_vector: np.ndarray,
    v_bar: float,
    iv_matrix: np.ndarray | None = None,
    grid0: int | str = "all",
    adjust: np.ndarray = np.array([0])) -> float
```

> Find the points of the rhat vector as in Andrews and Kwon (2023)
> 
> Parameters
> ----------
>
> w_data : array_like
>     n x j0 matrix of product portfolio.
>
> a_matrix : array_like
>     n x (j0 + 1) matrix of estimated revenue differentials.
>
> theta : array_like
>     d_theta x 1 parameter of interest.
>
> j0_vector : array_like
>     j0 x 2 matrix of ownership by two firms.
>
> v_bar : float
>     Tuning parameter as in Assumption 4.2
>
> iv_matrix : array_like, optional
>     n x d_IV matrix of instruments or None if no instruments are used.
>
> grid0 : {1, 2, 'all'}, default='all'
>     Grid direction to use for the estimation of the model.
>
> adjust : array_like, optional
>     Adjustment to the m_hat vector. Default is 0.
> 
> Returns
> -------
> float
>     Value of rhat for a given parameter theta.

<a id="ineq_functions.andrews_kwon.compute_an_vec"></a>

#### `compute_an_vec`

```python
def compute_an_vec(aux1_var: np.ndarray,
                   hat_r_inf: float,
                   w_data: np.ndarray,
                   a_matrix: np.ndarray,
                   theta_grid: np.ndarray,
                   j0_vector: np.ndarray,
                   v_bar: float,
                   iv_matrix,
                   grid0: int,
                   bootstrap_replications: int | None = None,
                   rng_seed: int | None = None,
                   bootstrap_indices: np.ndarray | None = None) -> np.ndarray
```

> Find the infimum An star as in Andrews and Kwon (2023)
> 
> Parameters
> ----------
>
> aux1_var : array_like
>     Vector of auxiliary variables with dimension n.
>
> hat_r_inf : float
>     Value of rhat at the parameter of interest.
>
> w_data : array_like
>     n x j0 matrix of product portfolio.
>
> a_matrix : array_like
>     n x (j0 + 1) matrix of estimated revenue differentials.
>
> theta_grid : array_like
>     Grid of parameter values to search. The value will be set at the index
>     of theta corresponding to `grid0`. Other dimensions will be set to 0.
>
> j0_vector : array_like
>     j0 x 2 matrix of ownership by two firms.
>
> v_bar : float
>     Tuning parameter as in Assumption 4.2
>
> iv_matrix : array_like, optional
>     n x d_IV matrix of instruments or None if no instruments are used.
>
> grid0 : {1, 2}
>     Grid direction to use for the estimation of the model.
>
> bootstrap_replications : int, optional
>     Number of bootstrap replications to use. If None, then bootstrap_indices must be
>     specified.
>
> rng_seed : int, optional
>     Seed for the random number generator.
>
> bootstrap_indices : array_like, optional
>     n x bootstrap_replications matrix of bootstrap indices. If None, then
>     bootstrap_replications must be specified.
> 
> Returns
> -------
> array_like
>     Vector of An star values with dimension bootstrap_replications.

<a id="ineq_functions.andrews_kwon.an_star"></a>

#### `an_star`

```python
def an_star(x_data: np.ndarray,
            std_b2: np.ndarray,
            std_b3: np.ndarray,
            kappa_n: float,
            hat_r_inf: float,
            bootstrap_replications: int | None = None,
            rng_seed: int | None = None,
            bootstrap_indices: np.ndarray | None = None) -> np.ndarray
```

> Computes the objective function that appears in inf problem defined in
> eq. (4.25) in Andrews and Kwon (2023).
> 
> Parameters
> ----------
>
> x_data : array_like
>     n x k matrix of the moment functions with n rows (output of
>     :func:`ineq_functions.m_function`).
>
> std_b2 : array_like
>     Vector of scaling factors as in eq. (4.21) of Andrews and Kwon (2023).
>     (second column of output of :func:`ineq_functions.std_b_vec`).
>
> std_b3 : array_like
>     Vector of scaling factors as in eq. (4.22) of Andrews and Kwon (2023).
>     (third column of output of :func:`ineq_functions.std_b_vec`).
>
> kappa_n : float
>     Tuning parameter as in (4.20) of Andrews and Kwon (2023).
>
> hat_r_inf : float
>     Estimator of the minimal relaxation of the moment ineq. as in (4.4) in
>     Andrews and Kwon (2023) (min of output of :func:`ineq_functions.r_hat`).
> 
> Returns
> -------
> array_like
>     Vector of An star values with dimension bootstrap_replications.

<a id="ineq_functions.andrews_kwon.cvalue_spur1"></a>

#### `cvalue_spur1`

```python
def cvalue_spur1(x_data: np.ndarray,
                 alpha: float,
                 an_vec: np.ndarray,
                 bootstrap_replications: int | None = None,
                 rng_seed: int | None = None,
                 bootstrap_indices: np.ndarray | None = None) -> float
```

> Calculate the c-value for the SPUR1 test statistic presented in
> Section 4 in Andrews and Kwon (2023).
> 
> Parameters
> ----------
>
> x_data : array_like
>     n x k matrix of the moment functions with n rows (output of
>     :func:`ineq_functions.m_function`).
>
> alpha : float
>     Significance level for the first stage test.
>
> an_vec : array_like
>     Vector as in eq. (4.25) in Andrews and Kwon (2023).
>
> bootstrap_replications : int, optional
>     Number of bootstrap replications. Required if bootstrap_indices
>     is not specified.
>
> rng_seed : int, optional
>     Random number generator seed (for replication purposes). If not
>     specified, the system seed will be used as-is.
>
> bootstrap_indices : array_like, optional
>     Integer array of shape (bootstrap_replications, n) for the bootstrap
>     replications. If this is specified, bootstrap_replications and rng_seed
>     will be ignored. If this is not specified, bootstrap_replications is
>     required.
> 
> Returns
> -------
> float
>     The c-value for the SPUR1 test statistic.

<a id="ineq_functions.andrews_kwon.std_b_vec"></a>

#### `std_b_vec`

```python
def std_b_vec(x_data: np.ndarray,
              bootstrap_replications: int | None = None,
              rng_seed: int | None = None,
              bootstrap_indices: np.ndarray | None = None) -> np.ndarray
```

> Compute scaling factors (std_1, std_2, std_3) as in (4.19), (4.21),
> and (4.22) as in Andrews and Kwon (2023).
> 
> Parameters
> ----------
>
> x_data : array_like
>     n x k matrix of the moment functions with n rows (output of
>     :func:`ineq_functions.m_function`).
>
> bootstrap_replications : int, optional
>     Number of bootstrap replications. Required if bootstrap_indices
>     is not specified.
>
> rng_seed : int, optional
>     Random number generator seed (for replication purposes). If not
>     specified, the system seed will be used as-is.
>
> bootstrap_indices : array_like, optional
>     Integer array of shape (bootstrap_replications, n) for the bootstrap
>     replications. If this is specified, bootstrap_replications and rng_seed
>     will be ignored. If this is not specified, bootstrap_replications is
>     required.
> 
> Returns
> -------
> array_like
>     Array of shape (3, k) with the scaling factors.

<a id="ineq_functions.andrews_kwon.tn_star"></a>

#### `tn_star`

```python
def tn_star(x_data: np.ndarray,
            std_b1: np.ndarray,
            kappa_n: float,
            bootstrap_replications: int | None = None,
            rng_seed: int | None = None,
            bootstrap_indices: np.ndarray | None = None) -> np.ndarray
```

> Compute the tn* statistic as in (4.24) as in Andrews and Kwon (2023).
> 
> Parameters
> ----------
>
> x_data : array_like
>     n x k matrix of the moment functions with n rows (output of
>     :func:`ineq_functions.m_function`).
>
> std_b1 : array_like
>     Array of shape (1, k, 1) with the first scaling factor.
>
> kappa_n : float
>     Tuning parameter as in (4.23).
>
> bootstrap_replications : int, optional
>     Number of bootstrap replications. Required if bootstrap_indices
>     is not specified.
>
> rng_seed : int, optional
>     Random number generator seed (for replication purposes). If not
>     specified, the system seed will be used as-is.
>
> bootstrap_indices : array_like, optional
>     Integer array of shape (bootstrap_replications, n) for the bootstrap
>     replications. If this is specified, bootstrap_replications and rng_seed
>     will be ignored. If this is not specified, bootstrap_replications is
>     required.
> 
> Returns
> -------
> array_like
>     Array of shape (bootstrap_replications, k) with the tn* statistics.

