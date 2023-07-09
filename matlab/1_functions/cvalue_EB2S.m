%% compute critical value defined in eq (49) of Section 5 in Canay, Illanes, and Velez (2023)

function c_value = cvalue_EB2S(X_data, BB_input, alpha_input, beta_input, rng_seed)

    % input
    % - X_data          n x k    matrix of evaluated moment functions
    % - BB_input        1 x 1    number of bootstraps
    % - alpha_input     1 x 1    significance level
    % - beta_input      1 x 1    tuning parameter to select moments
    % - rng_seed                 seed for replication purpose

    % output
    % - c_value         1 x 1    critical value
    %% Step 1: paramater setting

    n = size(X_data, 1); % sample size
    k = size(X_data, 2); % number of moments
    BB = BB_input;
    alpha = alpha_input;
    beta = beta_input;

    if beta < alpha / 2
        % disp('Two step EB-method is running')
    else
        disp('beta is not lower than alpha/2: fix it!')
        c_value = [];
        disp('alpha is...')
        disp(alpha)
        disp('and beta is...')
        disp(beta)
        keyboard
    end

    %% Step 2: Algorithm of the Empirical Bootstrap as in Section 5.2

    rng(rng_seed, 'twister'); % to replicate results
    draws_vector = randi(n, n, BB);

    WEB_matrix = zeros(BB, k); % matrix to save components of the empirical bootstrap test statistic

    mu_hat = mean(X_data, 1);
    sigma_hat = std(X_data, 1, 1);

    for kk = 1:BB
        XX_draw = X_data(draws_vector(:, kk), :); % draw from the empirical distribution
        WEB_matrix(kk, :) = sqrt(n) * (1 / n) * (ones(n, 1)' * (XX_draw - ones(n, 1) * mu_hat)) ./ sigma_hat; % as in eq (46)
    end

    WEB_vector = max(WEB_matrix, [], 2);

    qq_beta = quantile(WEB_vector, 1 - beta);
    c_value0 = qq_beta;

    test_vector = sqrt(n) * mu_hat ./ sigma_hat;
    JJ = sum(test_vector > (-2) * c_value0); % as in eq (47)

    if JJ > 0
        WEB_matrix2 = zeros(BB, JJ);
    else
        WEB_matrix2 = zeros(BB, 1);
    end

    jj0 = 0;

    for jj = 1:k
        test0 = test_vector(jj);

        if test0 > (-2) * c_value0
            jj0 = jj0 + 1;
            WEB_matrix2(:, jj0) = WEB_matrix(:, jj); % selection of moment inequalities
        end

    end

    WEB_vector2 = max(WEB_matrix2, [], 2); % as in eq (48)

    %% Step 3: Critical value

    qq_alpha = quantile(WEB_vector2, 1 - alpha + 2 * beta); % as in eq (49)
    c_value = qq_alpha;
end
