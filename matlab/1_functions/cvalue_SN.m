%% compute critical value defined in eq (41) of Section 5 in Canay, Illanes, and Velez (2023)

function c_value = cvalue_SN(X_data, alpha_input)

    % input
    % - X_data           n x k    matrix of evaluated moment functions
    % - alpha_input      1 x 1    significance level

    % output
    % - c_value    1 x 1    critical value

    %% Step 1: parameter setting
    n = size(X_data, 1); % sample size
    k = size(X_data, 2); % number of moments

    %% Step 2: calculations
    qq = norminv(1 - alpha_input / k);
    c_sn = qq / sqrt(1 - qq ^ 2 / n); % as in eq (41)

    c_value = c_sn;

end
