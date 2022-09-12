function [data] = scaling4training(inputs)

%physical v to physical d_p to [-1,1]

%particle volume v1 and v2
v_min = 10^-29; %m^3
v_max = 10^-18; %m^3
% 
% d_min = ((6.0/pi())*v_min)^(1/3);
% d_max = ((6.0/pi())*v_max)^(1/3);

% v scaling
login1 = log10(inputs(:,1));
login2= log10(inputs(:,2));
% 
inputs(:,1) = 2*(login1-log10(v_min))./((log10(v_max) - log10(v_min)))-1;
inputs(:,2) = 2*(login2-log10(v_min))./((log10(v_max) - log10(v_min)))-1;
%

% d scaling
% d_in1 = (inputs(:,1)*(6.0/pi())).^(1/3);
% d_in2 = (inputs(:,2)*(6.0/pi())).^(1/3);
% 
% inputs(:,1) = 2*(log10(d_in1)-log10(d_min))./((log10(d_max) - log10(d_min)))-1;
% inputs(:,2) = 2*(log10(d_in2)-log10(d_min))./((log10(d_max) - log10(d_min)))-1;



%% 

% inputs(:,1) = log(inputs(:,1)/v_min);
% inputs(:,2) = log(inputs(:,2)/v_min);



%Temperature
T_min = 273;%K
T_max = 4000; %K

inputs(:,3) = 2*(inputs(:,3)-T_min)/(T_max-T_min) -1;

%Mean Free Path
l_min = 5*10^-8;
l_max = 5*10^-6;
inputs(:,4) = 2*(inputs(:,4)-l_min)/(l_max-l_min) -1;

%viscosity
mu_min = 5*10^-6;
mu_max = 2*10^-4;
inputs(:,5) = 2*(inputs(:,5)-mu_min)/(mu_max-mu_min) -1;


data = inputs(:,:);


end