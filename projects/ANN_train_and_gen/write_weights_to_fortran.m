% Takes MATLAB net weights format and writes it into column vector for use
% with CPMOD Fortran implementation

% MATLAB format:
% weights in matrix of size [layer+1 x layer]: therefore first row is all
% weights from 1st layer to the 1st neuron in the 2nd layer, second row is
% all weights from 1st layer to the 2nd neuron in the 2nd layer

% Fortran format:
% w(1) = w(1,1) where w(1,1) is from layer 1 neuron 1 to layer 2 neuron 1
% w(2) = w(1,2) where w(1,2) is from layer 1 neuron 2 to layer 2 neuron 1 
% w(3) = w(1,3) where w(1,3) is from layer 1 neuron 3 to layer 2 neuron 1
% ... until last neuron in first layer:
% w(X) = w(1,X) where w(1,X) is from layer 1 end neuron to layer 2 neuron 1
% (technically a bias)
% w(X+1) = w(2,1) where w(2,1) is from layer 1 neuron 1 to layer 2 neuron 2
% and so on
mlp_size = [5,2,1];

no_layers = length(mlp_size) - 1;

for i = 1:no_layers
   dim_NN_file = strcat('layer_dim_',num2str(i),'.in');
   w_file = strcat('weights_',num2str(i),'.in');
   b_file = strcat('bias_',num2str(i),'.in');
   
   
   
   
   
    
end



% writefile ='trained.in';
% weights_vec = 0;
% 
% for j = 1:length(mlp_size)-1
%   B{j} = net.b{j};
%   if j == 1
%     W{j} = net.IW{j};   %N_neurons(2)*N_inputs
%   else
%     W{j} = net.LW{j,j-1}; %N_neurons(l+1)*N_neurons(l)
%   end
%   train_weights{j} = [W{j},B{j}];
% end
% 
% offset = 1;
% for j = 1:(length(mlp_size)-1)
%   for k = 1:mlp_size(j+1)
%     weights_vec(offset+(k-1)*(mlp_size(j)+1)...
%     :(offset-1)+(mlp_size(j)+1)*k) = train_weights{j}(k,:);    
%   end
%   offset = offset + (mlp_size(j)+1)*mlp_size(j+1);
% end
% 
% dlmwrite(writefile,weights_vec,'delimiter','\n','newline','unix','precision','%.15E');