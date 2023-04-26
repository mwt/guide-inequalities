function salida = m_functionv2(W_data,Dist_data,A_matrix,theta0,J0_vec,Vbar,IV,grid0)

% input: 
% - W_data    : n x d_W dim.
% - Dist_data : n x d_W dim.
% - A_matrix  : n x J0 dim.
% - theta     : d_theta x 1 dim.
% - J0_vec    : J0 x 2 dim. vector
% - Vbar      : tuning parameter
% - IV        : 'N' or 'Y', include or not instrumental variable

n  = size(A_matrix,1);
J0 = size(J0_vec,1);

load('Amatrix200701_fake.mat', 'IV_matrix') % TEMPORAL 

if size(W_data,1) ~= n
    disp('wrong number of observations')
    disp(size(A_matrix,1))
    disp(n)
    disp('wrong')
    keyboard
end

aux1 = sum(W_data);
aux1 = aux1(J0_vec(:,1));

ml_indx = [];
mu_indx = [];

for jj0=1:J0
    if aux1(jj0)<n
        if strcmp(grid0,'all')
            ml_indx = [ml_indx; jj0];
        else
            jj1 = grid0; % jj1-entry in vector theta
            if J0_vec(jj0,2) == jj1
                ml_indx = [ml_indx; jj0];
            end
        end
    end
    if aux1(jj0)>0
        if strcmp(grid0,'all')
            mu_indx = [mu_indx; jj0];
        else
            jj1 = grid0; % jj1-entry in vector theta
            if J0_vec(jj0,2) == jj1
                mu_indx = [mu_indx; jj0];
            end
        end
    end
end


for mm0=1:n
%                
   A_vec = A_matrix(mm0,2:J0+1)';
   D_vec = W_data(mm0,:)';
   D_vec = D_vec(J0_vec(:,1));
   Dist_vec = Dist_data(mm0,2:end)'; %NEW to check later
   Dist_vec = Dist_vec(J0_vec(:,1));
%   
   if strcmp(IV,'Y')
       Z_vec = ones(J0,1);
       Z1_vec = 1*(A_vec >=0);
       Z2_vec = 1*(A_vec <=0);
       
       ml_vec  = MomentFunct_Lv2(A_vec,D_vec,Dist_vec,Z_vec,J0_vec,theta0,Vbar);
       ml_vec1 = MomentFunct_Lv2(A_vec,D_vec,Dist_vec,Z1_vec,J0_vec,theta0,Vbar);
       ml_vec2 = MomentFunct_Lv2(A_vec,D_vec,Dist_vec,Z2_vec,J0_vec,theta0,Vbar);
       
       mu_vec  = MomentFunct_Uv2(A_vec,D_vec,Dist_vec,Z_vec,J0_vec,theta0,Vbar);
       mu_vec1 = MomentFunct_Uv2(A_vec,D_vec,Dist_vec,Z1_vec,J0_vec,theta0,Vbar);
       mu_vec2 = MomentFunct_Uv2(A_vec,D_vec,Dist_vec,Z2_vec,J0_vec,theta0,Vbar); 
       
       X2_data(mm0,:) = [ml_vec(ml_indx)  mu_vec(mu_indx)...
                         ml_vec1(ml_indx) mu_vec1(mu_indx)...
                         ml_vec2(ml_indx) mu_vec2(mu_indx)];      
   elseif strcmp(IV,'Y1')
       Z_vec = ones(J0,1);
       Z1_vec = 1*(A_vec >=0);
       Z2_vec = 1*(A_vec <=0);
       
       m1_vec  = MomentFunct_Lv2(A_vec,D_vec,Dist_vec,Z_vec,J0_vec,theta0,Vbar);
       ml_vec1 = MomentFunct_Lv2(A_vec,D_vec,Dist_vec,Z1_vec,J0_vec,theta0,Vbar);
       
       mu_vec  = MomentFunct_Uv2(A_vec,D_vec,Dist_vec,Z_vec,J0_vec,theta0,Vbar);
       mu_vec1 = MomentFunct_Uv2(A_vec,D_vec,Dist_vec,Z1_vec,J0_vec,theta0,Vbar); 
       
       X2_data(mm0,:) = [m1_vec(ml_indx)  mu_vec(mu_indx)...
                         ml_vec1(ml_indx) mu_vec1(mu_indx)];    
   elseif strcmp(IV,'Y2')
       Z_vec = ones(J0,1);
       Z1_vec = 1*(A_vec >=0);
       Z2_vec = 1*(A_vec <=0);
       
       ml_vec  = MomentFunct_Lv2(A_vec,D_vec,Dist_vec,Z_vec,J0_vec,theta0,Vbar);
       ml_vec2 = MomentFunct_Lv2(A_vec,D_vec,Dist_vec,Z2_vec,J0_vec,theta0,Vbar);
       
       mu_vec  = MomentFunct_Uv2(A_vec,D_vec,Dist_vec,Z_vec,J0_vec,theta0,Vbar);
       mu_vec2 = MomentFunct_Uv2(A_vec,D_vec,Dist_vec,Z2_vec,J0_vec,theta0,Vbar);
       
       X2_data(mm0,:) = [ml_vec(ml_indx) mu_vec(mu_indx)...
                         ml_vec2(ml_indx) mu_vec2(mu_indx)];
                     

   elseif strcmp(IV,'inc_mean') 
       Z_vec = ones(J0,1);
