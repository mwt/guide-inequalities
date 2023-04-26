function salida = std_R_vec(X_data,num_boots_R,rng_seed_R)

    rng(rng_seed_R, 'twister'); 
    n = size(X_data,1); 
    k = size(X_data,2);
    
    draws_vector_R = randi(n,n,num_boots_R);% round(rand(n,num_boots_R)*n+0.5); % draw with replacement  

    
    std1_R = zeros(1,k);
    std2_R = zeros(1,k);
    std3_R = zeros(1,k);
 
    mhatstar_vec = zeros(num_boots_R,k);

    for bb0 = 1:num_boots_R
        xi_draw0             = draws_vector_R(:,bb0);
        mhatstar_vec(bb0,:)  = m_hat(X_data,xi_draw0,1);
    end
     
    vec1 = sqrt(n)*(mhatstar_vec + max( -min(mhatstar_vec,0)' )'); %to be consistent with the dimensions   
    vec2 = sqrt(n)*mhatstar_vec;
    vec3 = sqrt(n)*( -min(mhatstar_vec,0) - max( -min(mhatstar_vec,0)' )'); %to be consistent with the dimensions

    std1_R(1,:) = max(std(vec1,1),1);
    std2_R(1,:) = max(std(vec2,1),1);
    std3_R(1,:) = max(std(vec3,1),1);
 
    salida = zeros(1,k,3);
    salida(:,:,1) = std1_R; salida(:,:,2) = std2_R; salida(:,:,3) = std3_R; 
     
end