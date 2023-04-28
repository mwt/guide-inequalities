% Table 1 in Section 8.1 in Canay, Illanes and Velez (2023)

% Inputs

% Amatrix200701_fake.mat                 fake data
%  - A_matrix            n  x (1+J0)     matrix of revenue differential
%  - D_matrix            n  x (1+J)      matrix of all product portfolio
%  - J0_vec              J0 x 2          matrix of product ownership by two firms

% G_restriction.m                        find test statistic and c. value
%  - m_function                          compute (26)-(27)
%  - m_hat                               compute a version of (38)
%  - cvalue_SN2S                         compute c. value as in (41)
%  - cvalue_EB2S                         compute c. value as in (48)

% output

% 'table1.tex'                           confidence intervals and comp.time

% comment:
% the first column of A_matrix and D_matrix were used to index the markets,
% these first columns are useless in the rest of the code.

clc; clear all; close all;

addpath('1_functions');
load('Amatrix200701_fake.mat');
mkdir('_results');

%% 1 Setup

dgp = struct;
dgp.A_matrix = A_matrix;
dgp.D_matrix = D_matrix;

dgp.J0_vec = J0_vec; % (product, firm), where firm = 1 coca-cola, firm=2 energy-products
dgp.num_market = size(A_matrix, 1);
dgp.num_product = size(D_matrix, 1) - 1;

settings = struct;
settings.Vbar = {500, 1000}; % Vbar is defined in Assumption 4.2 and appears in eq. (26)-(27).
settings.IV = {'N'}; % No instrumental variables
settings.test_stat = {'CCK'}; % CCK as in eq. (38).
settings.cv = {'SN2S', 'EB2S'}; % Critical values as in eq. (41) and (47).
settings.alpha = 0.05; % significance level
settings.grid = {1, 2}; % compute moment functions for 1: theta1, 2: theta2

sim = struct;
sim.grid_Theta1 = linspace(-40, 100, 1401)';
sim.grid_Theta2 = linspace(-40, 100, 1401)';
sim.rng_seed = 20220826;
sim.num_boots = 1000;
sim.rng_seed_R = 20220818;
sim.num_boots_R = 250;
sim.sim_name = 'Table1_0423fake';

specs = cell(4, 1);

specs{1} = {settings.Vbar{1}, settings.IV{1}, ...
                                              settings.test_stat{1}, settings.cv{1}}; % Vbar=500, IV=N, test0=CCK, cvalue = SN2S,

specs{2} = {settings.Vbar{1}, settings.IV{1}, ...
                                              settings.test_stat{1}, settings.cv{2}}; % Vbar=500, IV=N, test0=CCK, cvalue = EB2S,

specs{3} = {settings.Vbar{2}, settings.IV{1}, ...
                                              settings.test_stat{1}, settings.cv{1}}; % Vbar=1000, IV=N, test0=CCK, cvalue= SN2S,

specs{4} = {settings.Vbar{2}, settings.IV{1}, ...
                                              settings.test_stat{1}, settings.cv{2}}; % Vbar=1000, IV=N, test0=CCK, cvalue= EB2S,

results = struct;
results.CI1_vec = zeros(4, 2); % specs x {LB, UB}
results.CI2_vec = zeros(4, 2);
results.comp_time = zeros(4, 1);

results.Tn_vec1 = zeros(size(sim.grid_Theta1, 1), 4);
results.Tn_vec2 = zeros(size(sim.grid_Theta2, 1), 4);

%% 2 Computation
%  two steps:
%             i) compute test statistic and critical value
%            ii) construct confidence interevals

W_data = D_matrix(:, 2:end);
alpha_input = settings.alpha;
num_boots = sim.num_boots;

