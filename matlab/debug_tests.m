clc; clear all; close all;
addpath('1_functions');

% Variables
A_matrix = csvread(fullfile('..', 'data', 'A.csv'));
D_matrix = csvread(fullfile('..', 'data', 'D.csv'));
Dist_matrix = csvread(fullfile('..', 'data', 'Dist.csv')) / 1000;
IV_matrix = csvread(fullfile('..', 'data', 'IV.csv'));
J0_vec = csvread(fullfile('..', 'data', 'J0.csv')); % (product, firm), where firm = 1 coca-cola, firm=2 energy-products
W_data = D_matrix(:, 2:end);
Vbar = 0;
theta0 = [7 12]';
theta6 = [1 2 3 4 5 6]';
alpha = 0.05;
rng_seed = 20220826;
num_boots = 1000;

% Function Calls
% Table 2 function calls
disp("No IV, CCK, SN")
disp(G_restriction(W_data, A_matrix, theta0, J0_vec, Vbar, [], 1, 'CCK', 'SN', alpha, num_boots, rng_seed))
disp("No IV, CCK, SN2S")
disp(G_restriction(W_data, A_matrix, theta0, J0_vec, Vbar, [], 1, 'CCK', 'SN2S', alpha, num_boots, rng_seed))
disp("No IV, CCK, EB2S")
disp(G_restriction(W_data, A_matrix, theta0, J0_vec, Vbar, [], 1, 'CCK', 'EB2S', alpha, num_boots, rng_seed))
disp("No IV, RC-CCK, SPUR1")
disp(G_restriction(W_data, A_matrix, theta0, J0_vec, Vbar, [], 1, 'RC-CCK', 'SPUR1', alpha, num_boots, rng_seed, zeros(1, num_boots), 0))

disp("G restriction fmin")
disp(G_restriction_fmin(W_data, Dist_matrix, A_matrix, theta6, J0_vec, Vbar, [], 'all', 'CCK', 'SN', alpha, num_boots, rng_seed, 'Y'))

%disp("M hat")
%disp(m_hat(m_function(W_data, A_matrix, theta0, J0_vec, Vbar, IV_matrix, 'all'),[],0))
%X_data = m_function(W_data, A_matrix, theta0, J0_vec, Vbar, [], 1);
%n = size(X_data, 1); % sample size
%kappa_n = sqrt(log(n)); % tuning parameter as in Section 4.7.1 in Andrews and Kwon (2023)

%std_b0 = std_B_vec(X_data, num_boots, rng_seed);
%std_b1 = std_b0(:, :, 1);
%std_b2 = std_b0(:, :, 2);
%std_b3 = std_b0(:, :, 3);

%hat_r_inf = 0.22314601534719314;

%an_star0 = An_star(X_data, num_boots, rng_seed, std_b2, std_b3, kappa_n, hat_r_inf);
%disp("An_star")
%disp(an_star0)

%Tn_vec = Tn_star(X_data, num_boots, rng_seed, std_b1, kappa_n);
%disp(Tn_vec(:, 1))
%n = size(X_data, 1);
%k = size(X_data, 2);
%rng(rng_seed, 'twister');
%draws_vector_B = randi(n, n, num_boots);
%writematrix(draws_vector_B,"../data/random.csv");
%
%mhatstar_vec = zeros(num_boots, k);
%
%for bb0 = 1:num_boots
%    xi_draw0 = draws_vector_B(:, bb0);
%    mhatstar_vec(bb0, :) = m_hat(X_data, xi_draw0, 1);
%end
%
%disp(mhatstar_vec(:,1))
