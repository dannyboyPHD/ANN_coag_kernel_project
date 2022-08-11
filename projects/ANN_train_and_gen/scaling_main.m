%% create [0,1] array using Latin Hyper cube sampling
inputs_unscaled = lhsdesign(200000,5);%i.e. 1000 samples

inputs = scaling_simple(inputs_unscaled);%creates values in physical ranges
%%
for i = 1:200000
[inputs(i,1),inputs(i,2)] = order_v1v2(inputs(i,1:2));
end
dlmwrite('input_kernel_data.txt',inputs,'precision',16);% data for fortran script to gen outputs
%%


%%
inputs_prescaling = dlmread('input_kernel_data.txt'); %or whatever filename you choose

input4training = scaling4training(inputs_prescaling);
%%
outputs = dlmread('outputs.txt');%needs to be scaled, [-1,1] worked well previously 
%%
% min_out = min(outputs(:));
% max_out = max(outputs(:));
outputs = output_scaling(outputs);% log10 scaling the output to [-1,1]

%%
%call nftool
nftool

%%
%create test file - outputs using NN created in matlab, this is to test
%fortran implementation
test_outputs = zeros(200000,1);
test_outputs(:) = net(input4training(:,:)');


test_data = zeros(200000,6);
test_data(:,1:5) = inputs(:,:);
test_data(:,6) = 0.5*(test_outputs(:)+1)*(max_out - min_out) + min_out;


dlmwrite('res.dat',test_outputs,'precision',16);
dlmwrite('testdata.dat',test_data,'precision',16);






