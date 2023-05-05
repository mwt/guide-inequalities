# Table 1 in Section 8.1 in Canay, Illanes and Velez (2023)

# Inputs

# ../data/                               fake data
#  - A[['csv']]               n  x (1+J0)     matrix of revenue differential
#  - D[['csv']]               n  x (1+J)      matrix of all product portfolio
#  - J0[['csv']]              J0 x 2          matrix of ownership by two firms

# G_restriction[['m']]                        find test statistic and c. value
#  - m_function                          compute (26)-(27)
#  - m_hat                               compute a version of (38)
#  - cvalue_SN2S                         compute c. value as in (41)
#  - cvalue_EB2S                         compute c. value as in (48)

# output

# '_results/tables-tex/table_1[['time']]'       confidence intervals and comp[['time']]

# comment:
# the first column of A_matrix and D_matrix were used to index the markets,
# these first columns are useless in the rest of the code.

dir.create('_results')

# Import packages and functions
require(tidyverse)
# Quick hack to load functions (temporary)
lapply(list.files(path = "1_functions", full.names = T, pattern = "\\.R$"), source)

# Import data
datasets <- c("A", "D", "J0")
data_path <- file.path("..", "data")
dgp <- lapply(datasets, function(dataset) {
  read_csv(file.path(data_path, paste0(dataset, ".csv")), col_names = F) %>% as.matrix %>% unname
})

dgp[['num_market']] <- nrow(dgp$A)
dgp[['num_product']] <- nrow(dgp$D) - 1
dgp[['W_data']] <- dgp$D[, -1]

# Settings (cell arrays are used to loop over each of the four different specifications)
settings <- list(
  Vbar = c(500, 500, 1000, 1000),  # Vbar is defined in Assumption 4.2 and appears in eq. (26)-(27).
  test_stat = rep('CCK', 4),       # CCK as in eq. (38).
  cv = rep(c('SN2S', 'EB2S'), 2),  # Critical values as in eq. (41) and (47).
  alpha = rep(0.05, 4),            # significance level
  IV = rep(NA, 4)                  # no IVs
)

# Technical settings (lists are used to loop over the two parameters: theta1 and theta2)
sim <- list(
  grid_theta = list(seq(from = -40, to = 100, length.out = 1401), seq(from = -40, to = 100, length.out = 1401)),
  rng_seed = 20220826,
  sim_name = "table_1"
)

results <- list(
  CI_vec = list( matrix(NA, 4,2), matrix(NA, 4,2)),
  Tn_vec = lapply(sim$grid_theta, `+`, NA),
  comp_time = rep(NA, 4)
)

## 2 Computation
#  two steps:
#             i) compute test statistic and critical value
#            ii) conlist() confidence interevals

for (sim0 in 1:4){

    cat(c(paste0('case ', num2str(sim0))))

    tic

    for (theta_index in 1:2){
        # Temporary in-loop variables
(dim(0)[1])# save which points reject H0
(dim(0)[1])
(dim(0)[1])

        # Step 1: find test stat. Tn(theta) and c.value(theta) using G_restriction

        for (point0 in 1:(dim(sim[['grid_theta']])[1])){
            theta0 <- [0 0]'
            theta0(theta_index) <- sim[['grid_theta']][[theta_index]](point0, :)

            #test_H0: [T_n, c_value]
            test_H0 <- G_restriction(dgp[['W_data']], dgp[['A']], theta0, dgp[['J0']], settings[['Vbar']][[sim0]], settings[['IV']][[sim0]], theta_index, settings[['test_stat']][[sim0]], settings[['cv']][[sim0]], settings[['alpha']][[sim0]], sim[['num_boots']], sim[['rng_seed']])

            Test_vec(point0) <- test_H0(1)
            cv_vec(point0) <- test_H0(2)

            reject_H(point0) <- 1 * (test_H0(1) > test_H0(2))

        }

        results[['Tn_vec']][[theta_index]](:, sim0) <- Test_vec

        # Step 2: find confidence intervals using Tn(theta) and c[['value']](theta)

        # Confidence Interval for thetai

        CS_vec <- []

        for (point0 in 1:(dim(sim[['grid_theta']])[1])){
            thetai <- sim[['grid_theta']][[theta_index]](point0, :)'

            if (reject_H(point0) == 0){
                CS_vec <- [CS_vec; thetai']
            }

        }

        if (sum(dim(CS_vec)) == 0){# it may be the CI is empty
            results[['CI_vec']][[theta_index]](sim0, :) <- [NaN NaN]
            [!, point0] <- min(Test_vec)
            thetai <- sim[['grid_theta']][[theta_index]](point0, :)
            results[['CI_vec']][[theta_index]](sim0, 2) <- thetai# in this case, we report [nan, argmin test statistic]
        } else {
            results[['CI_vec']][[theta_index]](sim0, :) <- [min(CS_vec) max(CS_vec)]
        }

    }

    toc
    time <- toc
    results[['comp_time']](sim0, 1) <- time

}

## 3 Save results
save(fullfile('_results', strcat(sim[['sim_name']], '.mat')), 'dgp', 'settings', 'sim', 'results')

## 4 Print table
cd_name <- 'tables-tex'
dir.create('fullfile('_results', cd_name)')

f <- fopen(fullfile('_results', cd_name, strcat(sim[['sim_name']], '.tex')), 'w')# Open file for writing

fprintf(f, '%s\n', '\begin{tabular}{c c c c c}')
fprintf(f, '%s\n', '\hline \hline')
fprintf(f, '%s\n', '! & Crit. Value & $\theta_1$: Coca-Cola &$\theta_2$: Energy Brands & Comp. Time \\')
fprintf(f, '%s\n', '\hline')

for (row0 in 1:4){

    if (strcmp(settings[['cv']][[row0]], 'SN2S')){
        Vbar0 <- c(paste0('$Bar[[row0]]$ <- ', num2str(settings[['Vbar']][[row0]])))
        cvalue0 <- 'self-norm'
    } else if (strcmp(settings[['cv']][[row0]], 'EB2S')){
        Vbar0 <- "!"
        cvalue0 <- 'bootstrap'
    }

    fprintf(f, '%s%s%s%s%5[['CI_vec']]%s%5[['CI_vec']]%s%5[['CI_vec']]%s%5[['CI_vec']]%s%5[['CI_vec']]%s\n', Vbar0, ' & ', cvalue0, ' & [', results[['CI_vec']][[1]](row0, 1), ' , ', results[['CI_vec']][[1]](row0, 2), '] & [', results[['CI_vec']][[2]](row0, 1), ' , ', results[['CI_vec']][[2]](row0, 2), '] &', results[['comp_time']](row0, 1), '\\')

    if (row0 == 2){
        fprintf(f, '%s\n', '\hline')
    }

}

fprintf(f, '%s\n', '\hline \hline')
fprintf(f, '%s', '\}{tabular}')
