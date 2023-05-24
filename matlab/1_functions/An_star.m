% This function computes the objective function that appears in inf problem defined in eq. (4.25) in Andrews and Kwon (2023)
%
% Comment:
% - Based on Section 4.4 in Andrews and Kwon (2023).

function salida = An_star(X_data, num_boots, rng_seed, std_B2, std_B3, kappa_n, hat_r_inf)
    % input:
    % - X_data              n  x k              matrix of moments
    % - num_boots            1 x 1              number of bootstrap draws
    % - rng_seed                                seed for replication purpose
    % - std_B2               1 x k              scaling factor that appears in (4.21) in Andrews and Kwon (2023)
    % - std_B3               1 x k              scaling factor that appears in (4.22) in Andrews and Kwon (2023)
    % - kappa_n              1 x 1              tuning parameter as in (4.20) in Andrews and Kwon (2023)
    % - hat_r_inf            1 x 1              estimator of the minimal relaxation of the moment ineq. as in (4.4) in Andrews and Kwon (2023)

    % output:
    % - salida               1 x num_boots      see objective function defined in eq. (4.25) in Andrews and Kwon (2023)

    %% 1 Setup

    n = size(X_data, 1);
    k = size(X_data, 2);

    rng(rng_seed, 'twister');

    draws_vector = randi(n, n, num_boots); % draws with replacement

    %% 2 Computation

    % Step 1: compute hat_J_R(theta) as in (4.24) in Andrews and Kwon (2023)

    m_hat0 = m_hat(X_data, [], 0);
    r_hat_vec =- min(m_hat0, 0);
    r_hat = max(r_hat_vec); % as in (4.4) in Andrews and Kwon (2023)

    hat_J_R = [];

    for jj0 = 1:k

        if r_hat_vec(jj0) >= r_hat - std_B3(jj0) * kappa_n / sqrt(n)
            hat_J_R = [hat_J_R; jj0]; % notice this set is never empty
        end

    end

    % Step 2: compute the objective function that appears in inf problem defined in eq. (4.25) in Andrews and Kwon (2023)

    hat_b = sqrt(n) * (-min(m_hat0, 0) - hat_r_inf) - std_B3 * kappa_n; % as in (4.22) in Andrews and Kwon (2023)
    Xi_A = ((std_B3 * kappa_n) .^ (-1)) .* (sqrt(n) * (-min(m_hat0, 0) - hat_r_inf)); % as in (4.23) in Andrews and Kwon (2023)

    phi_n = 1 * (Xi_A <= 1);
    phi_n = phi_n .^ (-1) - 1; % return Inf if Xi_A >1 and 0 if Xi_A <= 1

    aux_vec1 = zeros(num_boots, 1);

    for bb0 = 1:num_boots

        xi_draw0 = draws_vector(:, bb0);
        vstar = sqrt(n) * (m_hat(X_data, xi_draw0, 1) - m_hat0); % as in (4.17) in Andrews and Kwon (2023)

        hat_Hi_star1 = (-1) * min(vstar + sqrt(n) * m_hat0 - std_B2 * kappa_n, 0) ...
            - (-1) * min(sqrt(n) * m_hat0 - std_B2 * kappa_n, 0); % vstar >= 0
        hat_Hi_star2 = (-1) * min(vstar + sqrt(n) * m_hat0 + std_B2 * kappa_n, 0) ...
            - (-1) * min(sqrt(n) * m_hat0 + std_B2 * kappa_n, 0); % vstar <  0

        hat_Hi_star = (1 * (vstar >= 0)) .* hat_Hi_star1 ...
            + (1 * (vstar < 0)) .* hat_Hi_star2; % as in (4.21) in Andrews and Kwon (2023)

        aux_vec2 = zeros(size(hat_J_R, 1), 1);

        for jj1 = 1:size(hat_J_R, 1)
            hat_bnew = hat_b;
            jj2 = hat_J_R(jj1);
            hat_bnew(jj2) = phi_n(jj2); % 0 (Xi_A <= 1) or Inf (Xi_A > 1)
            aux_vec2(jj1) = max(hat_Hi_star + hat_bnew);
        end

        aux_vec1(bb0) = min(aux_vec2);
    end

    salida = aux_vec1';
end
