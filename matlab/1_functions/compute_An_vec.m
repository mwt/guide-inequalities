function salida = compute_An_vec(D_matrix,A_matrix,J0_vec,Vbar,IV,grid0,grid_search,num_boots,num_robots)

% inputs:
% TBD

W_data = D_matrix(:,2:end);

settings               = struct;
settings.test_stat     = 'SPUR1';
settings.n             = size(W_data,1);
settings.k             = size(-m_function(W_data,A_matrix,[0 0]',J0_vec,Vbar,IV,grid0),2);
settings.tau_n         = sqrt(log(settings.n));
settings.kappa_n       = sqrt(log(settings.n));
settings.vbar          = 0; % it is consistent w/ m_function

sim             = struct; 
sim.grid_search = grid_search;
sim.num_points  = size(grid_search,1);
sim.rng_seed    = 20220826; 
sim.num_boots   = num_boots;
sim.rng_seed_R  = 20220818; 
sim.num_boots_R =  250;
sim.num_robots  =  num_robots;   % No. of parallel workers 
sim.sim_name    = 'version_0907';

results                = struct;
results.hat_r_inf      = [];
results.hat_Theta      = [];  
results.An_vec         = [];

%% Step 1: Compute r_n^INF, Sn_theta and Theta_hat
% delete(gcp)
% parpool('local',sim.num_robots)

rhat_vec = zeros(sim.num_points,1);

disp('1. computing hat_r_inf...');
% tic
 parfor (point0 =1:sim.num_points,sim.num_robots)
      
    theta0   = sim.grid_search(point0,:)';
    if grid0 == 1
        theta0 = [theta0 0]';
    elseif grid0 == 2
        theta0 = [0 theta0]';
    end
    
    X_data   = -m_function(W_data,A_matrix,theta0,J0_vec,Vbar,IV,grid0);
    m_hat0   = m_hat(X_data,[],0);
    rhat_vec(point0) = max(-min(m_hat0,0)); %by default ignores the NaN (defied by std = 0)

 end
 
results.hat_r_inf  = min(rhat_vec);
toc    

in_hat_Theta = zeros(sim.num_points,1);

disp('2. computing Theta_hat...');
% tic
parfor (point0 =1:sim.num_points,sim.num_robots)
      
    theta0   = sim.grid_search(point0,:)';
    if grid0 == 1
        theta0 = [theta0 0]';
    elseif grid0 == 2
        theta0 = [0 theta0]';
    end
    
    X_data   = -m_function(W_data,A_matrix,theta0,J0_vec,Vbar,IV,grid0); 
    m_hat0   = m_hat(X_data,[],0);

    % Nov 7:
    aux1_var = max(-min(m_hat0+results.hat_r_inf,0));
    
    if aux1_var <= settings.tau_n/sqrt(settings.n)
%     if max(-m_hat0) <= settings.tau_n/sqrt(settings.n) + results.hat_r_inf
        in_hat_Theta(point0) = 1;
    end

 end
 toc
 
 
 for point0 = 1:sim.num_points
     
    theta0   = sim.grid_search(point0,:)';
    if grid0 == 1
        theta0 = [theta0 0]';
    elseif grid0 == 2
        theta0 = [0 theta0]';
    end
     if in_hat_Theta(point0) == 1
         results.hat_Theta = [results.hat_Theta; point0 theta0']; %row and point in the grid
     end
 end

 %% Step 2: compute critical values using bootstrap

% Computing scaling factors (bootstrap standard deviations)
 
std_R    = zeros(sim.num_points,settings.k,3); 

disp('3. computing bootstrap std for scaling purpuse...');
% tic
parfor (point0 =1:sim.num_points,sim.num_robots)
     
     theta0   = sim.grid_search(point0,:)';
     if grid0 == 1
         theta0 = [theta0 0]';
     elseif grid0 == 2
         theta0 = [0 theta0]';
     end
     X_data   = -m_function(W_data,A_matrix,theta0,J0_vec,Vbar,IV,grid0);
     std_R0   = std_R_vec(X_data,sim.num_boots_R,sim.rng_seed_R);

     std_R(point0,:,:) = std_R0;
     
end
toc
   

% Computing A_n^*: num_boots x 1
An_vec = zeros(size(results.hat_Theta,1),sim.num_boots);

disp('4. computing An_star...');
% tic
 parfor (point0 = 1:size(results.hat_Theta,1),sim.num_robots)
     
     theta0   = results.hat_Theta(point0,2:3)';
     point1   = results.hat_Theta(point0,1)';
     X_data   = -m_function(W_data,A_matrix,theta0,J0_vec,Vbar,IV,grid0);
     std_R2   = std_R(point1,:,2);
     std_R3   = std_R(point1,:,3);
     
     An_vec(point0,:)  =  An_star(X_data,sim.num_boots,sim.rng_seed,std_R2,std_R3,settings.kappa_n,results.hat_r_inf);  % An_star: 1 x num_boots
 end
toc

results.An_vec = min(An_vec);

salida = results;

end
