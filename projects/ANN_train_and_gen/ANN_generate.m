clear all
%% ANN parameters
gen_new_data = 1;
no_samples  = 100000;
max_epochs = 15;
arch_nn = [10];
write2fortran = 1;
name = 'lightweight_test';
show_plots = 1;




%% create [0,1] array using Latin Hyper cube sampling
if(gen_new_data ==1)
    
    
    inputs_unscaled = lhsdesign(no_samples,5);
    
    
  
    inputs = scaling_simple(inputs_unscaled);%samples form log(v) space, then scales values in physical ranges 

    % order v1
    for i = 1:no_samples
        [inputs(i,1),inputs(i,2)] = order_v1v2(inputs(i,1:2));
    end
    inputs(:,3) = 2000
    inputs(:,4) = 5*10^-7
    inputs(:,5) = 5*10^-5
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
%         disp('attempt to compile gen_input_output_pairs')
%         !gfortran fabian_data_gen.f90 -o gen_input_output_pairs
%         if isfile('gen_input_output_pairs')
%             !./gen_input_output_pairs
%         else
%             disp('error in compilation');
%         end
        
    end
  
    inputs_prescaling = dlmread('input_kernel_data.txt');
    outputs = dlmread('outputs.txt');  
else
    inputs_prescaling = dlmread('input_kernel_data.txt');
    outputs = dlmread('outputs.txt'); 
end

%% scaling everything to [-1,1]

scatter3(inputs(:,1),inputs(:,2),outputs(:));
% set(gca, 'XScale', 'log')
% set(gca, 'YScale', 'log')
% set(gca,'Zscale','log')
%%
input4training = scaling4training(inputs_prescaling);
outputs = output_scaling(outputs);% log10 scaling the output to [-1,1]

%% gen NN and save net matlab obj

net_name = generate_NN(input4training,outputs,arch_nn,name,max_epochs,show_plots);

%% Load to fortran input .in files
% 'test','inplace','store','all'
write_flag = 'inplace';
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




%%

% number_Layers = loadedin_net.net.numLayers;




