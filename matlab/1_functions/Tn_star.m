% this function computes the bootstrap variable Tn^* as in (4.18) in Andrews and Kwon (2023)

function salida = Tn_star(X_data, num_boots, rng_seed, std_B1, kappa_n)
    % inputs
    % - X_data               n x k              matrix of evaluated moment functions
    % - num_boots            1 x 1              number of bootstrap draws
    % - rng_seed                                seed for replication purpose
    % - std_B1               1 x k              scaling factor that appears in (4.19) in Andrews and Kwon (2023)
    % - kappa_n              1 x 1              tuning parameter as in (4.20) in Andrews and Kwon (2023)

    % output:
    % - salida               k x num_boots

    %% 1 Setup

    n = size(X_data, 1); % sample size
    k = size(X_data, 2); % number of moments

    rng(rng_seed, 'twister');

    draws_vector = randi(n, n, num_boots); % draws with replacement

    %% 2 Computation

    m_hat0 = m_hat(X_data, [], 0); % as in (4.2) in Andrews and Kwon (2023)
    r_hat_vec = -min(m_hat0, 0);
    r_hat = max(r_hat_vec); % as in (4.4) in Andrews and Kwon (2023)

    xi_n = ((std_B1 * kappa_n) .^ (-1)) .* (sqrt(n) * (m_hat0 + r_hat)); % as in (4.19) in Andrews and Kwon (2023)
    phi_n = 1 * (xi_n <= 1);
    phi_n = phi_n .^ (-1) - 1; % return Inf if xi_n >1 and 0 if xi_n <= 1

    Tnstar_vec = zeros(num_boots, k);

    for bb0 = 1:num_boots
        xi_draw0 = draws_vector(:, bb0);
        vstar = sqrt(n) * (m_hat(X_data, xi_draw0, 1) - m_hat0); % as in (4.17) in Andrews and Kwon (2023)
        Tnstar_vec(bb0, :) = vstar + phi_n; % as in (4.18) in Andrews and Kwon (2023)
    end

    salida = Tnstar_vec';
end
