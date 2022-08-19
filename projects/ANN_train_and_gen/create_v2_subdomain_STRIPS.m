function [v1_min,v1_max,v2_min,v2_max] = create_v2_subdomain_STRIPS(mode)
if(strcmp(mode,'all'))
    v1_min = 1*10^-29;
    v1_max = 6*10^-18;
    
    v2_min = 1*10^-29;
    v2_max = 6*10^-18/2;
    
elseif(strcmp(mode,'a'))
    v1_min = 1*10^-29;
    v1_max = 5.8*10^-27;
 
    v2_min = 1*10^-29; % v min 
    v2_max = 3.5*10^-29;
    
elseif(strcmp(mode,'b'))
    v1_min = 10^-29;
    v1_max = 1.5*10^-13;
 
    v2_min = 1*10^-29; % v min 
    v2_max = 3.5*10^-29;
elseif(strcmp(mode,'c'))
    v1_min = 6*10^-25;
    v1_max = 1*10^-13;
 
    v2_min = 3*10^-29; % v min 
    v2_max = 1*10^-14;
elseif(strcmp(mode,'d'))
    v1_min = 5*10^-29;
    v1_max = 6*10^-13;
    
    v2_min = 5*10^-29;
    v2_max = 1*10^-27;
elseif(strcmp(mode,'e'))
    v1_min = 1*10^-27;
    v1_max = 6*10^-13;
    
    v2_min = 1*10^-27;
    v2_max = 1*10^-26;
elseif(strcmp(mode,'f'))
    v1_min = 1*10^-26;
    v1_max = 6*10^-18.;
    
    v2_min = 1*10^-26;
    v2_max = 6*10^-18;  % v max
    
    
    
    
end

end

