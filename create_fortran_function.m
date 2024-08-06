function [f] = create_fortran_function(sub_name,input_names, input_sizes)

% args = strcat(input_names);
arg_line = input_names{1};
n_inputs = length(input_names);

for a = 2:n_inputs
 arg_line = strcat(arg_line,',',input_names{a});
end

%start routine
f = {"double precision function "+sub_name+"("+arg_line+")"};

% input variable declaration
f{end+1} = "! Input Variables";

for i = 1:n_inputs
   rows = input_sizes(i,1); columns = input_sizes(i,2);
   if columns == 1 % 1D array
       if rows == 1 % single number
           f{end+1} = "double precision, intent(in) :: "+input_names{i};
       else
           f{end+1} = "double precision, dimension("+num2str(rows)+"), intent(in) :: "+input_names{i};
       end
   else
        f{end+1} = "double precision, dimension("+num2str(rows)+","+num2str(columns)+"), intent(in) :: "+input_names{i};
   end 
end

% local variable comment
f{end+1} = "! local variables";

%main body
f{end+1} = "! main body";

% close function
f{end+1} = "end function";
end

