require(Rfast)
require(readr)

# Quick hack to load functions (temporary)
invisible(lapply(
  list.files(
    path = file.path("ineq_functions","R"),
    full.names = T,
    pattern = "\\.R$"
  ),
  source
))

load_data <- function(dataset) {
  unname(as.matrix(read_csv(
    file.path(file.path("..", "data"), paste0(dataset, ".csv")),
    col_names = F,
    show_col_types = FALSE
  )))
}

# Variables
a_matrix <- load_data("A")
d_matrix <- load_data("D")
iv_matrix <- load_data("IV")
j0_vector <- load_data("J0")
w_data <- d_matrix[, -1]
v_bar <- 500
theta <- c(7, 12)
alpha <- 0.05
rng_seed <- 20220826
bootstrap_replications <- 1000

print("No IV, CCK, SN")
print(
  g_restriction(
    theta,
    w_data,
    a_matrix,
    j0_vector,
    v_bar,
    alpha,
    "all",
    iv_matrix,
    "CCK",
    "SN",
    bootstrap_replications = bootstrap_replications,
    rng_seed = rng_seed
  )
)
print("No IV, CCK, SN2S")
print(
  g_restriction(
    theta,
    w_data,
    a_matrix,
    j0_vector,
    v_bar,
    alpha,
    "all",
    iv_matrix,
    "CCK",
    "SN2S",
    bootstrap_replications = bootstrap_replications,
    rng_seed = rng_seed
  )
)
print("No IV, CCK, EB2S")
print(
  g_restriction(
    theta,
    w_data,
    a_matrix,
    j0_vector,
    v_bar,
    alpha,
    "all",
    iv_matrix,
    "CCK",
    "EB2S",
    bootstrap_replications = bootstrap_replications,
    rng_seed = rng_seed
  )
)