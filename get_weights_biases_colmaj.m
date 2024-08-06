function [w_elements,b_elements] = get_weights_biases_colmaj(in_net,L)

    total_w_elements = 0;
    total_b_elements = 0;
    
    
        if(L ==1)
            total_w_elements = total_w_elements + ...
                size(in_net.IW{1},1)*size(in_net.IW{1},2);
            
            total_b_elements = total_b_elements +...
                size(in_net.b{1},1);
        else
            total_w_elements = total_w_elements + ...
                size(in_net.LW{L},1)*size(in_net.LW{L,L-1},2);
            
            total_b_elements = total_b_elements +...
                size(in_net.b{L},1); 
        end
   
    
    disp(total_w_elements)
    disp(total_b_elements)
    
    w_elements = zeros(total_w_elements,1);
    b_elements = zeros(total_b_elements,1);
    
    cntr_w = 1;
    cntr_b = 1;
 
    if(L ==1)
          off_w = size(in_net.IW{1},1)*size(in_net.IW{1},2) - 1;
          % stored column major check reshape docs
          w_elements(cntr_w:cntr_w+off_w) = reshape(in_net.IW{1}(:,:),[off_w+1,1]);
          cntr_w = cntr_w + off_w +1;
          
          off_b = size(in_net.b{1},1) -1;
          b_elements(cntr_b:cntr_b+off_b) = in_net.b{1}(:);
          cntr_b = cntr_b + off_b+1;
          
    else
            off_w = size(in_net.LW{L,L-1},1)*size(in_net.LW{L,L-1},2) -1;
            % col major
            w_elements(cntr_w:cntr_w+off_w) = reshape(in_net.LW{L,L-1}(:,:),[off_w+1,1]);
            cntr_w = cntr_w + off_w +1;
            
            off_b = size(in_net.b{L},1)-1;
            b_elements(cntr_b:cntr_b+off_b) = in_net.b{L}(:);
            cntr_b = cntr_b + off_b +1 ;
    end
 
end
