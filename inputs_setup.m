
[min_max, param_names, scaling_type] = ui_inputs_scaling(name,V_or_D,no_params);


function [min_max, param_names, scaling_type] = ui_inputs_scaling(name,V_or_D,no_params)
% create fig
fig = uifigure;
gl = uigridlayout(fig,[3+no_params,4]);
row_widths = {}
for i = [1:3+no_params]
    row_widths{end+1} = 'fit';
end
gl.RowHeight = row_widths;
% gl.ColumnWidth = {'1x','1x','1x'};

name_title = uilabel(gl); name_title.Layout.Row = 1; name_title.Layout.Column = 1;
name_title.Text = 'Input Name';

min_title = uilabel(gl); min_title.Layout.Row = 1; min_title.Layout.Column = 2;
min_title.Text = 'min';

max_title = uilabel(gl); max_title.Layout.Row = 1; max_title.Layout.Column = 3;
max_title.Text = 'max';

scaling_title = uilabel(gl); scaling_title.Layout.Row = 1; scaling_title.Layout.Column = 4;
scaling_title.Text = 'scaling type';

%volume or diameter names (hard coded)
vd1 = uilabel(gl); vd1.Layout.Row = 2; vd1.Layout.Column = 1;vd1.Interpreter = 'latex';
vd2 = uilabel(gl); vd2.Layout.Row = 3; vd2.Layout.Column = 1;vd2.Interpreter = 'latex';

if strcmp(V_or_D, 'volume')
    vd1.Text = '$V_1$'; vd2.Text = '$V_2$';
elseif strcmp(V_or_D, 'diameter')
     vd1.Text = 'd_1'; vd2.Text = 'd_2';
end

names = {};
mins  = {};
maxes = {};
scalings = {};
%names textboxes
for i = [1:no_params]
    names{i} = uieditfield(gl,'text');
    names{i}.Layout.Row = i+3;
    names{i}.Layout.Column = 1;
end

%min input boxes
for i = [1:2+no_params]
    mins{i} = uieditfield(gl,'numeric');
    mins{i}.Layout.Row = i+1;
    mins{i}.Layout.Column = 2;
end

%max input boxes
for i = [1:2+no_params]
    maxes{i} = uieditfield(gl,'numeric');
    maxes{i}.Layout.Row = i+1;
    maxes{i}.Layout.Column = 3;
end

% scaling input boxes
for i = [1:2+no_params]
    scalings{i} = uidropdown(gl);
    scalings{i}.Layout.Row = i+1;
    scalings{i}.Layout.Column = 4;
    scalings{i}.Items = {'linear','log'};
end

%menu for save
menu = uimenu(fig);
menu.Text = 'save data';
menu.MenuSelectedFcn = @menu_save;


min_max = zeros(2+no_params,2);
param_names = {};
scaling_type = {};
i = 0;
uiwait(fig);
function menu_save(~,event)
    %save names 
  for i = [1:2+no_params]
     min_max(i,1) = mins{i}.Value;
     min_max(i,2) = maxes{i}.Value;
     scaling_type{i} = scalings{i}.Value;
  end
     param_names{1} = vd1.Text;
     param_names{2} = vd2.Text;
     for i = [3:1:no_params+2]
         disp(i);
        param_names{i} = names{i-2}.Value;
        
     end

     close(fig);
     
       
  end
end

    



