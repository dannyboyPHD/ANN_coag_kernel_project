function [f] = declare_local_array_fortran(f,var_name,var_size,values,fmt)
%assume values if flattened array colmaj

i = find(strcmp([f{:}],"! local variables"));

   rows = var_size(1); columns = var_size(2);

   if rows == 1 && columns == 1 % 1D array
        line = "double precision :: "+var_name;
        line = line +"= &";
   elseif columns == 1 % 1D array
        line = "double precision, dimension("+num2str(rows)+"):: "+var_name;
        line = line +"=(/&";
   elseif rows == 1 % 1D array
        line = "double precision, dimension("+num2str(columns)+"):: "+var_name;
        line = line +"=(/&";
   else
        line = "double precision, dimension("+num2str(rows)+","+num2str(columns)+") :: "+var_name;
        line = line +"=reshape((/&";
   end
   
   f = {f{1:i},line,f{i+1:end}};
   i = i+1;
   
   for j = 1:length(values)
        if j == length(values)
            if columns == 1 && rows ==1
                end_line = "";
            elseif columns == 1 || rows ==1
                end_line = "/)";
            else
                end_line = "/),shape("+var_name+"))";
            end
        else
            end_line = ",&";
        end
        f = {f{1:i},{num2str(values(j),fmt)+end_line},f{i+1:end}};
        i = i+1;
   end
end

