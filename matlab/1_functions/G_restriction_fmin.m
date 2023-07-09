% This function find the restrictions in eq. (50) and (51)
%
% Comment:
% - this restriciton is an input for the fmincon function
% - the implicit reference for equations is Canay, Illanes, and Velez (2023)

function [c, ceq] = G_restriction_fmin(W_data, Dist_data, A_matrix, theta0, J0_vec, Vbar, IV_matrix, grid0, test0, cvalue, alpha_input, num_boots, rng_seed, plug_in)

    % input:
    % - W_data              n  x J              matrix of all product portfolio
    % - Dist_data           n  x (1+J)          matrix of distance between product factories and cities
    % - A_matrix            n  x (1+J0)         matrix of revenue differential
    % - theta0         d_theta x 1              parameter of interest
    % - J0_vec              J0 x 2              matrix of ownership by two firms (coca-cola, energy-brands)
    % - Vbar                                    tuning parameter as in Assumption 4.2
    % - IV_matrix        {n x k, empty}         instruments (empty if no instruments)
    % - grid0            {1, 2, 'all'}          searching direction
    % - test0               {'CCK'}             one possible type of tests
    % - cvalue          {'SN','SN2S','EB2S'}    three possible type of critical values
    % - alpha_input           1 x 1             level of tests
    % - num_boots             1 x 1             number of bootstrap draws
    % - rng_seed                                seed for replication purpose
    % - plug_in   {'Y','account_uncertanty'}    Y: default option, account_uncertanty: include additional moments, see Section 8.2.3

    % output:
    % - c                     1 x 2             test-cvalue, inequality constrain
    % - ceq                   []                equality constraint

    if strcmp(test0, 'CCK')

        if strcmp(plug_in, 'Y')
            X_data = m_functionv2(W_data, Dist_data, A_matrix, theta0, J0_vec, Vbar, IV_matrix, grid0); % an alternative specification for e_ij, see Section 8.2.3.
        elseif strcmp(plug_in, 'account_uncertanty')
            X_data = m_functionv3(W_data, Dist_data, A_matrix, theta0, J0_vec, Vbar, IV_matrix, grid0); % an alternative specification for e_ij and accouting for uncertainty, see Section 8.2.3
        end

        m_hat0 = m_hat(X_data, [], 0);
        n = size(X_data, 1);

        T_n = sqrt(n) * m_hat0;
        T_n = max(T_n); % as in eq (39)

        if strcmp(cvalue, 'SN')
            c_value = cvalue_SN(X_data, alpha_input); % as in eq (41)
        end

        if strcmp(cvalue, 'SN2S')
            beta_input = alpha_input / 50; % see Section 4.2.2 in Chernozhukov, Chetverikov, and Kato (2019)
            c_value = cvalue_SN2S(X_data, alpha_input, beta_input); % as in eq (42)
        end

        if strcmp(cvalue, 'EB2S')
            beta_input = alpha_input / 50; % see Section 4.2.2 in Chernozhukov, Chetverikov, and Kato (2019)
            c_value = cvalue_EB2S(X_data, num_boots, alpha_input, beta_input, rng_seed); % as in eq (49)
        end

        salida = T_n - c_value; % as the restrictions in (50) and (51)

    end

    c = salida;
    ceq = [];
end
