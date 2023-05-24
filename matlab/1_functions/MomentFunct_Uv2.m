% this function compute a moment function for an alternative specification for e_ij (see Assumption 3.2)
%
% comment:
% - the moment function utilized in this function is an alternative to eq (27).
%   It can be derived following the derivations presented in Section 4.1
%   and assuming e_ij = g(theta,O_i) + V_ij instead of  Assumption 3.2

function salida = MomentFunct_Uv2(A_vec, D_vec, Dist_vec, Z_vec, J0_vec, theta, Vbar)

    % input:
    % - A_vec       J0 x 1      vector of estimated revenue differential in a market
    % - D_vec       J0 x 1      vector of product portfolio in a market.
    % - Dist_vec    J0 x 1      vector of distance between product and market
    % - Z_vec       J0 x 1      vector of instruments in a market
    % - J0_vec      J0 x 2      vector of products of coca-cola and energy-product
    % - theta  d_theta x 1      parameter of interest
    % - Vbar                    tuning parameter as in Assumption 4.2

    % output:
    % - salida      1 x J0      vector of the moment function.

    J0 = size(J0_vec, 1); % number of products to evaluate one-product deviation
    S0 = size(unique(J0_vec(:, 2), 'stable'), 1); % number of firms

    theta = reshape(theta, [3 S0])';

    if S0 ~= size(theta, 1)
        disp('error on dimension of theta')
        keyboard
    else

        salida = zeros(1, J0);

        for jj0 = 1:J0

            jj2 = J0_vec(jj0, 2);
            theta_jj0 = theta(jj2, 1);
            theta_jj1 = theta(jj2, 2);
            theta_jj2 = theta(jj2, 3);

            g_theta = theta_jj0 + theta_jj1 * Dist_vec(jj0) + theta_jj2 * Dist_vec(jj0) ^ 2; % alternative specification as in Section 8.2.3

            salida(jj0) = ((A_vec(jj0) + g_theta) .* D_vec(jj0) - Vbar * (1 - D_vec(jj0))) .* Z_vec(jj0); % use g_theta instead of theta, see eq (26) and Section 8.2.3
        end

    end

end
