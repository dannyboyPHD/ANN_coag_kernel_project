function [g] = declare_local_fortran(f,var_name,var_size)
i = find(strcmp([f{:}],"! local variables"));

   rows = var_size(1); columns = var_size(2);
   if columns == 1 % 1D array
       if rows == 1 % single number
           line = "double precision :: "+var_name;
       else
           line = "double precision, dimension("+num2str(rows)+") :: "+var_name;
       end
   else
        line = "double precision, dimension("+num2str(rows)+","+num2str(columns)+") :: "+var_name;
   end 

g = {f{1:i},line,f{i+1:end}};
end

