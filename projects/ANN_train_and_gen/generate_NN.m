function [] = generate_NN(x,t,arch_nn,name,max_epochs)


x = x';
t = t';

% For a list of all training functions type: help nntrain
% 'trainlm' is usually fastest.
% 'trainbr' takes longer but may be better for challenging problems.
% 'trainscg' uses less memory. Suitable in low memory situations.
trainFcn = 'trainbr';  % Bayesian Regularization backpropagation.


net = fitnet(arch_nn,trainFcn);
view(net)

% Choose Input and Output Pre/Post-Processing Functions
% For a list of all processing functions type: help nnprocess
net.input.processFcns = {'removeconstantrows'};
net.output.processFcns = {'removeconstantrows'};

% Setup Division of Data for Training, Validation, Testing
% For a list of all data division functions type: help nndivision
net.divideFcn = 'dividerand';  % Divide data randomly
net.divideMode = 'sample';  % Divide up every sample
net.divideParam.trainRatio = 70/100;
net.divideParam.valRatio = 15/100;
net.divideParam.testRatio = 15/100;
net.trainParam.epochs=max_epochs;

% For a list of all performance functions type: help nnperformance
net.performFcn = 'mse';  % Mean Squared Error

% For a list of all plot functions type: help nnplot
net.plotFcns = {'plotperform','plottrainstate','ploterrhist', ...
    'plotregression', 'plotfit'};

% Train the Network
[net,tr] = train(net,x,t);

% Test the Network
y = net(x);
e = gsubtract(t,y);
performance = perform(net,t,y)

% Recalculate Training, Validation and Test Performance
trainTargets = t .* tr.trainMask{1};
valTargets = t .* tr.valMask{1};
testTargets = t .* tr.testMask{1};
trainPerformance = perform(net,trainTargets,y)
valPerformance = perform(net,valTargets,y)
testPerformance = perform(net,testTargets,y)

%create dynamic name - refer to archicture of hidden layers
a = num2str(net.inputs{1}.size);
for i = 1:length(arch_nn)   
        a = strcat(a,':',num2str(arch_nn(i)));
end
n_out = num2str(net.outputs{net.numLayers}.size);
a = strcat(a,':',n_out);

save(strcat('./trained_nets/',name,'_',a),'net')




end

