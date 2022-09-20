clear all
%% ANN parameters
gen_new_data = 1;
no_samples  = 300000;
max_epochs = 6000;
arch_nn = [8];
write2fortran = 1;
name = 'ball';
show_plots = 1;
kernel = 1;

%% first stage predicting beta_av
% v1_min = 1*10^-29;          % m^3, equiv to less than 1 nm in diameter
% v1_max = 6*10^-13;          % m^3, equiv to roughly 100 micron in diameter

dom = 'all';                   %all, a,b,c,d in strips scheme
name = strcat(name,'_',dom);

% [v1_min,v1_max,v2_min, v2_max] = create_v2_subdomain_STRIPS(dom);

v1_min = 1*10^-29;          % m^3
v1_max = 6*10^-18; 

v2_min = 1*10^-29;          % m^3
v2_max = 6*10^-18/2;          % m^3

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
%% beta average

T_av = 0.5*(T_min+T_max);
mfp_av = 0.5*(mfp_min + mfp_max);
vis_av = 0.5*(vis_min + vis_max);

output4train = zeros(length(outputs),1);
beta_av = zeros(length(outputs),1);

if kernel ==1 
    for i = 1:length(outputs)    
        beta_av(i) = b1([T_av,mfp_av,vis_av],inputs_prescaling(i,1),inputs_prescaling(i,2));
    end
    T = inputs_prescaling(:,3);
    inputs_prescaling = inputs_prescaling(:,1:2); % drop T mfp and vis
    
    
elseif kernel == 2
     for i = 1:length(outputs)    
        beta_av(i) = b2([T_av,mfp_av,vis_av],inputs_prescaling(i,1),inputs_prescaling(i,2));
     end
     T = inputs_prescaling(:,3);
     mfp = inputs_prescaling(:,4);
     vis = inputs_prescaling(:,5);
    inputs_prescaling = inputs_prescaling(:,1:2); % drop T mfp and vis 
    
else
    for i = 1:length(outputs)
        beta_av(i) = fabian_original_beta([T_av,mfp_av,vis_av],inputs_prescaling(i,1),inputs_prescaling(i,2));
   
    end
    T = inputs_prescaling(:,3);
    mfp = inputs_prescaling(:,4);
    vis = inputs_prescaling(:,5);
    inputs_prescaling = inputs_prescaling(:,1:2); % drop T mfp and vis  
    
    
end
%% 1 stage output beta av

    output4train = zeros(length(outputs),1);
    output4train(:,1) = beta_av(:); % output of first stage

%% scaling for training
if kernel == 1
    input4training = scaling4training_b1(inputs_prescaling,domain);
    
    output_domain = zeros(1,2);
    output_domain(1,1) = min(output4train(:,1));
    output_domain(1,2) = max(output4train(:,1));

elseif kernel == 2
    input4training = scaling4training_b1(inputs_prescaling,domain);
    
    output_domain = zeros(1,2);
    output_domain(1,1) = min(output4train(:,1));
    output_domain(1,2) = max(output4train(:,1));
    
else
    input4training = scaling4training_b1(inputs_prescaling,domain);
    
    output_domain = zeros(1,2);
    output_domain(1,1) = min(output4train(:,1));
    output_domain(1,2) = max(output4train(:,1));
    

end

%%

outputs4train = output_scaling_1output(output4train,output_domain);

%%

net_name = generate_NN(input4training,outputs4train,arch_nn,name,max_epochs,show_plots);

%%
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
    net_1 = net.net;% fixes annoying object structure when read in
end

write2fortranV2(net_1,name,write_flag);
%% error check beta av prediction
sample_size = 1000;

err = zeros(sample_size,1);

beta_true = zeros(sample_size,1);
beta_comp = zeros(sample_size,1);