%        Z3_vec = IV_matrix(:,2);
       Z3_vec = 1*(IV_matrix(:,2) > median(IV_matrix(:,2)));
       Z4_vec = 1*(IV_matrix(:,2) <= median(IV_matrix(:,2)));
       
       ml_vec  = MomentFunct_Lv2(A_vec,D_vec,Dist_vec,Z_vec,J0_vec,theta0,Vbar);
       ml_vec3 = MomentFunct_Lv2(A_vec,D_vec,Dist_vec,Z3_vec,J0_vec,theta0,Vbar);
       ml_vec4 = MomentFunct_Lv2(A_vec,D_vec,Dist_vec,Z4_vec,J0_vec,theta0,Vbar);
       
       mu_vec  = MomentFunct_Uv2(A_vec,D_vec,Dist_vec,Z_vec,J0_vec,theta0,Vbar);
       mu_vec3 = MomentFunct_Uv2(A_vec,D_vec,Dist_vec,Z3_vec,J0_vec,theta0,Vbar);  
       mu_vec4 = MomentFunct_Uv2(A_vec,D_vec,Dist_vec,Z4_vec,J0_vec,theta0,Vbar);
       
       
       X2_data(mm0,:) = [ml_vec(ml_indx) mu_vec(mu_indx)...
                         ml_vec3(ml_indx) mu_vec3(mu_indx)...
                         ml_vec4(ml_indx) mu_vec4(mu_indx)];       

   elseif strcmp(IV,'inc_median')   
       Z_vec = ones(J0,1);
%        Z3_vec = IV_matrix(:,3);
       Z3_vec = 1*(IV_matrix(:,3) > median(IV_matrix(:,3)));
       Z4_vec = 1*(IV_matrix(:,3) <= median(IV_matrix(:,3)));   
       
       ml_vec  = MomentFunct_Lv2(A_vec,D_vec,Dist_vec,Z_vec,J0_vec,theta0,Vbar);
       ml_vec3 = MomentFunct_Lv2(A_vec,D_vec,Dist_vec,Z3_vec,J0_vec,theta0,Vbar);
       ml_vec4 = MomentFunct_Lv2(A_vec,D_vec,Dist_vec,Z4_vec,J0_vec,theta0,Vbar);
       
       mu_vec  = MomentFunct_Uv2(A_vec,D_vec,Dist_vec,Z_vec,J0_vec,theta0,Vbar);
       mu_vec3 = MomentFunct_Uv2(A_vec,D_vec,Dist_vec,Z3_vec,J0_vec,theta0,Vbar);  
       mu_vec4 = MomentFunct_Uv2(A_vec,D_vec,Dist_vec,Z4_vec,J0_vec,theta0,Vbar);       
       
       X2_data(mm0,:) = [ml_vec(ml_indx) mu_vec(mu_indx)...
                         ml_vec3(ml_indx) mu_vec3(mu_indx)...
                         ml_vec4(ml_indx) mu_vec4(mu_indx)];

                     
   elseif strcmp(IV,'empl_rate')   
       Z_vec = ones(J0,1);
%        Z3_vec = IV_matrix(:,4); 
       Z3_vec = 1*(IV_matrix(:,4) > median(IV_matrix(:,4)));
       Z4_vec = 1*(IV_matrix(:,4) <= median(IV_matrix(:,4)));
       
       ml_vec  = MomentFunct_Lv2(A_vec,D_vec,Dist_vec,Z_vec,J0_vec,theta0,Vbar);
       ml_vec3 = MomentFunct_Lv2(A_vec,D_vec,Dist_vec,Z3_vec,J0_vec,theta0,Vbar);
       ml_vec4 = MomentFunct_Lv2(A_vec,D_vec,Dist_vec,Z4_vec,J0_vec,theta0,Vbar);
       
       mu_vec  = MomentFunct_Uv2(A_vec,D_vec,Dist_vec,Z_vec,J0_vec,theta0,Vbar);
       mu_vec3 = MomentFunct_Uv2(A_vec,D_vec,Dist_vec,Z3_vec,J0_vec,theta0,Vbar);  
       mu_vec4 = MomentFunct_Uv2(A_vec,D_vec,Dist_vec,Z4_vec,J0_vec,theta0,Vbar);       
       
       X2_data(mm0,:) = [ml_vec(ml_indx) mu_vec(mu_indx)...
                         ml_vec3(ml_indx) mu_vec3(mu_indx)...
                         ml_vec4(ml_indx) mu_vec4(mu_indx)];
                     
   elseif strcmp(IV,'demographics')   
       Z_vec = ones(J0,1);
