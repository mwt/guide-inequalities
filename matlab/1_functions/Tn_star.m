function salida = Tn_star(X_data,num_boots,rng_seed,std_R1,kappa_n)

    rng(rng_seed, 'twister'); 
    n = size(X_data,1); 
    k = size(X_data,2);
    
    draws_vector = randi(n,n,num_boots);%round(rand(n,num_boots)*n+0.5); % draw with replacement 
    
    m_hat0    = m_hat(X_data,[],0);
    r_hat_vec = -min(m_hat0,0);
    r_hat     = max(r_hat_vec);

    xi_n   = ( (std_R1*kappa_n).^(-1) ).* (sqrt(n)*(m_hat0 + r_hat )); % eq. 5.11
    phi_n  =  1*(xi_n<=1);
    phi_n  = phi_n.^(-1)-1; % eq. 4.11 

    Tnstar_vec = zeros(num_boots,k);

    for bb0 = 1:num_boots
        xi_draw0           = draws_vector(:,bb0);  
        vstar              = sqrt(n)*(m_hat(X_data,xi_draw0,1)-m_hat0);
        Tnstar_vec(bb0,:)  = vstar + phi_n;
    end
    
    salida = Tnstar_vec';
end