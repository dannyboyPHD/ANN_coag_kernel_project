function [] = write2fortranV2(in_net,name,flag)

    total_w_elements = 0;
    total_b_elements = 0;
    
    for l = 1:in_net.numLayers-1
        if(l ==1)
            total_w_elements = total_w_elements + ...
                size(in_net.IW{1},1)*size(in_net.IW{1},2);
            
            total_b_elements = total_b_elements +...
                size(in_net.b{1},1);
        end
            total_w_elements = total_w_elements + ...
                size(in_net.LW{l+1,l},1)*size(in_net.LW{l+1,l},2);
            
            total_b_elements = total_b_elements +...
                size(in_net.b{l+1},1); 
    end
    
    disp(total_w_elements)
    disp(total_b_elements)
    
    w_elements = zeros(total_w_elements,1);
    b_elements = zeros(total_b_elements,1);
    
    cntr_w = 1;
    cntr_b = 1;
    
    for l = 1:in_net.numLayers-1 
       if(l ==1)
          off_w = size(in_net.IW{1},1)*size(in_net.IW{1},2) - 1;
          % stored column major check reshape docs
          w_elements(cntr_w:cntr_w+off_w) = reshape(in_net.IW{1}(:,:),[off_w+1,1]);
          cntr_w = cntr_w + off_w +1;
          
          off_b = size(in_net.b{1},1) -1;
          b_elements(cntr_b:cntr_b+off_b) = in_net.b{1}(:);
          cntr_b = cntr_b + off_b+1;
          
       end
            off_w = size(in_net.LW{l+1,l},1)*size(in_net.LW{l+1,l},2) -1;
            % col major
            w_elements(cntr_w:cntr_w+off_w) = reshape(in_net.LW{l+1,l}(:,:),[off_w+1,1]);
            cntr_w = cntr_w + off_w +1;
            
            off_b = size(in_net.b{l+1},1)-1;
            b_elements(cntr_b:cntr_b+off_b) = in_net.b{l+1}(:);
            cntr_b = cntr_b + off_b +1 ;
    end
    
    %reverse engineer the arch
    arch = zeros(in_net.numLayers,1);
    no_inputs = in_net.inputs{1}.size;
    
    for i = 1:in_net.numLayers
        arch(i) = in_net.layers{i}.size;
    end
    
    nn_info = [no_inputs;in_net.numLayers;arch];
    disp(strcat('layer:',num2str(nn_info(:))));
    
    writematrix(nn_info,strcat(name,'_arch'));
   
if(strcmp(flag,'test')) 
     writematrix(nn_info,strcat(name,'_arch'));
     writematrix(w_elements,strcat(name,'_weights'));
     writematrix(b_elements,strcat(name,'_bias'));
    
    
elseif(strcmp(flag,'inplace'))
     path2env = '../speed_test/input_files/';
     disp('writing into test env');
     writematrix(nn_info,strcat(strcat(path2env,name),'_arch'));
     writematrix(w_elements,strcat(strcat(path2env,name),'_weights'));
     writematrix(b_elements,strcat(strcat(path2env,name),'_bias'));
elseif(strcmp(flag,'all'))
     path2env = '../speed_test/input_files/';
     disp('writing into test and trained_nets env');
     writematrix(nn_info,strcat(strcat(path2env,name),'_arch'));
     writematrix(nn_info,strcat(strcat('./trained_nets/',name),'_arch'));
     
     writematrix(w_elements,strcat(strcat(path2env,name),'_weights'));
     writematrix(b_elements,strcat(strcat(path2env,name),'_bias'));
     
     writematrix(w_elements,strcat(strcat('./trained_nets/',name),'_weights'));
     writematrix(b_elements,strcat(strcat('./trained_nets/',name),'_bias'));
     
elseif(strcmp(flag,'store'))
     path2env = './trained_nets/';
     disp('writing into trained_nets env');

     writematrix(nn_info,strcat(strcat(path2env,name),'_arch'));
     
     writematrix(w_elements,strcat(strcat(path2env,name),'_weights'));
     writematrix(b_elements,strcat(strcat(path2env,name),'_bias'));
  
else
    disp('on valid flag')


end

