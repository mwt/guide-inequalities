function salida = MomentFunct_Lv2(A_vec,D_vec,Dist_vec,Z_vec,J0_vec,theta,Vbar)
% Comment: ownership in J0_vec are relabeled. 
% For instance, coca-cola = 1 and energy drink = 2 instead of coca-cola = 4 and energy drink = 8.

% Moment inequality function defined in eq (24)

% input: 
% - A_vec  : J0 x 1 dim. vector of estimated revenue differential in a given market, see Assumption 3
% - D_vec  : J0 x 1 dim. vector of entry decisions in a given market. 
% - Dist_vec  : J0 x 1 dim.
% - Z_vec  : J0 x 1 dim. vector with positive entries , see Assumption 4.
% - J0_vec : J0 x 2 dim. vector 
% - theta  : (3*S0) x 1 dim. vector

% output: 
% - salida : 1 x J0-dim. vector of the moment function.  

% J  = size(D_vec,1);
J0 = size(J0_vec,1); % number of products to evaluate one-product deviation
S0 = size(unique(J0_vec(:,2),'stable'),1); % number of firms

theta = reshape(theta,[3 S0])';

if S0 ~= size(theta,1)
    disp('error on dimension of theta')
    keyboard
else
    
salida = zeros(1,J0);

for jj0 = 1:J0

    jj2         = J0_vec(jj0,2);
    theta_jj0   = theta(jj2,1);
    theta_jj1   = theta(jj2,2);
    theta_jj2   = theta(jj2,3);
    
    g_theta     = theta_jj0 + theta_jj1*Dist_vec(jj0) + theta_jj2*Dist_vec(jj0)^2;
    
    salida(jj0) = ( (A_vec(jj0) - g_theta)*(1- D_vec(jj0)) - Vbar*D_vec(jj0) )*Z_vec(jj0);    
end

end

end