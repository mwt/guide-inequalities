% Table 4 in Section 8.2.3 in Canay, Illanes and Velez (2023)

% Inputs

% ../data/                               fake data
%  - A.csv               n  x (1+J0)     matrix of revenue differential
%  - D.csv               n  x (1+J)      matrix of all product portfolio
%  - Dist.csv            n  x (1+J)      matrix of distance from factory's product to market
%  - J0.csv              J0 x 2          matrix of ownership by two firms

% G_restriction.m                        find test statistic and c. value
%  - m_function                          compute (27)-(28)
%  - m_hat                               compute a version of (39)
%  - cvalue_SN                           compute c. value as in (41)

% output

% '_results/tables-tex/table_4.tex'       confidence intervals and comp.time

% comment:
% the first column of A_matrix and D_matrix were used to index the markets,
% these first columns are useless in the rest of the code.

clc; clear all; close all;
addpath('1_functions');
mkdir('_results');

%% 1 Setup
dgp = struct;
dgp.A_matrix = csvread(fullfile('..', 'data', 'A.csv'));
dgp.D_matrix = csvread(fullfile('..', 'data', 'D.csv'));
dgp.Dist_matrix = csvread(fullfile('..', 'data', 'Dist.csv')) / 1000;
dgp.J0_vec = csvread(fullfile('..', 'data', 'J0.csv')); % (product, firm), where firm = 1 coca-cola, firm=2 energy-products

dgp.num_market = size(dgp.A_matrix, 1);
dgp.num_product = size(dgp.D_matrix, 1) - 1;
dgp.W_data = dgp.D_matrix(:, 2:end);

% Settings (cell arrays are used to loop over each of the four different specifications)
settings = struct;
settings.Vbar = {500, 500, 1000, 1000}; % Vbar is defined in Assumption 4.2 and appears in eq. (27)-(28).
settings.test_stat = {'CCK', 'CCK', 'CCK', 'CCK'}; % CCK as in eq. (39).
settings.cv = {'SN', 'SN', 'SN', 'SN'}; % Critical values as in eq. (42) and (48).
settings.alpha = {0.05, 0.05, 0.05, 0.05}; % significance level
settings.IV = {[], [], [], []}; % no IVs

settings.lb = {[-40 -20 0 -40 -20 0 0 0], [-40 -20 -10 -40 -20 -10 0 0], [-40 -20 0 -40 -20 0 0 0], [-40 -20 -10 -40 -20 -10 0 0]};
settings.ub = {[100 50 0 100 50 0 3 2], [100 50 10 100 50 10 3 2], [100 50 0 100 50 0 3 2], [100 50 10 100 50 10 3 2]};
rng(1, 'twister');
settings.x0 = {[0.5 0 0 0.5 0 0 1 0.65], 40 * [(rand(1) - 0.5) (rand(1) - 0.5) 0 (rand(1) - 0.5) (rand(1) - 0.5) 0 1 0.65], [0.5 0 0 0.5 0 0 1 0.65], 40 * [(rand(1) - 0.5) (rand(1) - 0.5) 0 (rand(1) - 0.5) (rand(1) - 0.5) 0 1 0.65]};

% Technical settings (to define restrictions for fmincon function)
sim = struct;
sim.rng_seed = 20220826;
sim.num_boots = 1000;
sim.sim_name = 'table_4';
rng(sim.rng_seed, 'twister');

results = struct;
% Conf. Inter.    theta_1,1    theta_1,2    theta_1,3    theta_2,1    theta_2,2    theta_2,3    theta_1(mu)  theta_2(mu)  theta_1(mu_hat) theta_2(mu_hat)
results.CI_vec = {zeros(4, 2), zeros(4, 2), zeros(4, 2), zeros(4, 2), zeros(4, 2), zeros(4, 2), zeros(4, 2), zeros(4, 2), zeros(4, 2), zeros(4, 2)};
results.comp_time = zeros(4, 1);

