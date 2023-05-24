% Table 3 in Section 8.2.2 in Canay, Illanes and Velez (2023)

% Inputs

% ../data/                               fake data
%  - A.csv               n  x (1+J0)     matrix of revenue differential
%  - D.csv               n  x (1+J)      matrix of all product portfolio
%  - J0.csv              J0 x 2          matrix of ownership by two firms

% compute_An_vec                         find r_n^INF and compute A_n^* defined in Section 4 in Andrews and Kwon (2023)
%  - std_R_vec                           compute sd_1, sd_2, and sd_3 in eq. (4.19), (4.21), and (4.22) in Andrews and Kwon (2023)
%  - An_star                             computes the objective function that appears in inf problem defined in eq. (4.25) in Andrews and Kwon (2023)

% G_restriction.m                        find test statistic and c. value
%  - m_function                          compute (26)-(27)
%  - m_hat                               compute a version of (38)
%  - cvalue_SN2S                         compute c. value as in (41)
%  - cvalue_EB2S                         compute c. value as in (48)
%  - cvalue_SPUR1                        compute c. value as in Section C

% output

% '_results/tables-tex/table_3.tex'       confidence intervals and comp.time

% comment:
% the first column of A_matrix and D_matrix were used to index the markets,
% these first columns are useless in the rest of the code.

clc; clear all; close all;
addpath('1_functions');
mkdir('_results');

%% 1 Setup

% Import data
dgp = struct;
dgp.A_matrix = csvread(fullfile('..', 'data', 'A.csv'));
dgp.D_matrix = csvread(fullfile('..', 'data', 'D.csv'));
dgp.J0_vec = csvread(fullfile('..', 'data', 'J0.csv')); % (product, firm), where firm = 1 coca-cola, firm=2 energy-products

dgp.num_market = size(dgp.A_matrix, 1);
dgp.num_product = size(dgp.D_matrix, 1) - 1;
dgp.W_data = dgp.D_matrix(:, 2:end);

% Settings (cell arrays are used to loop over each of the four different specifications)
settings = struct;
settings.Vbar = {0, 0, 0, 0}; % Vbar is defined in Assumption 4.2 and appears in eq. (26)-(27).
settings.test_stat = {'CCK', 'RC-CCK', 'RC-CCK', 'RC-CCK'}; % CCK as in eq. (38) and RC-CCK is its recentered version as in Section 8.2.2.
settings.cv = {'SN2S', 'SN2S', 'EB2S', 'SPUR1'}; % Critical values as in eq. (41), (48), and Section C
settings.alpha = {0.05, 0.05, 0.05, 0.05}; % significance level
settings.IV = {[], [], [], []}; % no IVs

% Technical settings (cell arrays are used to loop over the two parameters: theta1 and theta2)
sim = struct;
sim.grid_Theta = {linspace(-40, 100, 1401)', linspace(-40, 100, 1401)'};
sim.rng_seed = 20220826;
sim.num_boots = 1000;
sim.num_robots = 4; % number of parallel workers
sim.sim_name = 'table_3';

results = struct;
results.CI_vec = {zeros(4, 2), zeros(4, 2)}; % specs x {LB, UB}
results.Tn_vec = {zeros(size(sim.grid_Theta{1}, 1), 4), zeros(size(sim.grid_Theta{2}, 1), 4)};
results.comp_time = zeros(4, 1);
results.hat_r_inf = zeros(4, 2); % As in eq. (A.16) in Appendix C

%% 2 Computation
%  three steps:
%             1) compute eq. (4.4) and (4.25) in Andrews and Kwon (2023)
%             2) compute test statistic and critical value
%             3) construct confidence interevals

% delete(gcp)
% parpool('local',sim.num_robots)

