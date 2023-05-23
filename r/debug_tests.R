require(Rfast)
require(readr)

# Quick hack to load functions (temporary)
invisible(lapply(
  list.files(
    path = "1_functions",
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
A_matrix <- load_data('A')
D_matrix <- load_data('D')
IV_matrix <- load_data('IV')
J0_vec <- load_data('J0')
W_data <- D_matrix[,-1]
Vbar = 500
theta = c(7, 12)
alpha = 0.05
rng_seed = 20220826
num_boots = 1000

print("No IV, CCK, SN")
print(G_restriction(W_data, A_matrix, theta, J0_vec, Vbar, IV_matrix, 1, 'CCK', 'SN', alpha, num_boots, rng_seed))
print("No IV, CCK, SN2S")
print(G_restriction(W_data, A_matrix, theta, J0_vec, Vbar, IV_matrix, 1, 'CCK', 'SN2S', alpha, num_boots, rng_seed))
print("No IV, CCK, EB2S")
print(G_restriction(W_data, A_matrix, theta, J0_vec, Vbar, IV_matrix, 1, 'CCK', 'EB2S', alpha, num_boots, rng_seed))

print("M hat")
print(m_hat(m_function(W_data, A_matrix, theta, J0_vec, Vbar, IV_matrix, grid0 = 'all')))