%        Z3_vec = IV_matrix(:,2);       
%        Z4_vec = IV_matrix(:,3);
%        Z5_vec = IV_matrix(:,4);
       Z3_vec = 1*(IV_matrix(:,2) > median(IV_matrix(:,2)));
%        Z4_vec = 1*(IV_matrix(:,2) <= median(IV_matrix(:,2)));
       Z5_vec = 1*(IV_matrix(:,3) > median(IV_matrix(:,3)));
%        Z6_vec = 1*(IV_matrix(:,3) <= median(IV_matrix(:,3)));
       Z7_vec = 1*(IV_matrix(:,4) > median(IV_matrix(:,4)));
%        Z8_vec = 1*(IV_matrix(:,4) <= median(IV_matrix(:,4)));
       
       ml_vec  = MomentFunct_Lv2(A_vec,D_vec,Dist_vec,Z_vec,J0_vec,theta0,Vbar);
       ml_vec3 = MomentFunct_Lv2(A_vec,D_vec,Dist_vec,Z3_vec,J0_vec,theta0,Vbar);
%        ml_vec4 = MomentFunct_Lv2(A_vec,D_vec,Dist_vec,Z4_vec,J0_vec,theta0,Vbar);
       ml_vec5 = MomentFunct_Lv2(A_vec,D_vec,Dist_vec,Z5_vec,J0_vec,theta0,Vbar);
%        ml_vec6 = MomentFunct_Lv2(A_vec,D_vec,Dist_vec,Z6_vec,J0_vec,theta0,Vbar);
       ml_vec7 = MomentFunct_Lv2(A_vec,D_vec,Dist_vec,Z7_vec,J0_vec,theta0,Vbar);
%        ml_vec8 = MomentFunct_Lv2(A_vec,D_vec,Dist_vec,Z8_vec,J0_vec,theta0,Vbar);
       
       mu_vec  = MomentFunct_Uv2(A_vec,D_vec,Dist_vec,Z_vec,J0_vec,theta0,Vbar);
       mu_vec3 = MomentFunct_Uv2(A_vec,D_vec,Dist_vec,Z3_vec,J0_vec,theta0,Vbar);  
%        mu_vec4 = MomentFunct_Uv2(A_vec,D_vec,Dist_vec,Z4_vec,J0_vec,theta0,Vbar); 
       mu_vec5 = MomentFunct_Uv2(A_vec,D_vec,Dist_vec,Z5_vec,J0_vec,theta0,Vbar);  
%        mu_vec6 = MomentFunct_Uv2(A_vec,D_vec,Dist_vec,Z6_vec,J0_vec,theta0,Vbar);
       mu_vec7 = MomentFunct_Uv2(A_vec,D_vec,Dist_vec,Z7_vec,J0_vec,theta0,Vbar);  
%        mu_vec8 = MomentFunct_Uv2(A_vec,D_vec,Dist_vec,Z8_vec,J0_vec,theta0,Vbar);
       
       X2_data(mm0,:) = [ml_vec(ml_indx)  mu_vec(mu_indx)...
                         ml_vec3(ml_indx) mu_vec3(mu_indx)...
                         ml_vec5(ml_indx) mu_vec5(mu_indx)...
                         ml_vec7(ml_indx) mu_vec7(mu_indx)];
%                          ml_vec8(ml_indx) mu_vec8(mu_indx)];  
%                          ml_vec4(ml_indx) mu_vec4(mu_indx)...    
%                          ml_vec6(ml_indx) mu_vec6(mu_indx)...
   else
      Z_vec = ones(J0,1);
      ml_vec = MomentFunct_Lv2(A_vec,D_vec,Dist_vec,Z_vec,J0_vec,theta0,Vbar);
      mu_vec = MomentFunct_Uv2(A_vec,D_vec,Dist_vec,Z_vec,J0_vec,theta0,Vbar);
      
      X_data(mm0,:) = [ml_vec(ml_indx) mu_vec(mu_indx)];
   
   end 
     
end

if strcmp(IV,'Y')
    salida = X2_data;
elseif strcmp(IV,'Y1')
    salida = X2_data;
elseif strcmp(IV,'Y2')
    salida = X2_data;
elseif strcmp(IV,'inc_mean')
    salida = X2_data;
elseif strcmp(IV,'inc_median') 
    salida = X2_data;
elseif strcmp(IV,'empl_rate') 
    salida = X2_data;
elseif strcmp(IV,'demographics') 
    salida = X2_data;
elseif strcmp(IV,'N')
    salida = X_data;
end

end