for i = 1: sample_size
    disp(i)

    if kernel == 1
        beta = b1(T_av,inputs_prescaling(i,1),inputs_prescaling(i,2));
        beta_check_av = b1([T_av,mfp_av,vis_av],inputs_prescaling(i,1),inputs_prescaling(i,2));
    elseif kernel == 2 
        beta = b2([T_av,mfp_av,vis_av],inputs_prescaling(i,1),inputs_prescaling(i,2));
        
    elseif kernel == 12
        beta = fabian_original_beta([T_av,mfp_av,vis_av],inputs_prescaling(i,1),inputs_prescaling(i,2));
%         beta_check_av = b1([T_av,mfp_av,vis_av],inputs_prescaling(i,1),inputs_prescaling(i,2));
        
        
    end
    
    
    beta_ann = net_1(input4training(i,:)');
    beta_ann = 0.5*(beta_ann + 1)*(log10(output_domain(1,2))-log10(output_domain(1,1))) + log10(output_domain(1,1));
    beta_ann = 10^beta_ann;

    beta_a = beta_ann;
    err(i) = abs(beta_a - beta)/beta;
   
    beta_true(i) = beta;
    beta_comp(i) = beta_a; 
end
err_comp = sum(err)/sample_size;
plot(beta_true,beta_comp,'o',beta_true,beta_true,'r-');

err_comp

%% second stage NN

if kernel == 1
    inputs = zeros(no_samples,2);
    inputs(:,1) = outputs4train(:); % beta av scaled
    inputs(:,2) = -1+2*(T(:)-T_min)/(T_max - T_min); % lin-scaled T
    
elseif kernel == 2
    inputs = zeros(no_samples,6);
    inputs(:,1) = outputs4train(:); % beta av scaled
    inputs(:,2) = T(:)./vis(:);
    
    ratio_min = min(inputs(:,2));
    ratio_max = max(inputs(:,2));
    inputs(:,2) = -1+2*(inputs(:,2)-ratio_min)/(ratio_max -ratio_min);
    
%     inputs(:,2) = -1+2*(T(:)-T_min)/(T_max -T_min); % scaled T
%     inputs(:,3) = -1+2*(log10(mfp(:))-log10(mfp_min))/(log10(mfp_max) - log10(mfp_min)); % scaled mfp
    inputs(:,3) = inputs_prescaling(:,1)./mfp(:);
    kn1_min = min(inputs(:,3));
    kn1_max = max(inputs(:,3));
    inputs(:,3) = -1 + 2*(log10(inputs(:,3)) - log10(kn1_min))/(log10(kn1_max) - log10(kn1_min));
    
    inputs(:,4) = inputs_prescaling(:,2)./mfp(:);
    kn2_min = min(inputs(:,4));
    kn2_max = max(inputs(:,4));
    inputs(:,4) = -1 + 2*(log10(inputs(:,4)) - log10(kn1_min))/(log10(kn1_max) - log10(kn1_min));
    
    
    inputs(:,5) = input4training(:,1);
    inputs(:,6) = input4training(:,2);
    
    
%     inputs(:,5) = -1+2*(vis(:)-vis_min)/(vis_max - vis_min); % scaled vis
%     inputs(:,5) = -1+2*(mfp(:) - mfp_min)/(mfp_max - mfp_min);
elseif kernel == 12
    inputs = zeros(no_samples,7);
    inputs(:,1) = outputs4train(:); % beta av scaled
    inputs(:,2) = T(:)./vis(:);
    
    ratio_min = min(inputs(:,2));
    ratio_max = max(inputs(:,2));
    inputs(:,2) = -1+2*(inputs(:,2)-ratio_min)/(ratio_max -ratio_min);
    
%     inputs(:,2) = -1+2*(T(:)-T_min)/(T_max -T_min); % scaled T
%     inputs(:,3) = -1+2*(log10(mfp(:))-log10(mfp_min))/(log10(mfp_max) - log10(mfp_min)); % scaled mfp
    inputs(:,3) = inputs_prescaling(:,1)./mfp(:);
    kn1_min = min(inputs(:,3));
    kn1_max = max(inputs(:,3));
    inputs(:,3) = -1 + 2*(log10(inputs(:,3)) - log10(kn1_min))/(log10(kn1_max) - log10(kn1_min));
    
    inputs(:,4) = inputs_prescaling(:,2)./mfp(:);
    kn2_min = min(inputs(:,4));
    kn2_max = max(inputs(:,4));
    inputs(:,4) = -1 + 2*(log10(inputs(:,4)) - log10(kn1_min))/(log10(kn1_max) - log10(kn1_min));
    
    
    inputs(:,5) = input4training(:,1);
    inputs(:,6) = input4training(:,2);
    inputs(:,7) = T(:);
    
    ratio_min = min(inputs(:,7));
    ratio_max = max(inputs(:,7));
    inputs(:,7) = -1+2*(inputs(:,7)-ratio_min)/(ratio_max -ratio_min);
end



output_domain = zeros(1,2);
output_domain(1,1) = min(outputs(:));
output_domain(1,2) = max(outputs(:));

outputs = output_scaling_1output(outputs,output_domain);

%%
name = '2stage';
arch_nn = [12];
net_name = generate_NN(inputs,outputs,arch_nn,name,max_epochs,show_plots);
%%
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
    net_2 = net.net;% fixes annoying object structure when read in
end

write2fortranV2(net_2,name,write_flag);
%%
sample_size = 2000;

% out_min = 10^-17;
% out_max = 5*10^-5;

err = zeros(sample_size,1);

beta_true = zeros(sample_size,1);
beta_comp = zeros(sample_size,1);

for i = 1: sample_size
    disp(i)
%     beta = fabian_original_beta(inputs_prescaling(i,3:5),inputs_prescaling(i,1),inputs_prescaling(i,2));
    if kernel == 1
        beta = b1(T(:),inputs_prescaling(i,1),inputs_prescaling(i,2));
        beta_check_av = b1([T_av,mfp_av,vis_av],inputs_prescaling(i,1),inputs_prescaling(i,2));
    elseif kernel == 2 
        beta = b2(inputs_prescaling(i,3:5),inputs_prescaling(i,1),inputs_prescaling(i,2));
        
    elseif kernel == 12
        beta = b1([T_av,mfp_av,vis_av],inputs_prescaling(i,1),inputs_prescaling(i,2));
        beta_check_av = b1([T_av,mfp_av,vis_av],inputs_prescaling(i,1),inputs_prescaling(i,2));
    elseif kernel == 3
        
        beta = fabian_original_beta(inputs_prescaling(i,3:5),inputs_prescaling(i,1),inputs_prescaling(i,2));
        
        
    end
    
    
    beta_ann = net_1(input4training(i,:)');% predict beta av scaled
    
    inputs(i,1) = beta_ann;
    beta_ann = net_2(inputs(i,:)');
    
    beta_ann = 0.5*(beta_ann + 1)*(log10(output_domain(1,2))-log10(output_domain(1,1))) + log10(output_domain(1,1));
    beta_ann = 10^beta_ann;
%     
%     beta_ann(2) = 0.500000*(beta_ann(2) + 1)*(output_domain(2,2)-output_domain(2,1)) + output_domain(2,1);
% % 
%     beta_ann(1) = 0.5*(beta_ann(1) + 1)*(log10(output_domain(1,2))-log10(output_domain(1,1))) + log10(output_domain(1,1));
%     beta_ann(1) = 10^beta_ann(1);
     
%     beta_a = beta_ann(2)*beta_ann(1) + beta_ann(1);
    beta_a = beta_ann;
    err(i) = abs(beta_a - beta)/beta;
   
    beta_true(i) = beta;
    beta_comp(i) = beta_a; 
end
err_comp = sum(err)/sample_size;
%%
close all;
plot(beta_true,beta_comp,'o',beta_true,beta_true,'r-');

err_comp








      


