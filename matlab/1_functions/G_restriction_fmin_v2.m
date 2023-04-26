function [c,ceq] = G_restriction_fmin_v2(W_data,Dist_data,A_matrix,theta0,J0_vec,Vbar,IV,grid0,test0,cvalue,alpha_input,num_boots,An_vec,hat_r_inf)
% T_n(theta) - cv(theta,1-alpha), % for CCK using SN2S or EB2s
% S_n(theta) - cv(theta,1-alpha), % for AK using SPUR1 or SB2S
% theta0 - vector d_theta x 1

if strcmp(test0,'CCK')
    X_data   = m_functionv3(W_data,Dist_data,A_matrix,theta0,J0_vec,Vbar,IV,grid0);
    m_hat0   = m_hat(X_data,[],0);
    nn       = size(X_data,1);
    
    T_n      = sqrt(nn)*m_hat0;
    T_n      = max(T_n);

    if strcmp(cvalue,'SN')
        c_value = cvalue_SN(X_data,alpha_input);
    end

    if strcmp(cvalue,'SN2S')
        beta_input = alpha_input/50;
        c_value = cvalue_SN2S(X_data,alpha_input,beta_input);
    end
    
    if strcmp(cvalue,'EB')
        c_value = cvalue_EB(X_data,num_boots,alpha_input);
    end

    if strcmp(cvalue,'EB2S')
        beta_input = alpha_input/50;
        c_value = cvalue_EB2S(X_data,num_boots,alpha_input,beta_input); 
    end
    
    salida = T_n - c_value;

end

if strcmp(test0,'RC-CCK')
    
    X_data   = -m_functionv3(W_data,Dist_data,A_matrix,theta0,J0_vec,Vbar,IV,grid0);
    m_hat0   = m_hat(X_data,[],0);
    nn       = size(X_data,1);
    
    S_n      = sqrt(nn)*(m_hat0 + hat_r_inf); %re-centering step is numerically equivalent if we use [x]_+ or [-x]_-
    S_n      = max(-min(S_n,0));
    
    if strcmp(cvalue,'SPUR1')
        c_value = cvalue_SPUR1(X_data,num_boots,alpha_input,An_vec);
    end
    
    if strcmp(cvalue,'SN2S')
        beta_input = alpha_input/50;
        X_data     = m_functionv3(W_data,Dist_data,A_matrix,theta0,J0_vec,Vbar,IV,grid0);
        c_value    = cvalue_SN2S(X_data,alpha_input,beta_input); %to compute the usual critical value w/o correcting for recentering step
    end
    
    if strcmp(cvalue,'EB2S')
        beta_input = alpha_input/50;
        X_data     = m_functionv3(W_data,Dist_data,A_matrix,theta0,J0_vec,Vbar,IV,grid0);
        c_value    = cvalue_EB2S(X_data,num_boots,alpha_input,beta_input); %to compute the usual critical value w/o correcting for recentering step
    end      

    salida = S_n - c_value;

end
c = salida;
ceq = [];
end