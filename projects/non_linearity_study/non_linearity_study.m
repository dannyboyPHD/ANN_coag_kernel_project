%% study and corden-off areas of suitable non-linearity in beta in simple manner

v_start = [10^-29,10^-29]; % bottom left of beta domain
% grow in some search direction
% see what step is required for lnearity measure to drop to ncrease to 1%
% store, mark on plot
% create contour plot
% use this information to create subdomains
%
params = [2000,5*10^-7,5*10^-5];
res = 100
%%

b = fabian_original_beta([1500,5*10^-7,5*10^-5],v_start(1),v_start(2));

dir = [1,1];  % unit vector in v1 direction

dz = dir*(0.5*10^-28);

b_end = fabian_original_beta([1500,5*10^-7,5*10^-5],v_start(1)+dz(1),v_start(2)+dz(2));
v_end = v_start +dz;

points_on_step = req_v1v2points(v_start,v_end,res)







db = b_end - b;
