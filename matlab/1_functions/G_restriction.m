% This function find the test statistic and critical value as in Section 5
% - the test statistic is as in eq. (38)
% - the critical value is as in eq. (40), (41) and (48)
%
% Comment:
% - it also includes the re-centered test statistic as in section 8.2.2
%   and critical value SPUR1 as in Appendix Section C.


function salida = G_restriction(W_data,A_matrix,theta0,J0_vec,Vbar,IV,grid0,test0,cvalue,alpha_input,num_boots,An_vec,hat_r_inf)
% input: 
% - W_data              n  x J              matrix of all product portfolio
% - A_matrix            n  x (1+J0)         matrix of revenue differential
% - theta0         d_theta x 1              parameter of interest
% - J0_vec              J0 x 2              matrix of ownership by two firms
% - Vbar                                    tuning parameter as in Assumption 4.2
% - IV       {'N', 'demographics'}          instruments      
% - grid0       {1, 2, 'all'}               searching direction
% - test0       {'CCK','RC-CCK'}            two possible type of tests
% - cvalue   {'SN','SN2S','EB2S', 'SPUR1'}  four possible type of crit. values 
% - alpha_input           1 x 1             level of tests
% - num_boots             1 x 1             number of bootstrap draws
% - An_vec        num_boots x 1             vector as in eq. (xx) in Andrews and Kwon (2023)
% - hat_r_inf             1 x 1             lower value of the test as in eq (A.16)

% output: 
% - salida                1 x 2             (test, cvalue) 

if nargin == 11
 
    if strcmp(test0,'CCK')
        X_data   = m_function(W_data,A_matrix,theta0,J0_vec,Vbar,IV,grid0);
        m_hat0   = m_hat(X_data,[],0);
        nn       = size(X_data,1);

        T_n      = sqrt(nn)*m_hat0;
        T_n      = max(T_n);                                               % as in eq (38) 

        if strcmp(cvalue,'SN')
            c_value = cvalue_SN(X_data,alpha);                             % as in eq (40)
        end

        if strcmp(cvalue,'SN2S')
            beta_input = alpha_input/50;                                   % see Chernozhukov et al. (2019, Section 4.2.2)
            c_value    = cvalue_SN2S(X_data,alpha_input,beta_input);       % as in eq (41)
        end

        if strcmp(cvalue,'EB2S')
            beta_input = alpha_input/50;                                   % see Chernozhukov et al. (2019, Section 4.2.2)
            c_value    = cvalue_EB2S(X_data,num_boots,alpha_input,beta_input);  % as in eq (48)
        end

        salida = [T_n, c_value];

    end

elseif nargin == 13

    if strcmp(test0,'RC-CCK')

        X_data   = -m_function(W_data,A_matrix,theta0,J0_vec,Vbar,IV,grid0); % to use same notation as in Andrews and Kwon (2023)
        m_hat0   = m_hat(X_data,[],0);
        nn       = size(X_data,1);

        S_n      = sqrt(nn)*(m_hat0 + hat_r_inf);                          % re-centering step
        S_n      = max(-min(S_n,0));                                       % =max(-S_n) = T_n recentered, since by definition S_n <=0

        if strcmp(cvalue,'SPUR1')
            c_value  = cvalue_SPUR1(X_data,num_boots,alpha_input,An_vec);
        end

        if strcmp(cvalue,'SN2S')
            beta_input = alpha_input/50;
            X_data     = m_function(W_data,A_matrix,theta0,J0_vec,Vbar,IV,grid0);
            c_value    = cvalue_SN2S(X_data,alpha_input,beta_input);       % to compute the usual critical value w/o correcting for recentering step
        end

        if strcmp(cvalue,'EB2S')
            beta_input = alpha_input/50;
            X_data     = m_function(W_data,A_matrix,theta0,J0_vec,Vbar,IV,grid0);
            c_value    = cvalue_EB2S(X_data,num_boots,alpha_input,beta_input); % to compute the usual critical value w/o correcting for recentering step
        end      

        salida = [S_n, c_value];

    end
    
else
    disp('goal!')
    error('there are typos in the number of inputs! ');

end

end