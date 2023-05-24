% This function finds r_n^INF and compute A_n^* defined in Andrews and Kwon (2023)
% - A_n^* as in (4.25) in Andrews and Kwon (2023) to compute c.value SPUR1
% - r_n^INF as in (4.4) in Andrews and Kwon (2023) to recenter the statistic
%
% Comment:
% - Based on Section 4 in Andrews and Kwon (2023).

function salida = compute_An_vec(D_matrix, A_matrix, J0_vec, Vbar, IV, grid0, grid_search, num_boots, num_robots, rng_seed)

    % input:
    % - D_data              n  x (1+J)          matrix of all product portfolio
    % - A_matrix            n  x (1+J0)         matrix of revenue differential
    % - J0_vec              J0 x 2              matrix of ownership by two firms
    % - Vbar                                    tuning parameter as in Assumption 4.2
    % - IV            {'N' , 'demographics'}    instruments
    % - grid0               {1 , 2}             searching direction
    % - grid_search                             searching direction
    % - num_boots            1 x 1              number of bootstrap draws
    % - num_robots                              number of parallel workers
    % - rng_seed                                seed for replication purpose

    % output:
    % - salida.hat_r_inf     1 x 1              estimator of the minimal relaxation of the moment ineq. as in (4.4) in Andrews and Kwon (2023)
    % - salida.hat_Theta     1 x d_hat_Theta    estimator of the MR-identified as in (4.20) in Andrews and Kwon (2023)
    % - salida.An_vec        1 x num_boots      a bootstrap lower bound as in (4.25) in Andrews and Kwon (2023)

    %% 1 Setup

    W_data = D_matrix(:, 2:end);
    aux0 = -m_function(W_data, A_matrix, [0 0]', J0_vec, Vbar, IV, grid0); % in order to compute the number of moments

    settings = struct; % decision about tunning parameters, see Section 4.7.1 in Andrews and Kwon (2023)
    settings.test_stat = 'SPUR1';
    settings.n = size(W_data, 1); % sample size
    settings.k = size(aux0, 2); % number of moments
    settings.tau_n = sqrt(log(settings.n)); % as in Section 4.4 and 4.7.1 in Andrews and Kwon (2023)
    settings.kappa_n = sqrt(log(settings.n)); % as in Section 4.4 and 4.7.1 in Andrews and Kwon (2023)
    settings.vbar = 0; % as in Section 8.2.2 in Canay, Illanes, and Velez (2023)
    settings.iota = 1;

    sim = struct;
    sim.grid_search = grid_search;
    sim.num_points = size(grid_search, 1);
    sim.rng_seed = rng_seed;
    sim.num_boots = num_boots; % as Section 4.7.1 in 4.7.1 in Andrews and Kwon (2023)
    sim.num_robots = num_robots; % number of parallel workers

    results = struct;
    results.hat_r_inf = [];
    results.hat_Theta = [];
    results.An_vec = [];

    %% 2 Computations
    % there are four steps to find r_n^INF and compute A_n^* defined in Andrews and Kwon (2023)
    % 1) find r_n^INF as in (4.4) in Andrews and Kwon (2023)
    % 2) compute Theta_hat as in (4.20) in Andrews and Kwon (2023)
    % 3) compute scaling factors (bootstrap standard deviations) as in (4.16), (4.19), (4.21), and (4.22) in Andrews and Kwon (2023)
    % 4) compute A_n^* as in (4.25) in Andrews and Kwon (2023)

    % Step 1: find r_n^INF as in (4.4) in Andrews and Kwon (2023)

    rhat_vec = zeros(sim.num_points, 1);

    parfor (point0 = 1:sim.num_points, sim.num_robots)

        theta0 = sim.grid_search(point0, :)';

        if grid0 == 1
            theta0 = [theta0 0]';
        elseif grid0 == 2
            theta0 = [0 theta0]';
        end

        X_data = -m_function(W_data, A_matrix, theta0, J0_vec, Vbar, IV, grid0); % note we use -m_function
        m_hat0 = m_hat(X_data, [], 0);
        rhat_vec(point0) = max(-min(m_hat0, 0)); % by default ignores the NaN (defined by std = 0)

    end

    results.hat_r_inf = min(rhat_vec);

    % Step 2: compute Theta_hat as in (4.20) in Andrews and Kwon (2023)

    in_hat_Theta = zeros(sim.num_points, 1);

    parfor (point0 = 1:sim.num_points, sim.num_robots) % to know which values of theta's verify (4.20) in Andrews and Kwon (2023)

        theta0 = sim.grid_search(point0, :)';

        if grid0 == 1
            theta0 = [theta0 0]';
        elseif grid0 == 2
            theta0 = [0 theta0]';
        end

        X_data = -m_function(W_data, A_matrix, theta0, J0_vec, Vbar, IV, grid0); % note we use -m_function
        m_hat0 = m_hat(X_data, [], 0);

        aux1_var = max(-min(m_hat0 + results.hat_r_inf, 0));

        if aux1_var <= settings.tau_n / sqrt(settings.n) % see eq. (4.20) in Andrews and Kwon (2023)
            in_hat_Theta(point0) = 1;
        end

    end

    for point0 = 1:sim.num_points % to save the thetas in Theta_hat as in (4.20) in Andrews and Kwon (2023)

        theta0 = sim.grid_search(point0, :)';

        if grid0 == 1
            theta0 = [theta0 0]';
        elseif grid0 == 2
            theta0 = [0 theta0]';
        end

        if in_hat_Theta(point0) == 1
            results.hat_Theta = [results.hat_Theta; point0 theta0']; % save (row,theta')
        end

    end

    % Step 3: compute scaling factors (bootstrap standard deviations) as in (4.16), (4.19), (4.21), and (4.22) in Andrews and Kwon (2023)

    std_B = zeros(sim.num_points, settings.k, 3); % (std_1, std_2, std_3) as in (4.19), (4.21), and (4.22) in Andrews and Kwon (2023)

    parfor (point0 = 1:sim.num_points, sim.num_robots)

        theta0 = sim.grid_search(point0, :)';

        if grid0 == 1
            theta0 = [theta0 0]';
        elseif grid0 == 2
            theta0 = [0 theta0]';
        end

        X_data = -m_function(W_data, A_matrix, theta0, J0_vec, Vbar, IV, grid0);
        std_B0 = std_B_vec(X_data, sim.num_boots, sim.rng_seed); % see eq (4.16) in Andrews and Kwon (2023) and (4.19), (4.21), and (4.22).

        std_B(point0, :, :) = std_B0;

    end

    % Step 4: compute A_n^* as in (4.25) in Andrews and Kwon (2023)

    An_vec = zeros(size(results.hat_Theta, 1), sim.num_boots);

    parfor (point0 = 1:size(results.hat_Theta, 1), sim.num_robots)

        theta0 = results.hat_Theta(point0, 2:3)';
        point1 = results.hat_Theta(point0, 1)';
        X_data = -m_function(W_data, A_matrix, theta0, J0_vec, Vbar, IV, grid0);
        std_B2 = std_B(point1, :, 2); % see eq (4.16) and (4.21) defined in Andrews and Kwon (2023)
        std_B3 = std_B(point1, :, 3); % see eq (4.16) and (4.22) defined in Andrews and Kwon (2023)

        An_vec(point0, :) = An_star(X_data, sim.num_boots, sim.rng_seed, std_B2, std_B3, settings.kappa_n, results.hat_r_inf); % An_star: 1 x num_boots
    end

    toc

    results.An_vec = min(An_vec); % 1 x num_boots

    salida = results;

end
