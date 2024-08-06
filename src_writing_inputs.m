[Language,scaling_implement, matmul_implement] =  src_writing_setup(network,activation_fun);


function [L,scaling_imp, matmul_imp] = src_writing_setup(net_in,actfcn)
gl_rows = 5;
% create fig
fig = uifigure;
gl = uigridlayout(fig,[gl_rows,2]);

row_widths = {};

for i = [1:gl_rows]
    row_widths{end+1} = 'fit';
end

Language_title = uilabel(gl); Language_title.Layout.Row = 1; Language_title.Layout.Column = 1;
Language_title.Text = 'Language';

Languages_dd = uidropdown(gl);
Languages_dd.Layout.Row = 1;
Languages_dd.Layout.Column = 2;
Languages_dd.Items = {'fortran','C'};

Net_title = uilabel(gl); Net_title.Layout.Row = 2; Net_title.Layout.Column = 1;
Net_title.Text = 'Net';

Net_label = uilabel(gl); Net_label.Layout.Row = 2; Net_label.Layout.Column = 2;
Net_label.Text = net_in.name;

ActFun_title = uilabel(gl); ActFun_title.Layout.Row = 3; ActFun_title.Layout.Column = 1;
ActFun_title.Text = 'Activation Function';

Act_label = uilabel(gl); Act_label.Layout.Row = 3; Act_label.Layout.Column = 2;
Act_label.Text = actfcn;

scaling_title = uilabel(gl); scaling_title.Layout.Row = 4; scaling_title.Layout.Column = 1;
scaling_title.Text = 'Scaling implementation';

scaling_impl_dd = uidropdown(gl);
scaling_impl_dd.Layout.Row = 4;
scaling_impl_dd.Layout.Column = 2;
scaling_impl_dd.Items = {'intrinsics','truncated Taylor series'};

matrix_title = uilabel(gl); matrix_title.Layout.Row = 5; matrix_title.Layout.Column = 1;
matrix_title.Text = 'Matrix Multiplication Implementation';

matrix_dd = uidropdown(gl);
matrix_dd.Layout.Row = 5;
matrix_dd.Layout.Column = 2;
matrix_dd.Items = {'matmul','unrolled loops'};







% menu for save
menu = uimenu(fig);
menu.Text = 'save data';
menu.MenuSelectedFcn = @menu_save;

uiwait(fig);
function menu_save(~,event)
    %save names 
     L = Languages_dd.Value;
     scaling_imp = scaling_impl_dd.Value;
     matmul_imp = matrix_dd.Value;

     close(fig);
     
       
  end
end

    