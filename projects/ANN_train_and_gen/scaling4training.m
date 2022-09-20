function [data] = scaling4training(inputs,min_max)
%physical v to physical d_p to [-1,1]
%particle volume v1 and v2
% v_min = 10^-29; %m^3
% v_max = 10^-18; %m^3

v1_min = min_max(1,1);
v1_max = min_max(1,2 );

v2_min = min_max(2,1);
v2_max = min_max(2,2);

% d_min = ((6.0/pi())*v_min)^(1/3);
% d_max = ((6.0/pi())*v_max)^(1/3);

% v scaling
login1 = log10(inputs(:,1));
login2= log10(inputs(:,2));


inputs(:,1) = 2*(login1-log10(v1_min))./((log10(v1_max) - log10(v1_min)))-1;
inputs(:,2) = 2*(login2-log10(v2_min))./((log10(v2_max) - log10(v2_min)))-1;


% d scaling
% d_in1 = (inputs(:,1)*(6.0/pi())).^(1/3);
% d_in2 = (inputs(:,2)*(6.0/pi())).^(1/3);

% inputs(:,1) = 2*(log10(d_in1)-log10(d_min))./((log10(d_max) - log10(d_min)))-1;
% inputs(:,2) = 2*(log10(d_in2)-log10(d_min))./((log10(d_max) - log10(d_min)))-1;
%%
%Temperature
T_min = min_max(3,1);%K
T_max = min_max(3,2); %K

inputs(:,3) = 2*(inputs(:,3)-T_min)/(T_max-T_min) -1;

%Mean Free Path
l_min = min_max(4,1);
l_max = min_max(4,2);
inputs(:,4) = 2*(inputs(:,4)-l_min)/(l_max-l_min) -1;

%viscosity
mu_min = min_max(5,1);
mu_max = min_max(5,2);
inputs(:,5) = 2*(inputs(:,5)-mu_min)/(mu_max-mu_min) -1;

data = inputs(:,:);

end