function salida = find_dist(Dist_data, J0_vec)

    % input:
    % - Dist_data       n  x (1+J)      matrix of distance between product factories and cities
    % - J0_vec          J0 x 2          matrix of ownership by two firms

    % output:
    % - salida          n x 2           vector of distance between firm's factory to market

    B1_matrix = Dist_data(:, J0_vec(1:24, 1) + 1); % distances between coca-cola's product and markets
    B2_matrix = Dist_data(:, J0_vec(25:31, 1) + 1); % distances between energy-brand's product and markets

    salida = [max(B1_matrix, [], 2) max(B2_matrix, [], 2)]; % largest distance from firm's factory to the market

end
