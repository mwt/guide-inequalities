% Moment inequality functions use an alternative specification for e_ij
% (see Assumption 3.2) and account for additional randomness on objective function defined in eq (49) and (50)

% there are four main steps
% step 1: select moments with non-zero variance using ml_indx & mu_indx
% step 2: load instruments in case we use them
% step 3: compute all the moment functions
% step 4: select the cumputed moments using ml_indx & mu_indx defined in step 1

% comment:
% - moment functions use a different specification for expected sunk cost:
%                   e_ij = g(theta,O_i) + V_ij,
%   see Assumption 3.2 where we used g(theta) = theta_s.
% - additional moment functions defined based on data and mu to account for
%   additional randomness on objective function defined in eq (49) and (50)
% - all the inputs are included in 'Amatrix200701_fake.mat'.
% - W_data = D_matrix(:,2:end);
% - J1 is the number of moments w/ no zero variance, see section 8.1.
% - n is the number of markets

function salida = m_functionv3(W_data, Dist_data, A_matrix, theta, J0_vec, Vbar, IV_matrix, grid0)

    % input:
    % - W_data          n  x J          matrix of all product portfolio
    % - Dist_data       n  x (1+J)      matrix of distance between product factories and cities
    % - A_matrix        n  x (1+J0)     matrix of revenue differential
    % - theta      d_theta x 1          parameter of interest
    % - J0_vec          J0 x 2          matrix of ownership by two firms
    % - Vbar                            tuning parameter as in Assumption 4.2
    % - IV_matrix     {n x k, empty}    instruments (empty if no instruments)
    % - grid0       {1, 2, 'all'}       searching direction

    % output:
    % - salida          n x J1          vector of the moment function.

    n = size(A_matrix, 1); % sample size
    J0 = size(J0_vec, 1); % number of products owned by coca-cola and energy-brands
    theta0 = theta(1:6); % as theta in table 4
    mu0 = theta(7:8); % as mu in table 4

    if size(W_data, 1) ~= n
        disp('wrong number of observations')
        disp(size(A_matrix, 1))
        disp(n)
        disp('wrong')
        keyboard
    end

    %% step 1: select moments with non-zero variance using ml_indx & mu_indx
    %          the procedure follows the discussion of section 8.1

    aux1 = sum(W_data);
    aux1 = aux1(J0_vec(:, 1));

    ml_indx = [];
    mu_indx = [];

    for jj0 = 1:J0

        if aux1(jj0) < n

            if strcmp(grid0, 'all') % include all the possible moments generated by products of coca-cola or energy-products
                ml_indx = [ml_indx; jj0];
            else
                jj1 = grid0; % include only the possible moments generated by coca-cola (grid0=1) or energy-products (grid0=2)

                if J0_vec(jj0, 2) == jj1
                    ml_indx = [ml_indx; jj0];
                end

            end

        end

        if aux1(jj0) > 0

            if strcmp(grid0, 'all') % include all the possible moments generated by products of coca-cola or energy-products
                mu_indx = [mu_indx; jj0];
            else
                jj1 = grid0; % include only the possible moments generated by coca-cola (grid0=1) or energy-products (grid0=2)

                if J0_vec(jj0, 2) == jj1
                    mu_indx = [mu_indx; jj0];
                end

            end

        end

    end

    %% step 2: compute all the moment functions

    for mm0 = 1:n
        %
        A_vec = A_matrix(mm0, 2:J0 + 1)'; % vector of estimated revenue differential in market mm0
        D_vec = W_data(mm0, :)';
        D_vec = D_vec(J0_vec(:, 1)); % vector of product portfolio of coca-cola and energy-products in market mm0
        Dist_vec = Dist_data(mm0, 2:end)';
        Dist_vec = Dist_vec(J0_vec(:, 1)); % vector of distance between product factory and city

        if isempty(IV_matrix)
            Z_vec = ones(J0, 1);
            ml_vec = MomentFunct_Lv2(A_vec, D_vec, Dist_vec, Z_vec, J0_vec, theta0, Vbar);
            mu_vec = MomentFunct_Uv2(A_vec, D_vec, Dist_vec, Z_vec, J0_vec, theta0, Vbar);

            X_data(mm0, :) = [ml_vec(ml_indx) mu_vec(mu_indx)];

        else
            Z_vec = ones(J0, 1);
            Z3_vec = 1 * (IV_matrix(:, 2) > median(IV_matrix(:, 2))); % employment rate
            Z5_vec = 1 * (IV_matrix(:, 3) > median(IV_matrix(:, 3))); % average income in market
            Z7_vec = 1 * (IV_matrix(:, 4) > median(IV_matrix(:, 4))); % median income in market

            ml_vec = MomentFunct_Lv2(A_vec, D_vec, Dist_vec, Z_vec, J0_vec, theta0, Vbar);
            ml_vec3 = MomentFunct_Lv2(A_vec, D_vec, Dist_vec, Z3_vec, J0_vec, theta0, Vbar);
            ml_vec5 = MomentFunct_Lv2(A_vec, D_vec, Dist_vec, Z5_vec, J0_vec, theta0, Vbar);
            ml_vec7 = MomentFunct_Lv2(A_vec, D_vec, Dist_vec, Z7_vec, J0_vec, theta0, Vbar);

            mu_vec = MomentFunct_Uv2(A_vec, D_vec, Dist_vec, Z_vec, J0_vec, theta0, Vbar);
            mu_vec3 = MomentFunct_Uv2(A_vec, D_vec, Dist_vec, Z3_vec, J0_vec, theta0, Vbar);
            mu_vec5 = MomentFunct_Uv2(A_vec, D_vec, Dist_vec, Z5_vec, J0_vec, theta0, Vbar);
            mu_vec7 = MomentFunct_Uv2(A_vec, D_vec, Dist_vec, Z7_vec, J0_vec, theta0, Vbar);

            X_data(mm0, :) = [ml_vec(ml_indx) mu_vec(mu_indx) ...
                                 ml_vec3(ml_indx) mu_vec3(mu_indx) ...
                                 ml_vec5(ml_indx) mu_vec5(mu_indx) ...
                                 ml_vec7(ml_indx) mu_vec7(mu_indx)];
        end

    end

    % additional moments to account for randomness of the objective function defined in eq (49) and (50)

    dist_vec = find_dist(Dist_data, J0_vec);

    dist_u1 = dist_vec(:, 1) - mu0(1);
    dist_l1 = -dist_vec(:, 1) + mu0(1);
    dist_u2 = dist_vec(:, 2) - mu0(2);
    dist_l2 = -dist_vec(:, 2) + mu0(2);

    %% step 3: select the computed moments using ml_indx & mu_indx defined in step 1

    salida = [X_data dist_u1 dist_l1 dist_u2 dist_l2];

end
