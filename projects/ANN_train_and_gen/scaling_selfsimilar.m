function [in] =scaling_selfsimilar(inputs)

in = zeros(size(inputs,1),4);

in(:,1) = inputs(:,2)./inputs(:,1); % v2/v1 ratio

v_min = min(in(:,1));
v_max = max(in(:,1));
%physical v to physical d_p to [-1,1]

login1 = log10(in(:,1));

% 
in(:,1) = 2*(login1-log10(v_min))./((log10(v_max) - log10(v_min)))-1;

%%

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

