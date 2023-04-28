%% compute critical value defined in eq (41) of section 5

function c_value = cvalue_SN2S(X_data, alpha_input, beta_input)

    % input
    % - X_data          n x k    n: sample size, p: number of moment inequalities
    % - alpha_input     1 x 1    significance level
    % - beta_input      1 x 1    tuning parameter to select moments

    % output
    % - c_value         1 x 1    critical value

    %% Step 0: parameter setting

    n = size(X_data, 1);
    k = size(X_data, 2);
    alpha = alpha_input;
    beta = beta_input;

    if beta < alpha / 2
        %     disp('Two step SN-method is running');
    else
        disp('beta is not lower than alpha/2: fix it!')
        c_value = [];
        disp('alpha is...')
        disp(alpha)
        disp('and beta is...')
        disp(beta)
        keyboard
    end

    %% Step 1: define set J_SN as almost binding

    c_sn0 = cvalue_SN(X_data, beta); % as in eq (40)
    contar = 0; % number of moments inequalities that are almost binding

    for jj = 1:k
        mu_hat = mean(X_data(:, jj));
        sigma_hat = std(X_data(:, jj), 1);

        test0 = sqrt(n) * mu_hat / sigma_hat; % Studentized statistic for each moment inequality

        if test0 >- 2 * c_sn0 % moments inequalities that are almost binding
            contar = contar +1;
        end

    end

    k_hat = contar; % as in eq (39)

    %% Step 2: calculate critical value using a subset of moment inequalities

    if k_hat > 0
        qq1 = norminv(1 - (alpha - 2 * beta) / k_hat);
        c_sn1 = qq1 / sqrt(1 - qq1 ^ 2 / n); % as in eq (41)
    else
        c_sn1 = 0;
    end

    c_value = c_sn1;
end
