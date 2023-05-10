clc; clear all; close all;
addpath('1_functions');

% Variables
A_matrix = csvread(fullfile('..', 'data', 'A.csv'));
D_matrix = csvread(fullfile('..', 'data', 'D.csv'));
IV_matrix = csvread(fullfile('..', 'data', 'IV.csv'));
J0_vec = csvread(fullfile('..', 'data', 'J0.csv')); % (product, firm), where firm = 1 coca-cola, firm=2 energy-products
num_market = size(A_matrix, 1);
num_product = size(D_matrix, 1) - 1;
W_data = D_matrix(:, 2:end);
Vbar = 500;
theta0 = [7 12]';
alpha = 0.05;
rng_seed = 20220826;
num_boots = 1000;

% Function Calls
% Table 1 function calls
disp("No IV, CCK, SN")
disp(G_restriction(W_data, A_matrix, theta0, J0_vec, Vbar, [], 1, 'CCK', 'SN', alpha, num_boots, rng_seed))
disp("No IV, CCK, SN2S")
disp(G_restriction(W_data, A_matrix, theta0, J0_vec, Vbar, [], 1, 'CCK', 'SN2S', alpha, num_boots, rng_seed))
disp("No IV, CCK, EB2S")
disp(G_restriction(W_data, A_matrix, theta0, J0_vec, Vbar, [], 1, 'CCK', 'EB2S', alpha, num_boots, rng_seed))

disp("M hat")
disp(m_hat(m_function(W_data, A_matrix, theta0, J0_vec, Vbar, [], 'all'),[],0))