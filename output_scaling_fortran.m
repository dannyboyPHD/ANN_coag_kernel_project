function [f] = output_scaling_fortran(f,start_point,fcn_name,x,mm_name,min_max,scaling_type)
i = find(strcmp([f{:}],start_point));
n_inputs = size(min_max,1);

f = {f{1:i},"! output scaling - start",f{i+1:end}};
i = i+1;


    if strcmp(scaling_type{1},'linear')
        a = "";
        b = "";
    elseif strcmp(scaling_type{1},'log')
        a = "10**(";
        b = ")";
    elseif strcmp(scaling_type{1},'ln')
        a = "exp(";
        b = ")";
    end

    out_max = mm_name+"(2)";
    out_min = mm_name+"(1)";

   line = x+"= 0.5D0*("+x+"+1.D0)*("+out_max+"-"+out_min+") + "+out_min;
   
   f = {f{1:i},line,f{i+1:end}};
   i=i+1;
   
   % for single output case 
   % to do mulitple outputs
   line = fcn_name+" = "+a+x+b;
   f = {f{1:i},line,f{i+1:end}};
   i=i+1;
   


f = {f{1:i},"! output scaling - end",f{i+1:end}};

line = "return";
   f = {f{1:i},line,f{i+1:end}};



end

