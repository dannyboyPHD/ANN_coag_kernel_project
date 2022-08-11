clear all
%% ANN parameters
gen_new_data = 1;
no_samples = 2000;
max_epochs = 20;
arch_nn = [10,10,10];
write2fortran = 1;
name = 'sarkis_test1';

%% create [0,1] array using Latin Hyper cube sampling
if(gen_new_data ==1)
    inputs_unscaled = lhsdesign(no_samples,5);

    inputs = scaling_simple(inputs_unscaled);%samples form log(v) space, then scales values in physical ranges 
    
    % order v1 and v2
    for i = 1:no_samples
        [inputs(i,1),inputs(i,2)] = order_v1v2(inputs(i,1:2));
    end
    
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

input4training = scaling4training(inputs_prescaling);
outputs = output_scaling(outputs);% log10 scaling the output to [-1,1]

%% gen NN and save net matlab obj

generate_NN(input4training,outputs,arch_nn,name,max_epochs);

%% Load to fortran input .in files
% write2fortran_in = 1;
% name = 'test_net_10:10:8:4_ANN.mat';
% net = load(name);
%%

% number_Layers = loadedin_net.net.numLayers;




