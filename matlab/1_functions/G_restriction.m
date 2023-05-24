% This function find the test statistic and critical value as in Section 5
% - the test statistic is as in eq. (38)
% - the critical value is as in eq. (40), (41) and (48)
%
% Comment:
% - it also includes the re-centered test statistic as in section 8.2.2
%   and critical value SPUR1 as in Appendix Section C.
% - the implicit reference for equations is Canay, Illanes, and Velez (2023)

function salida = G_restriction(W_data, A_matrix, theta0, J0_vec, Vbar, IV_matrix, grid0, test0, cvalue, alpha_input, num_boots, rng_seed, An_vec, hat_r_inf)
    % input:
    % - W_data              n  x J              matrix of all product portfolio
    % - A_matrix            n  x (1+J0)         matrix of revenue differential
    % - theta0         d_theta x 1              parameter of interest
    % - J0_vec              J0 x 2              matrix of ownership by two firms (coca-cola, energy-brands)
    % - Vbar                                    tuning parameter as in Assumption 4.2
    % - IV_matrix   {n x k, empty}              instruments (empty if no instruments)
    % - grid0       {1, 2, 'all'}               searching direction
    % - test0       {'CCK','RC-CCK'}            two possible type of tests
    % - cvalue   {'SN','SN2S','EB2S', 'SPUR1'}  four possible type of critical values
    % - alpha_input           1 x 1             level of tests
    % - num_boots             1 x 1             number of bootstrap draws
    % - rng_seed                                seed for replication purpose
    %
    % - An_vec        num_boots x 1             vector as in eq. (4.25) in Andrews and Kwon (2023), only useful to compute c.value SPUR1
    % - hat_r_inf             1 x 1             lower value of the test as in eq. (4.4)  in Andrews and Kwon (2023), only useful to recenter the test (RC-CCK)

    % output:
    % - salida                1 x 2             (test, cvalue)

    if nargin == 12

        if strcmp(test0, 'CCK')
            X_data = m_function(W_data, A_matrix, theta0, J0_vec, Vbar, IV_matrix, grid0);
            m_hat0 = m_hat(X_data, [], 0);
            n = size(X_data, 1);

            T_n = sqrt(n) * m_hat0;
            T_n = max(T_n); % as in eq (38)

            if strcmp(cvalue, 'SN')
                c_value = cvalue_SN(X_data, alpha_input); % as in eq (40)
            end

            if strcmp(cvalue, 'SN2S')
                beta_input = alpha_input / 50; % see Section 4.2.2 in Chernozhukov et al. (2019)
                c_value = cvalue_SN2S(X_data, alpha_input, beta_input); % as in eq (41)
            end

            if strcmp(cvalue, 'EB2S')
                beta_input = alpha_input / 50; % see Section 4.2.2 in Chernozhukov et al. (2019)
                c_value = cvalue_EB2S(X_data, num_boots, alpha_input, beta_input, rng_seed); % as in eq (48)
            end

            salida = [T_n, c_value];

        end

    elseif nargin == 14

        if strcmp(test0, 'RC-CCK')

            X_data = m_function(W_data, A_matrix, theta0, J0_vec, Vbar, IV_matrix, grid0);
            m_hat0 = m_hat(-X_data, [], 0); % as in eq. (4.2) in Andrews and Kwon (2023)
            n = size(X_data, 1);

            S_n = sqrt(n) * (m_hat0 + hat_r_inf); % re-centering step as in (4.5) in  Andrews and Kwon (2023)
            S_n = max(-min(S_n, 0)); % = max(-S_n) = T_n recentered, since by definition S_n <=0

            if strcmp(cvalue, 'SPUR1')
                c_value = cvalue_SPUR1(-X_data, num_boots, alpha_input, An_vec, rng_seed); % compute the critical value presented in Section 4.4 in Andrews and Kwon (2023)
            end

            if strcmp(cvalue, 'SN2S')
                beta_input = alpha_input / 50;
                c_value = cvalue_SN2S(X_data, alpha_input, beta_input); % as in eq (41)
            end

            if strcmp(cvalue, 'EB2S')
                beta_input = alpha_input / 50;
                c_value = cvalue_EB2S(X_data, num_boots, alpha_input, beta_input, rng_seed); % as in eq (48)
            end

            salida = [S_n, c_value];

        end

    else
        disp('goal!')
        error('there are typos in the number of inputs! ');

    end

end
