%% study and corden-off areas of suitable non-linearity in beta in simple manner
clear all
%%
v_start = [2*10^-17,10^-29]; % bottom left of beta domain

dz  = [0,1]*10^-29;
domain_limits = [10^-13,10^-14];
%%
params = [2000,5*10^-7,5*10^-5];
nonLin_limit = 0.75; %100%
% dz_Lims = zeros(100,2);
n_searches = 1;
max_n = 3;
%%
for i = 1:n_searches
    v_lims = search_dz(v_start,dz,max_n,nonLin_limit,params,domain_limits);
    hold on  
    plot(v_start(1),v_start(2),'k*')
    plot(v_lims(:,1), v_lims(:,2),'-o')
    
    v_start = v_start + 10*[v_start(1),0];
    
end

