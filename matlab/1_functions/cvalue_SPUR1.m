function c_value = cvalue_SPUR1(X_data,num_boots,alpha_input,An_vec) 
% See Andrews and Kwon (2021) Section 5.1 etc TO ADD MORE DETAILS
 
%% Step 1: paramater setting

nn          = size(X_data,1); % number of observations
% kk          = size(X_data,2); % number of moment inequalities
% num_boots  : number of draws in the algorithm
alpha       = alpha_input;       % nominal level for the critical value
rng_seed    = 20220826;          % Random number seed
kappa_n     = sqrt(log(nn));     % tuning parameter
num_boots_R = 250;
rng_seed_R  = 20220818;%20221110; %20220818

%An_vec is a global vector 1 x num_boots that must share the same rng_seed (double check this)


%% Step 2: Algorithm of the Empirical Bootstrap

std_R0      = std_R_vec(X_data,num_boots_R,rng_seed_R);
std_R1      = std_R0(:,:,1);
Tn_vec      = Tn_star(X_data,num_boots,rng_seed,std_R1,kappa_n); % Tn_vec: kk x num_boots

Snstar_vec  = max(-min(Tn_vec + An_vec,0)); %  An_vec: 1 x num_boots
     

%% Step 3: Critical value

qq_alpha = quantile(Snstar_vec,1-alpha); % conditional (1-alpha)-quantile of Snstar_vec given random sample X_data
c_value  = qq_alpha;  % Output

end