clear all
%% ANN parameters
gen_new_data = 1;
no_samples  = 1000;
max_epochs = 20;
arch_nn = [10,50,10];
write2fortran = 1;
name = 'ann_dom';
show_plots = 1;

%% set domain to be trained
% v1_min = 1*10^-29;          % m^3, equiv to less than 1 nm in diameter
% v1_max = 6*10^-13;          % m^3, equiv to roughly 100 micron in diameter

dom = 'all';                   %all, a,b,c,d in strips scheme
name = strcat(name,'_',dom);

[v1_min,v1_max,v2_min, v2_max] = create_v2_subdomain_STRIPS(dom);

% v2_min = 1*10^-29;          % m^3
% v2_max = 6*10^-13;          % m^3

T_min = 273;               % K
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
%     
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
input4training = scaling4training(inputs_prescaling);
outputs = output_scaling(outputs);% log10 scaling the output to [-1,1]

%% gen NN and save net matlab obj

net_name = generate_NN(input4training,outputs,arch_nn,name,max_epochs,show_plots);

%% Load to fortran input .in files
write_flag = 'inplace';% 'test','inplace','store','all'
load_curr_net = 1;

if(load_curr_net == 0)
    %hard code the net you want to write into fortran
    name = 'coag_net_w_ordering_5:12:10:1';
    net = load(strcat('./trained_nets/',name,'.mat'));
    net = net.net;% fixes annoying object structure when read in
elseif(load_curr_net == 1)
    name = net_name;
    net = load(strcat('./trained_nets/',name));
    net = net.net;% fixes annoying object structure when read in
end

write2fortranV2(net,name,write_flag);