for sim0 = 1:4

    disp(['case ' num2str(sim0)])

    Vbar = specs{sim0}{1};
    IV = specs{sim0}{2};
    test0 = specs{sim0}{3};
    cvalue = specs{sim0}{4};

    reject_H1 = zeros(size(sim.grid_Theta1, 1), 1); % save which points reject H0
    reject_H2 = zeros(size(sim.grid_Theta2, 1), 1); % save which points reject H0

    Test1_vec = zeros(size(sim.grid_Theta1, 1), 1);
    cv1_vec = zeros(size(sim.grid_Theta1, 1), 1);
    Test2_vec = zeros(size(sim.grid_Theta2, 1), 1);
    cv2_vec = zeros(size(sim.grid_Theta2, 1), 1);

    % Step 1: find test stat. Tn(theta) and c.value(theta) using G_restriction

    tic

    for point0 = 1:size(sim.grid_Theta1, 1)
        theta0 = [sim.grid_Theta1(point0, :) 0]';
        grid0 = settings.grid{1};

        %test_H0: [T_n, c_value]
        test_H0 = G_restriction(W_data, A_matrix, theta0, J0_vec, Vbar, IV, grid0, test0, cvalue, alpha_input, num_boots);

        Test1_vec(point0) = test_H0(1);
        cv1_vec(point0) = test_H0(2);

        reject_H1(point0) = 1 * (test_H0(1) > test_H0(2));
    end

    for point0 = 1:size(sim.grid_Theta2, 1)
        theta0 = [0 sim.grid_Theta2(point0, :)]';
        grid0 = settings.grid{2};

        %test_H0: [T_n, c_value]
        test_H0 = G_restriction(W_data, A_matrix, theta0, J0_vec, Vbar, IV, grid0, test0, cvalue, alpha_input, num_boots);

        Test2_vec(point0) = test_H0(1);
        cv2_vec(point0) = test_H0(2);

        reject_H2(point0) = 1 * (test_H0(1) > test_H0(2));
    end

    results.Tn_vec1(:, sim0) = Test1_vec;
    results.Tn_vec2(:, sim0) = Test2_vec;

    % Step 2: find confidence intervals using Tn(theta) and c.value(theta)

    % Confidence Interval for theta1

    CS_vec = [];

    for point0 = 1:size(sim.grid_Theta1, 1)
        theta1 = sim.grid_Theta1(point0, :)';

        if reject_H1(point0) == 0
            CS_vec = [CS_vec; theta1'];
        end

    end

    if sum(size(CS_vec)) == 0 % it may be the CI is empty
        results.CI1_vec(sim0, :) = [NaN NaN];
        [~, point0] = min(Test1_vec);
        theta1 = sim.grid_Theta1(point0, :);
        results.CI1_vec(sim0, 2) = theta1; % in this case, we report [nan, argmin test statistic]
    else
        results.CI1_vec(sim0, :) = [min(CS_vec) max(CS_vec)];
    end

    % Confidence Interval for theta2

    CS_vec = [];

    for point0 = 1:size(sim.grid_Theta2, 1)
        theta2 = sim.grid_Theta2(point0, :)';

        if reject_H2(point0) == 0
            CS_vec = [CS_vec; theta2'];
        end

    end

    if sum(size(CS_vec)) == 0 % it may be the CI is empty
        results.CI2_vec(sim0, :) = [NaN NaN];
        [~, point0] = min(Test2_vec);
        theta2 = sim.grid_Theta1(point0, :);
        results.CI1_vec(sim0, 2) = theta2; % in this case, we report [nan, argmin test statistic]
    else
        results.CI2_vec(sim0, :) = [min(CS_vec) max(CS_vec)];
    end

    toc
    time = toc;
    results.comp_time(sim0, 1) = time;
end

%% 3 Save results
save(fullfile('_results', strcat(sim.sim_name, '.mat')), 'dgp', 'settings', 'sim', 'results', 'specs');

%% 4 Print table
cd_name = 'tables-tex';
mkdir(fullfile('_results', cd_name));

f = fopen(fullfile('_results', cd_name, strcat(sim.sim_name, 'table1.tex')), 'w'); % Open file for writing

fprintf(f, '%s\n', '\begin{tabular}{c c c c c}')
fprintf(f, '%s\n', '\hline \hline')
fprintf(f, '%s\n', '~ & Crit. Value & $\theta_1$: Coca-Cola &$\theta_2$: Energy Brands & Comp. Time \\')
fprintf(f, '%s\n', '\hline')

for row0 = 1:size(specs, 1)

    Vbar = specs{row0}{1};
    cvalue = specs{row0}{4};

    if strcmp(cvalue, 'SN2S')
        Vbar = ['$\Bar{V}$=' num2str(Vbar)];
        cvalue0 = 'self-norm';
    elseif strcmp(cvalue, 'EB2S')
        Vbar = "~";
        cvalue0 = 'bootstrap';
    end

    fprintf(f, '%s%s%s%s%5.1f%s%5.1f%s%5.1f%s%5.1f%s%5.1f%s\n', ...
        Vbar, ' & ', cvalue0, ' & [', ...
        results.CI1_vec(row0, 1), ' , ', results.CI1_vec(row0, 2), '] & [', ...
        results.CI2_vec(row0, 1), ' , ', results.CI2_vec(row0, 2), '] &', ...
        results.comp_time(row0, 1), '\\');

    if row0 == 2
        fprintf(f, '%s\n', '\hline')
    end

end

fprintf(f, '%s\n', '\hline \hline')
fprintf(f, '%s', '\end{tabular}')
