function c_value = cvalue_EB(X_data,BB_input,alpha_input) 
%% (One step) Empirical Bootstrap critical value: See CCK (2020), pp. 20, Algorithm (Empirical Bootstrap)

%% Step 1: paramater setting

nn          = size(X_data,1); % number of observations
pp          = size(X_data,2); % number of moment inequalities
BB          = BB_input;          % number of draws in the algorithm
alpha       = alpha_input;       % nominal level for the critical value
rng_seed    = 20220826;          % Random number seed

%% Step 2: Algorithm of the Empirical Bootstrap
rng(rng_seed, 'twister');  
draws_vector = randi(nn,nn,BB);%round(rand(nn,BB)*nn+0.5); % draw with replacement

WEB_matrix  = zeros(BB,pp); % random sample of the empirical bootstrap test statistic

mu_hat      = mean(X_data,1);  % report a row, mean applied on each column
sigma_hat   = std(X_data,1,1); % standard devation using '1/N' instead of '1/(N-1)', and report a row

for kk=1:BB    
    XX_draw  = X_data(draws_vector(:,kk),:);    % draw from the empirical distribution        
    WEB_matrix(kk,:)   = sqrt(nn)*(1/nn)*(ones(nn,1)'*(XX_draw-ones(nn,1)*mu_hat))./sigma_hat;   
end

WEB_vector  = max(WEB_matrix,[],2);
 

%% Step 3: Critical value
qq_alpha = quantile(WEB_vector,1-alpha); % conditional (1-alpha)-quantile of WEB given random sample XX_matrix
c_value = qq_alpha;  % Output
end 