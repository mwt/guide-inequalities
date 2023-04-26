function salida = An_star(X_data,num_boots,rng_seed,std_R2,std_R3,kappa_n,hat_r_inf)

    rng(rng_seed, 'twister'); 
    n = size(X_data,1); 
    k = size(X_data,2);
    
    draws_vector = randi(n,n,num_boots); % round(rand(n,num_boots)*n+0.5); % draw with replacement   
    
    m_hat0    = m_hat(X_data,[],0);
    r_hat_vec = - min(m_hat0,0);
    r_hat     = max(r_hat_vec);
    
    % Part 0: hat_J_R(theta) eq. 5.18    
    hat_J_R = [];
    
    for jj0=1:k
        if r_hat_vec(jj0) >= r_hat - std_R3(jj0)*kappa_n/sqrt(n)
            hat_J_R = [hat_J_R; jj0]; % this set is never empty
        end        
    end    
    
    % Part 1: hat_b(theta) eq. 5.16    
    hat_b  = sqrt(n)*(-min(m_hat0,0)-hat_r_inf) - std_R3*kappa_n;
    
    % Part 2: Xi_A(theta) eq. 5.17    
    Xi_A   = ((std_R3*kappa_n).^(-1)).*(sqrt(n)*(-min(m_hat0,0)-hat_r_inf));    
    phi_n  =  1*(Xi_A<=1);
    phi_n  = phi_n.^(-1)-1;
      
    aux_vec1 = zeros(num_boots,1);
    
    for bb0 = 1:num_boots
          
        xi_draw0  = draws_vector(:,bb0);
        vstar     = sqrt(n)*(m_hat(X_data,xi_draw0,1)-m_hat0);
        v_Hi      = 1*(vstar>=0);
    
        % Part 3: hat_Hi_star(theta) eq. 5.15
        hat_Hi_star1 = (-1)*min(vstar + sqrt(n)*m_hat0-std_R2*kappa_n,0) - (-1)*min(sqrt(n)*m_hat0-std_R2*kappa_n,0); % vstar >= 0
        hat_Hi_star2 = (-1)*min(vstar + sqrt(n)*m_hat0+std_R2*kappa_n,0) - (-1)*min(sqrt(n)*m_hat0+std_R2*kappa_n,0); % vstar <  0      
        hat_Hi_star  = v_Hi.*hat_Hi_star1 + (1-v_Hi).*hat_Hi_star2;   
        
        aux_vec2     = zeros(size(hat_J_R,1),1);

        for jj1=1:size(hat_J_R,1)            
            hat_bnew = hat_b;
            jj2      = hat_J_R(jj1);
            hat_bnew(jj2) = phi_n(jj2); % 0 or Inf            
            aux_vec2(jj1)  = max(hat_Hi_star + hat_bnew);
        end
        
        aux_vec1(bb0) = min(aux_vec2);    
    end    
    
    salida = aux_vec1';
end