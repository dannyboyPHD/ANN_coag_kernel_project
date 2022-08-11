function [data] = scaling_simple(inputs)

%scaling Latin Hypercube sampling to real-life values

%particle volume v1 and v2 sampling from v-logspace
v_min = 10^-29; %m^3
v_max = 10^-13; %m^3
inputs(:,1) = inputs(:,1)*(log10(v_max) - log10(v_min)) + log10(v_min);%v_1
inputs(:,2) = inputs(:,2)*(log10(v_max) - log10(v_min)) + log10(v_min);%v_2

inputs(:,1) = 10.^inputs(:,1);
inputs(:,2) = 10.^inputs(:,2);

%Temperature
T_min = 273;%K
T_max = 4000; %K

inputs(:,3) = inputs(:,3)*(T_max-T_min) + T_min;

%Mean Free Path
l_min = 5*10^-8;
l_max = 5*10^-6;
inputs(:,4) = inputs(:,4)*(l_max-l_min)+l_min;

%viscosity
mu_min = 5*10^-6;
mu_max = 2*10^-4;
inputs(:,5) = inputs(:,5)*(mu_max-mu_min) + mu_min;


data = inputs(:,:);


end

