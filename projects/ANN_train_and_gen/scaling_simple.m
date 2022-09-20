function [inputs] = scaling_simple(inputs,min_max)

%scaling Latin Hypercube sampling to real-life values

%particle volume v1 and v2 sampling from v-logspace
v1_min = min_max(1,1);
v1_max = min_max(1,2);

v2_min = min_max(2,1);
v2_max = min_max(2,2);

inputs(:,1) = inputs(:,1)*(log10(v1_max) - log10(v1_min)) + log10(v1_min);%v_1
inputs(:,2) = inputs(:,2)*(log10(v2_max) - log10(v2_min)) + log10(v2_min);%v_2
% input(:,2) = inputs(:,2).*(log10(v1_max/2) - inputs(:,1)) + inputs(:,1); 

inputs(:,1) = 10.^inputs(:,1);
inputs(:,2) = 10.^inputs(:,2);

%Temperature
T_min = min_max(3,1);
T_max = min_max(3,2);

%log sampling
inputs(:,3) = inputs(:,3)*(log10(T_max) - log10(T_min)) + log10(T_min);
inputs(:,3) = 10.^inputs(:,3);

%viscosity
mu_min = min_max(5,1);
mu_max = min_max(5,2);

%log sampling
inputs(:,5) = inputs(:,5)*(log10(mu_max) - log10(mu_min)) + log10(mu_min);
inputs(:,5) = 10.^(inputs(:,5));


%Mean Free Path
l_min = min_max(4,1);
l_max = min_max(4,2);

%log scaling
% R_air = 287; %J kg^-1 K^-1
% R_al = 81.5; %J kg^-1 K^-1
% 
% R = rand()*(R_air - R_al) + R_al; 
% P_atm = 1.01325*10^5; %Pa

inputs(:,4) = inputs(:,4)*(log10(l_max) - log10(l_min)) + log10(l_min);
inputs(:,4) = 10.^(inputs(:,4));


% % consistnet mean free path with vis and T
% inputs(:,4) = sqrt(pi*R/2)*(1/P_atm)*inputs(:,5).*sqrt(inputs(:,3));


end