%% 2 Computation
%  three steps:
%          1) define objective functions and constraints options as in (50)-(51)
%          2) find confidence intervals for coordinate of theta as in Section 6
%          3) find confidence intervals for function of theta following Section 6

for sim0 = 1:4

    disp(['case ' num2str(sim0)])

    % Step 1: define objective functions and constraints options as in (50)-(51)
    tic

    options = optimoptions('fmincon', 'Algorithm', 'sqp');

    % inequality restriction for fmincon as in (50) and (51)

    plug_in = 'Y'; % default option for the alternative specifications and same objective funciton as in eq (50) and (51)
    nonlcon_v1 = @(theta0) G_restriction_fmin(dgp.W_data, dgp.Dist_matrix, dgp.A_matrix, theta0', dgp.J0_vec, settings.Vbar{sim0}, settings.IV{sim0}, 'all', settings.test_stat{sim0}, settings.cv{sim0}, settings.alpha{sim0}, sim.num_boots, sim.rng_seed, plug_in); %  theta0' in G_restriction_fmin must be a column vector

    % Step 2: find confidence intervals for coordinates of theta as in Section 6
    A = [];
    b = [];
    Aeq = [];
    beq = [];

    for theta_index = 1:6
        l_fobj = @(theta0) theta0(theta_index);
        u_fobj = @(theta0) -theta0(theta_index);

        [x1, lb, flag_lb] = fmincon(l_fobj, settings.x0{sim0}(1:6), A, b, Aeq, beq, settings.lb{sim0}(1:6), settings.ub{sim0}(1:6), nonlcon_v1, options);
        [x2, ub, flag_ub] = fmincon(u_fobj, settings.x0{sim0}(1:6), A, b, Aeq, beq, settings.lb{sim0}(1:6), settings.ub{sim0}(1:6), nonlcon_v1, options);

        results.CI_vec{theta_index}(sim0, :) = [lb -ub];
    end

    % Step 3: find confidence intervals for a function of theta following Section 6

    % objective functions accounting for uncertainty

    plug_in = 'account_uncertanty';
    nonlcon_v2 = @(theta0) G_restriction_fmin(dgp.W_data, dgp.Dist_matrix, dgp.A_matrix, theta0', dgp.J0_vec, settings.Vbar{sim0}, settings.IV{sim0}, 'all', settings.test_stat{sim0}, settings.cv{sim0}, settings.alpha{sim0}, sim.num_boots, sim.rng_seed, plug_in); %  theta0' in G_restriction_fmin must be a column vector

    for theta_index = 1:2
        l_obj = @(theta0) theta0(1 + (theta_index - 1) * 3) +theta0(2 + (theta_index - 1) * 3) * theta0(6 + theta_index) +theta0(3 + (theta_index - 1) * 3) * theta0(6 + theta_index) ^ 2;
        u_obj = @(theta0) -theta0(1 + (theta_index - 1) * 3) -theta0(2 + (theta_index - 1) * 3) * theta0(6 + theta_index) -theta0(3 + (theta_index - 1) * 3) * theta0(6 + theta_index) ^ 2;

        [x1, lb, flag_lb] = fmincon(l_obj, settings.x0{sim0}, A, b, Aeq, beq, settings.lb{sim0}, settings.ub{sim0}, nonlcon_v2, options);
        [x2, ub, flag_ub] = fmincon(u_obj, settings.x0{sim0}, A, b, Aeq, beq, settings.lb{sim0}, settings.ub{sim0}, nonlcon_v2, options);

        results.CI_vec{6 + theta_index}(sim0, :) = [lb -ub]; % Confidence Interval for theta_i(mu)
    end

    % objective functions without accounting for uncertainty (plug-in)

    dist_mean = mean(find_dist(dgp.Dist_matrix, dgp.J0_vec));

    for theta_index = 1:2
        l_obj = @(theta0) theta0(1 + (theta_index - 1) * 3) +theta0(2 + (theta_index - 1) * 3) * dist_mean(theta_index) +theta0(3 + (theta_index - 1) * 3) * dist_mean(theta_index) ^ 2;
        u_obj = @(theta0) -theta0(1 + (theta_index - 1) * 3) -theta0(2 + (theta_index - 1) * 3) * dist_mean(theta_index) -theta0(3 + (theta_index - 1) * 3) * dist_mean(theta_index) ^ 2;

        [x1, lb, flag_lb] = fmincon(l_obj, settings.x0{sim0}(1:6), A, b, Aeq, beq, settings.lb{sim0}(1:6), settings.ub{sim0}(1:6), nonlcon_v1, options);
        [x2, ub, flag_ub] = fmincon(u_obj, settings.x0{sim0}(1:6), A, b, Aeq, beq, settings.lb{sim0}(1:6), settings.ub{sim0}(1:6), nonlcon_v1, options);

        results.CI_vec{8 + theta_index}(sim0, :) = [lb -ub]; % Confidence Interval for theta_i(mu_hat)
    end

    toc
    time = toc;
    results.comp_time(sim0, 1) = time;
end

%% 3 Save results
save(fullfile('_results', strcat(sim.sim_name, '.mat')), 'dgp', 'settings', 'sim', 'results');

%% 4 Print table
cd_name = 'tables-tex';
mkdir(fullfile('_results', cd_name));

num_spec = size(results.CI_vec{1}, 1);

table0 = [];

for theta_index = 1:8
    row = reshape(results.CI_vec{theta_index}(:, :)', [2 * num_spec 1])';
    table0 = [table0; row];
end

time_vec = results.comp_time(:, 1)';

f = fopen(fullfile('_results', cd_name, strcat(sim.sim_name, '.tex')), 'w'); % Open file for writing

fprintf(f, '%s\n', '\begin{tabular}{c c c c c c}');
fprintf(f, '%s\n', '\hline \hline');
fprintf(f, '%s\n', '& & \multicolumn{2}{c}{ $\Bar{V}=500$  } &  \multicolumn{2}{c}{ $\Bar{V}=1000$  }\\ \hline ');
fprintf(f, '%s\n', '& parameter & linear & quadratic & linear & quadratic \\ \hline');

row9 = time_vec(:, 1:4);

for row0 = 1:9

    if row0 == 2
        firm = 'Coca';
    elseif row0 == 3
        firm = 'Cola';
    elseif row0 == 5
        firm = 'Energy';
    elseif row0 == 6
        firm = 'Brands';
    else
        firm = '~';
    end

    if row0 < 9

        if row0 < 4
            theta0 = ['$\theta_{1,' num2str(row0) '}$'];
            row1 = row0;
        elseif row0 == 4
            theta0 = '$\theta_1(\mu)$';
            row1 = 7;
        elseif row0 > 4 && row0 < 8
            theta0 = ['$\theta_{2,' num2str(row0 - 4) '}$'];
            row1 = row0 - 1;
        elseif row0 == 8
            theta0 = '$\theta_2(\mu)$';
            row1 = row0;
        end

        fprintf(f, '%s%s%s%s %5.1f%s%5.1f%s %5.1f%s%5.1f%s %5.1f%s%5.1f%s %5.1f%s%5.1f%s\n', ...
            firm, ' & ', theta0, ' & [', ...
            table0(row1, 1), ' , ', table0(row1, 2), '] & [', ...
            table0(row1, 3), ' , ', table0(row1, 4), '] & [', ...
            table0(row1, 5), ' , ', table0(row1, 6), '] & [', ...
            table0(row1, 7), ' , ', table0(row1, 8), '] \\');
    else
        theta0 = '~';
        firm = 'Comp. time';
        fprintf(f, '%s%s%s%s%5.1f%s%5.1f%s%5.1f%s%5.1f%s\n', ...
            firm, ' & ', theta0, ' & ', ...
            row9(1), ' & ', row9(2), ' & ', ...
            row9(3), ' & ', row9(4), '\\');
    end

    if row0 == 4 || row0 == 8
        fprintf(f, '%s\n', '\hline');
    end

end

fprintf(f, '%s\n', '\hline \hline');
fprintf(f, '%s', '\end{tabular}');
