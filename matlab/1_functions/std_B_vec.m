% This function computes scaling factors (std_1, std_2, std_3) as in (4.19), (4.21), and (4.22) as in Andrews and Kwon (2023)
% - use eq (4.16) defined in Andrews and Kwon (2023)
%
% Comment:
% - Based on Section 4.4 in Andrews and Kwon (2023).

function salida = std_B_vec(X_data, num_boots, rng_seed)
    % input:
    % - X_data              n  x k              matrix of moments
    % - num_boots            1 x 1              number of bootstrap draws
    % - rng_seed                                seed for replication purpose

    % output:
    % - salida              1 x k x 3           matrix of scaling factors (std_1, std_2, std_3) as in (4.19), (4.21), and (4.22) in Andrews and Kwon (2023)

    %% 1 Setup

    iota = 1e-06; % as in eq (4.16) and Section 4.7.1 in Andrews and Kwon (2023)
    n = size(X_data, 1); % sample size
    k = size(X_data, 2); % number of moments

    rng(rng_seed, 'twister');

    draws_vector_B = randi(n, n, num_boots); % draws with replacement

    %% 2 Computation

    std1_B = zeros(1, k);
    std2_B = zeros(1, k);
    std3_B = zeros(1, k);

    mhatstar_vec = zeros(num_boots, k);

    for bb0 = 1:num_boots
        xi_draw0 = draws_vector_B(:, bb0);
        mhatstar_vec(bb0, :) = m_hat(X_data, xi_draw0, 1);
    end

    vec1 = sqrt(n) * (mhatstar_vec + max(-min(mhatstar_vec, 0)' )'); % to be consistent with the dimensions
    vec2 = sqrt(n) * mhatstar_vec;
    vec3 = sqrt(n) * (-min(mhatstar_vec, 0) - max(-min(mhatstar_vec, 0)' )'); % to be consistent with the dimensions

    std1_B(1, :) = max(std(vec1, 1), iota); % see eq (4.16) and (4.19) defined in Andrews and Kwon (2023)
    std2_B(1, :) = max(std(vec2, 1), iota); % see eq (4.16) and (4.21) defined in Andrews and Kwon (2023)
    std3_B(1, :) = max(std(vec3, 1), iota); % see eq (4.16) and (4.22) defined in Andrews and Kwon (2023)

    salida = zeros(1, k, 3);
    salida(:, :, 1) = std1_B; salida(:, :, 2) = std2_B; salida(:, :, 3) = std3_B;

end
