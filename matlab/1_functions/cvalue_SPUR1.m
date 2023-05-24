% this function computes the c. value SPUR1 presented in Section 4 in Andrews and Kwon (2023)

function c_value = cvalue_SPUR1(X_data, num_boots, alpha_input, An_vec, rng_seed)
    % inputs
    % - X_data               n x k              matrix of evaluated moment functions
    % - num_boots            1 x 1              number of bootstrap draws
    % - alpha_input                             significance level
    % - An_vec               1 x num_boots      vector as in eq. (4.25) in Andrews and Kwon (2023)
    % - rng_seed                                seed for replication purpose

    % output:
    % - salida               1 x 1              conditional (1-alpha)-quantile as in Section 4.4 in Andrews and Kwon (2023)

    %% 1 Setup

    n = size(X_data, 1); % sample size
    alpha = alpha_input; % significance level
    kappa_n = sqrt(log(n)); % tuning parameter as in Section 4.7.1 in Andrews and Kwon (2023)

    %% 2 Computation of Bootstrap statistic as in eq (4.15) in Andrews and Kwon(2023)

    std_B0 = std_B_vec(X_data, num_boots, rng_seed); % see in eq (4.16) and (4.19) defined in Andrews and Kwon (2023)
    std_B1 = std_B0(:, :, 1);
    Tn_vec = Tn_star(X_data, num_boots, rng_seed, std_B1, kappa_n); % as in (4.18) in Andrews and Kwon (2023)

    Snstar_vec = max(-min(Tn_vec + An_vec, 0)); % An_vec: 1 x num_boots, Tn_vec: k x num_boots,

    %% Step 3: Finde critical value

    qq_alpha = quantile(Snstar_vec, 1 - alpha); % conditional (1-alpha)-quantile of Snstar_vec given random sample X_data
    c_value = qq_alpha;

end