for sim0 = 1:4

    disp(['case ' num2str(sim0)])

    tic

    for theta_index = 1:2
        % Temporary in-loop variables (for each theta)
        reject_H = zeros(size(sim.grid_Theta{theta_index}, 1), 1); % save which points reject H0
        Test_vec = zeros(size(sim.grid_Theta{theta_index}, 1), 1);
        cv_vec = zeros(size(sim.grid_Theta{theta_index}, 1), 1);

        % Step 1: compute hat_r_inf and An_vec as in (4.4) and (4.25) in Andrews and Kwon (2023)

        %        An_vec = zeros(1,sim.num_boots);
        %        hat_r_inf = 0;

        if strcmp(settings.test_stat{sim0}, 'RC-CCK') % this step does not depend on the value of theta
            AK_results = compute_An_vec(dgp.D_matrix, dgp.A_matrix, dgp.J0_vec, settings.Vbar{sim0}, settings.IV{sim0}, theta_index, sim.grid_Theta{theta_index}, sim.num_boots, sim.num_robots, sim.rng_seed);
            An_vec = AK_results.An_vec; % input to compute c.value SPUR1, see Section 4.4 in Andrews and Kwon (2023)
            hat_r_inf = AK_results.hat_r_inf; % input to recenter the statistic, see Section 4.1 in Andrews and Kwon (2023)
            results.hat_r_inf(sim0, theta_index) = hat_r_inf;
        end

        % Step 2: find test stat. Tn(theta) and c.value(theta) using G_restriction

        parfor point0 = 1:size(sim.grid_Theta{theta_index}, 1)
            theta0 = [0 0]';
            theta0(theta_index) = sim.grid_Theta{theta_index}(point0, :);

            %test_H0: [T_n, c_value]
            if strcmp(settings.test_stat{sim0}, 'CCK')
                test_H0 = G_restriction(dgp.W_data, dgp.A_matrix, theta0, dgp.J0_vec, settings.Vbar{sim0}, settings.IV{sim0}, theta_index, settings.test_stat{sim0}, settings.cv{sim0}, settings.alpha{sim0}, sim.num_boots, sim.rng_seed);
            elseif strcmp(settings.test_stat{sim0}, 'RC-CCK')
                test_H0 = G_restriction(dgp.W_data, dgp.A_matrix, theta0, dgp.J0_vec, settings.Vbar{sim0}, settings.IV{sim0}, theta_index, settings.test_stat{sim0}, settings.cv{sim0}, settings.alpha{sim0}, sim.num_boots, sim.rng_seed, An_vec, hat_r_inf);
            end

            Test_vec(point0) = test_H0(1);
            cv_vec(point0) = test_H0(2);

            reject_H(point0) = 1 * (test_H0(1) > test_H0(2));
        end

        results.Tn_vec{theta_index}(:, sim0) = Test_vec;

        % Step 3: find confidence intervals using Tn(theta) and c.value(theta)

        % Confidence Interval for thetai

        CS_vec = [];

        for point0 = 1:size(sim.grid_Theta{theta_index}, 1)
            thetai = sim.grid_Theta{theta_index}(point0, :)';

            if reject_H(point0) == 0
                CS_vec = [CS_vec; thetai'];
            end

        end

        if sum(size(CS_vec)) == 0 % it may be the CI is empty
            results.CI_vec{theta_index}(sim0, :) = [NaN NaN];
            [~, point0] = min(Test_vec);
            thetai = sim.grid_Theta{theta_index}(point0, :);
            results.CI_vec{theta_index}(sim0, 2) = thetai; % in this case, we report [nan, argmin test statistic]
        else
            results.CI_vec{theta_index}(sim0, :) = [min(CS_vec) max(CS_vec)];
        end

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

f = fopen(fullfile('_results', cd_name, strcat(sim.sim_name, '.tex')), 'w'); % Open file for writing

fprintf(f, '%s\n', '\begin{tabular}{c c c c c}');
fprintf(f, '%s\n', '\hline \hline');
fprintf(f, '%s\n', 'Test Stat. & Crit. Value & $\theta_1$: Coca-Cola & $\theta_2$: Energy Brands & Comp. Time \\');
fprintf(f, '%s\n', '\hline');

for row0 = 1:4

    if row0 == 1
        test0 = 'CCK';
    else
        test0 = 'RC-CCK';
    end

    if strcmp(settings.cv{row0}, 'SN2S')
        cvalue0 = 'self-norm';
    elseif strcmp(settings.cv{row0}, 'EB2S')
        cvalue0 = 'bootstrap';
    elseif strcmp(settings.cv{row0}, 'SPUR1')
        cvalue0 = 'SPUR1';
    end

    if strcmp(num2str(results.CI_vec{1}(row0, 1)), 'NaN')

        if strcmp(num2str(results.CI_vec{2}(row0, 1)), 'NaN')
            fprintf(f, '%s%s%s%s%5.1f%s%5.1f%s%5.1f%s\n', test0, ' & ', cvalue0, ' & $', results.CI_vec{1}(row0, 2), '^{\dagger}$ & $', results.CI_vec{2}(row0, 2), '^{\dagger}$ &', results.comp_time(row0, 1), '\\');
        else
            fprintf(f, '%s%s%s%s%5.1f%s%5.1f%s%5.1f%s%5.1f%s\n', test0, ' & ', cvalue0, ' & $', results.CI_vec{1}(row0, 2), '^{\dagger}$ & [', results.CI_vec{2}(row0, 1), ' , ', results.CI_vec{2}(row0, 2), '] &', results.comp_time(row0, 1), '\\');
        end

    else
        fprintf(f, '%s%s%s%s%5.1f%s%5.1f%s%5.1f%s%5.1f%s%5.1f%s\n', test0, ' & ', cvalue0, ' & [', results.CI_vec{1}(row0, 1), ' , ', results.CI_vec{1}(row0, 2), '] & [', results.CI_vec{2}(row0, 1), ' , ', results.CI_vec{2}(row0, 2), '] &', results.comp_time(row0, 1), '\\');

    end

    if row0 == 1 || row0 == 3
        fprintf(f, '%s\n', '\hline');
    end

end

fprintf(f, '%s\n', '\hline \hline');
fprintf(f, '%s', '\end{tabular}');
