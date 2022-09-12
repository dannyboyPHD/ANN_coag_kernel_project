clear all
%% ANN parameters
gen_new_data = 1;
no_samples  = 50000;
max_epochs = 5000;
arch_nn = [8];
write2fortran = 1;
name = 'ball';
show_plots = 1;
%% set domain to be trained
% v1_min = 1*10^-29;          % m^3, equiv to less than 1 nm in diameter
% v1_max = 6*10^-13;          % m^3, equiv to roughly 100 micron in diameter

dom = 'all';                   %all, a,b,c,d in strips scheme
name = strcat(name,'_',dom);

[v1_min,v1_max,v2_min, v2_max] = create_v2_subdomain_STRIPS(dom);

% total_area = 0.5*(6*10^-13 - 10^-29)^2;
% area = (v2_max - v2_min)*(v1_max - v1_min);

% no_samples = no_samples*(area/total_area);

% v2_min = 1*10^-29;          % m^3
% v2_max = 6*10^-13;          % m^3

T_min = 2000;               % K
T_max = 4000;              % K, it's a hot flame - burning Al2O3 droplet halo 
mfp_min = 5*10^-8;         % m
mfp_max = 5*10^-6;         % m
vis_min = 5*10^-6;         % kgm^-1s^-1
vis_max = 2*10^-4;         % kgm^-1s^-1

domain = [v1_min,v1_max;...
          v2_min,v2_max;...
          T_min,T_max;...
          mfp_min,mfp_max;...
          vis_min,vis_max];
         
%% create [0,1] array using Latin Hyper cube sampling
if(gen_new_data ==1)
    
    inputs_unscaled = lhsdesign(no_samples,5);
    
    inputs = scaling_simple(inputs_unscaled,domain);%samples form log(domain) space, then scales values in physical ranges 

    % order v1
    for i = 1:no_samples
        [inputs(i,1),inputs(i,2)] = order_v1v2(inputs(i,1:2));
    end
%     inputs(:,3) = 2000
%     inputs(:,4) = 5*10^-7
%     inputs(:,5) = 5*10^-5
    
  
    dlmwrite('input_kernel_data.txt',inputs,'precision',16);% data for fortran script to gen outputs
    
    if isfile('outputs.txt')&&isfile('no_samples.txt')
        disp('removing prev outputs.txt and no_samples.txt')
        !rm outputs.txt no_samples.txt 
    else
        disp('outputs.txt or no_samples.txt not found');
    end
    
    a = [no_samples];
    writematrix(a,'no_samples.txt')
    
    disp('creating new input output pairs')% recompile the executable if ona differnet machine
    
    if isfile('gen_input_output_pairs')
        !./gen_input_output_pairs
        disp('done')
    else
        disp('please compile using make on terminal (outside matlab env)');
    end
  
    inputs_prescaling = dlmread('input_kernel_data.txt');
    outputs = dlmread('outputs.txt');  
else
    inputs_prescaling = dlmread('input_kernel_data.txt');
    outputs = dlmread('outputs.txt'); 
end

%% scaling everything to [-1,1]
% scatter3(inputs(:,1),inputs(:,2),outputs(:));
% set(gca, 'XScale', 'log')
% set(gca, 'YScale', 'log')
% % set(gca,'Zscale','log')
%%

%   inputs(:,2) = inputs(:,2)./inputs(:,1);
%     
%   in = inputs(:,:);
%   inputs = zeros(no_samples,4);
%     
%   inputs(:,1) = in(:,2);
%   inputs(:,2:4) = in(:,3:5);
% 


%%

T_av = 0.5*(T_min+T_max);
mfp_av = 0.5*(mfp_min + mfp_max);
vis_av = 0.5*(vis_min + vis_max);

output4train = zeros(length(outputs),2);
beta_av = zeros(length(outputs),1);

for i = 1:length(outputs)
    beta_av(i) = fabian_original_beta([T_av,mfp_av,vis_av],inputs_prescaling(i,1),inputs_prescaling(i,2));
end
output4train(:,1) = beta_av(:);
output4train(:,2) = (outputs(:) - beta_av(:))./beta_av(:);




input4training = scaling4training(inputs_prescaling);
% % input4training = scaling_selfsimilar(inputs_prescaling);
% outputs = output_scaling(outputs);% log10 scaling the output to [-1,1]
outputs4train = output_scaling(output4train);
%% gen NN and save net matlab obj

net_name = generate_NN(input4training,outputs4train,arch_nn,name,max_epochs,show_plots);

%% Load to fortran input .in files
write_flag = 'inplace';% 'test','inplace','store','all'
load_curr_net = 1;

if(load_curr_net == 0)
    %hard code the net you want to write into fortran
    name = 'b1_6tanh_3mill_samples_3:6:1';
    net = load(strcat('./trained_nets/',name,'.mat'));
    net = net.net;% fixes annoying object structure when read in
elseif(load_curr_net == 1)
    name = net_name;
    net = load(strcat('./trained_nets/',name));
    net = net.net;% fixes annoying object structure when read in
end

write2fortranV2(net,name,write_flag);
%%
% sample = length(input4training(:,1));
sample_size = 1000;

m = -0.8;
n = 3*10^6;

out_min = 10^-17;
out_max = 5*10^-5;

err = zeros(sample_size,1);

beta_true = zeros(sample_size,1);
beta_comp = zeros(sample_size,1);

for i = 1: sample_size
    disp(i)
    beta = fabian_original_beta(inputs_prescaling(i,3:5),inputs_prescaling(i,1),inputs_prescaling(i,2));
    beta_ann = net(input4training(i,:)');
    
    beta_ann(2) = 0.500000*(beta_ann(2) + 1)*(n-m) + m;
%     beta_ann(2) = 0.5*(beta_ann(2) + 1)*(log10(n+abs(2*m))-log10(abs(2*m) +m)) + log10(abs(2*m)+m);
    beta_ann(2) = 10^beta_ann(2) - abs(2*m);
    
    
    beta_check_av = fabian_original_beta([T_av,mfp_av,vis_av],inputs_prescaling(i,1),inputs_prescaling(i,2));
    
    
    
    beta_ann(1) = 0.5*(beta_ann(1) + 1)*(log10(out_max)-log10(out_min)) + log10(out_min);
    beta_ann(1) = 10^beta_ann(1);
    
    beta_a = beta_ann(2)*beta_ann(1) + beta_ann(1);
    
    err(i) = abs(beta_a - beta)/beta;
   
    beta_true(i) = beta;
    beta_comp(i) = beta_a;
    
end
err_comp = sum(err)/sample_size;
%%
plot(beta_true,beta_comp,'o',beta_true,beta_true,'r-');

err_comp
















