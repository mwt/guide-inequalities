%% compute critical value defined in eq (40) of section 5

function c_value = cvalue_SN(X_data, alpha_input)

    % input
    % - X_data           n x k    n: sample size, p: number of moment inequalities
    % - alpha_input      1 x 1    significance level

    % output
    % - c_value    1 x 1    critical value

    %% Step 1: parameter setting
    n = size(X_data, 1);
    k = size(X_data, 2);

    %% Step 2: calculations
    qq = norminv(1 - alpha_input / k);
    c_sn = qq / sqrt(1 - qq ^ 2 / n); % as in eq (40)

    c_value = c_sn;

end
