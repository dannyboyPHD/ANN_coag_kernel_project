
from ann_src_writer import*

def read_in_net(net_file):
    #key variables
    outscaling = 'lin' #log, lin
    inscaling = 'lin' #log lin


    f = open('./input_files/'+net_file+'.txt','r')
    net_name = f.readline().strip('\n')
    fcn_name = f.readline().strip('\n')
    f.close()

    print('loading net: ',net_name, 'as ',fcn_name)

    #get no inputs to NN
    f = open('./input_files/'+net_name+'_arch.txt')
    no_inputs = int(f.readline())
    no_layers = int(f.readline())

    arch =[]

    for l in range(no_layers):
        arch.append(int(f.readline()))

    f.close()
    #initiate and fill weights and biases as list of lists w[layer_no][row][col], b[layer_no][row]
    weights = []
    bias = []

    # fill weights and bias from relevant input files 
    f = open('./input_files/'+net_name+'_weights.txt','r')
    g = open('./input_files/'+net_name+'_bias.txt','r')

    for i in range(no_layers):

        n_rows = arch[i]

        if i ==0:
            n_cols = no_inputs
        else:
            n_cols = arch[i-1]
  
        w = [[ float(f.readline()) for _ in range(n_cols)] for z in range(n_rows)]
        b = [float(g.readline()) for _ in range(n_rows)]
        weights.append(w)
        bias.append(b)
    
    f.close()
    g.close()

    print(weights[0][0][:])

    weight_label = []
    bias_label = []

    for i in range(no_layers):
        weight_label.append('weight_'+fcn_name+'_'+str(i+1))
        bias_label.append('b_'+fcn_name+'_'+str(i+1))
    return weight_label, weights, bias_label,bias,no_inputs,no_layers,arch

def write_weights_declaration(f,weights, weight_label,no_layers):
    for _ in range(no_layers-1):
        # print('no_rows in ',len(weights[_][:]))
        # print('no_col in ',len(weights[_][0][:]))
        n_rows = len(weights[_][:])
        n_cols = len(weights[_][0][:])
        f.write('double precision, dimension('+str(n_rows)+','+str(n_cols)+') :: '+weight_label[_]+'\n')

    n_rows = len(weights[no_layers-1][:])
    n_cols = len(weights[no_layers-1][0][:])
    print(n_cols)
    if n_rows == 1:
        f.write('double precision, dimension('+str(n_cols)+') :: '+weight_label[no_layers-1]+'\n')
    else:
        f.write('double precision, dimension('+str(n_rows)+','+str(n_cols)+') :: '+weight_label[no_layers-1]+'\n')

def write_bias_declaration(f,bias,bias_label,no_layers):
     for _ in range(no_layers):
        n_rows = len(bias[_][:])
        print(n_rows)
        if n_rows == 1:
            f.write('double precision :: '+bias_label[_]+'\n')
        else:
            f.write('double precision, dimension('+str(n_rows)+') :: '+bias_label[_]+'\n')
        
def write_pure_fcn(f,fcn_name,weight_label,bias_label,no_inputs,no_layers,arch,scaling,act):

    f.write(first_line(fcn_name,weight_label,bias_label,no_layers))
    # f.write('double precison, dimension('+str(no_inputs)+'), intent(in) :: data_in\n')
    f.write(douprec_dim_in(str(no_inputs),'data_in'))
    f.write(douprec_dim_dummy(str(no_inputs),'data_inputs'))

    #weights
    for _ in range(no_layers):
        if _ ==0:
            dim = str(arch[0])+','+str(no_inputs)
        elif _ == no_layers -1:
            if arch[no_layers -1] == 1:
                dim = str(arch[_ -1])
            else:
                dim = str(arch[_])+','+str(arch[_ -1])
        else:
            dim = str(arch[_])+','+str(arch[_ -1])
       
        f.write(douprec_dim_in(dim,weight_label[_]))
    #bias
    for _ in range(no_layers):
        dim = str(arch[_])
        f.write(douprec_dim_in(dim,bias_label[_]))

    f.write('double precision, dimension('+str(no_inputs)+') ,intent(in) :: min_in\n')
    f.write('double precision, dimension('+str(no_inputs)+') ,intent(in) :: max_in\n')
    if arch[-1] == 1:
        f.write('double precision,intent(in) :: output_max_out\n')
        f.write('double precision,intent(in) :: output_min_out\n')
    else:
        douprec_dim_in(str(arch[-1]),'output_max_out')
        f.write(douprec_dim_in(dim,'output_max_out'))
        f.write(douprec_dim_in(dim,'output_min_out'))


    #hidden layer vectors
    for _ in range(no_layers -1):
        dim = str(arch[_])
        f.write(douprec_dim_dummy(dim,'x_hidden_'+str(_+1)))

    if arch[-1] > 1:
        f.write(douprec_dim_dummy(str(arch[no_layers -1]),'beta_results'))
        

    f.write('\n')
    f.write('\n')

    
# input scaling def. by scaling list, can be log or linear
    for _ in range(no_inputs):
        if scaling[_] == 'lin':
            f.write('data_inputs('+str(_+1)+') =  -1.D0+ 2.D0*(data_in('+str(_+1)+') - min_in('+str(_+1)+'))/(max_in('+str(_+1)+') - min_in('+str(_+1)+'))\n')
        elif scaling[_] == 'log':
             f.write('data_inputs('+str(_+1)+') =  -1.D0+ 2.D0*(log10(data_in('+str(_+1)+')) - min_in('+str(_+1)+'))/(max_in('+str(_+1)+') - min_in('+str(_+1)+'))\n')

# application of layers, act_fcn(wx + b)
    for _ in range(no_layers - 1):
        if _ == 0:
            f.write('!LAYER '+str(_+1)+'\n')
            f.write('x_hidden_'+str(_+1)+' = matmul('+weight_label[_]+', data_inputs)\n')
        else:
            f.write('!LAYER '+str(_+1)+'\n')
            f.write('x_hidden_'+str(_+1)+' = matmul('+weight_label[_]+','+ 'x_hidden_'+str(_)+')\n')
        
        f.write('x_hidden_'+str(_+1)+' = x_hidden_'+str(_+1)+'+'+bias_label[_]+'\n')

        if act == 'tanh':
            f.write('x_hidden_'+str(_+1)+' = dtanh(x_hidden_'+str(_+1)+')\n')
        elif act == 'relu':
            f.write('x_hidden_'+str(_+1)+' = relu(x_hidden_'+str(_+1)+')\n')





    #output layer hc for 1 output
    f.write('\n')
    f.write('\n')
    f.write('!OUTPUT LAYER\n')


    if arch[no_layers-1] == 1:

        f.write(fcn_name+' = dot_product('+weight_label[no_layers-1]+', x_hidden_'+str(no_layers-1)+')\n')
        f.write(fcn_name+' = '+fcn_name+'+'+bias_label[no_layers-1]+'\n')

        if scaling[-1] == 'lin':
            f.write(fcn_name+' = 0.5D0*('+fcn_name+' + 1.D0)*(output_max_out - output_min_out) +output_min_out\n')
        elif scaling[-1] == 'log':
            f.write(fcn_name+' = 0.5D0*('+fcn_name+' + 1.D0)*(output_max_out - output_min_out) +output_min_out\n')
            f.write(fcn_name+' = 10**'+fcn_name+'\n')
    else:

        f.write('beta_results = matmul('+weight_label[no_layers-1]+', x_hidden_'+str(no_layers-1)+')\n')
        f.write('beta_results = beta_results +'+bias_label[no_layers-1]+'\n')
        
        for _ in range(arch[no_layers-1]):
            if scaling[no_inputs + _] == 'lin':
                f.write('beta_results('+str(_+1)+') = 0.5D0*( beta_results('+str(_+1)+')+ 1.D0)*(output_max_out('+str(_+1)+') - output_min_out('+str(_+1)+')) +output_min_out('+str(_+1)+')\n')
            elif scaling[no_inputs + _] == 'log':
                f.write('beta_results('+str(_+1)+') = 0.5D0*(beta_results('+str(_+1)+') + 1.D0)*(output_max_out('+str(_+1)+') - output_min_out('+str(_+1)+')) +output_min_out('+str(_+1)+')\n')
                f.write('beta_results('+str(_+1)+') = 10**beta_results('+str(_+1)+')\n')
        #output reassembling         
        f.write(fcn_name+' = beta_results(2)*beta_results(1) + beta_results(1)\n')
        f.write('return\n')
   
    f.write('end function\n')

def write_combined_net_fcn(f,fcn_name,weight_label1,bias_label1,no_inputs1,no_layers1,arch1,\
    weight_label2,bias_label2,no_inputs2,no_layers2,arch2):

    f.write(first_line_combined(fcn_name,weight_label1,bias_label1,no_layers1, weight_label2,bias_label2,no_layers2))
    # f.write('double precison, dimension('+str(no_inputs)+'), intent(in) :: data_in\n')
    f.write(douprec_dim_in(str(no_inputs2),'data_in'))
    f.write(douprec_dim_dummy(str(no_inputs2),'data_inputs'))

    #weights
    for _ in range(no_layers1):
        if _ ==0:
            dim = str(arch1[0])+','+str(no_inputs1)
        elif _ == no_layers1 -1:
            dim = str(arch1[_ -1])
        else:
            dim = str(arch1[_])+','+str(arch1[_ -1])
       
        f.write(douprec_dim_in(dim,weight_label1[_]))
    #bias
    for _ in range(no_layers1):
        dim = str(arch1[_])
        f.write(douprec_dim_in(dim,bias_label1[_]))

    #weights
    for _ in range(no_layers2):
        if _ ==0:
            dim = str(arch2[0])+','+str(no_inputs2)
        elif _ == no_layers2 -1:
            dim = str(arch2[_ -1])
        else:
            dim = str(arch2[_])+','+str(arch2[_ -1])
       
        f.write(douprec_dim_in(dim,weight_label2[_]))
    #bias
    for _ in range(no_layers2):
        dim = str(arch2[_])
        f.write(douprec_dim_in(dim,bias_label2[_]))

    

    f.write('double precision, dimension('+str(no_inputs2)+') ,intent(in) :: min_in\n')
    f.write('double precision, dimension('+str(no_inputs2)+') ,intent(in) :: max_in\n')
    f.write('double precision,intent(in) :: output_max_out\n')
    f.write('double precision,intent(in) :: output_min_out\n')
    f.write('double precision :: b1\n')
    f.write('double precision :: b2\n')

    #hidden layer vectors
    for _ in range(no_layers1 -1):
        dim = str(arch1[_])
        f.write(douprec_dim_dummy(dim,'x_hidden1_'+str(_+1)))

    for _ in range(no_layers2 -1):
        dim = str(arch2[_])
        f.write(douprec_dim_dummy(dim,'x_hidden2_'+str(_+1)))

    f.write('\n')
    f.write('\n')

    #scaling this is hard coded and wont scle with difficult number of inputs - beta1 vs beta2
    
    f.write('data_inputs(1) = -1.D0 + 2.D0*(log10(data_in(1)) - min_in(1))/(max_in(1) - min_in(1))\n')
    f.write('data_inputs(2) = -1.D0 + 2.D0*(log10(data_in(2)) - min_in(2))/(max_in(2) - min_in(2))\n')
    f.write('data_inputs(3) =  -1.D0+ 2.D0*(data_in(3) - min_in(3))/(max_in(3) - min_in(3))\n')
    f.write('data_inputs(4) =  -1.D0+ 2.D0*(data_in(4) - min_in(4))/(max_in(4) - min_in(4))\n')
    f.write('data_inputs(5) =  -1.D0+ 2.D0*(data_in(5) - min_in(5))/(max_in(5) - min_in(5))\n')

    for _ in range(no_layers1 - 1):
        if _ == 0:
            f.write('!LAYER '+str(_+1)+'\n')
            f.write('x_hidden1_'+str(_+1)+' = matmul('+weight_label1[_]+', data_in(1:3))\n')
        else:
            f.write('!LAYER '+str(_+1)+'\n')
            f.write('x_hidden1_'+str(_+1)+' = matmul('+weight_label1[_]+','+ 'x_hidden1_'+str(_)+')\n')
        
        f.write('x_hidden1_'+str(_+1)+' = x_hidden1_'+str(_+1)+'+'+bias_label1[_]+'\n')

        f.write('x_hidden1_'+str(_+1)+' = dtanh(x_hidden1_'+str(_+1)+')\n')

    for _ in range(no_layers2 - 1):
        if _ == 0:
            f.write('!LAYER '+str(_+1)+'\n')
            f.write('x_hidden2_'+str(_+1)+' = matmul('+weight_label2[_]+', data_in)\n')
        else:
            f.write('!LAYER '+str(_+1)+'\n')
            f.write('x_hidden2_'+str(_+1)+' = matmul('+weight_label2[_]+','+ 'x_hidden2_'+str(_)+')\n')
        
        f.write('x_hidden2_'+str(_+1)+' = x_hidden2_'+str(_+1)+'+'+bias_label2[_]+'\n')

        f.write('x_hidden2_'+str(_+1)+' = dtanh(x_hidden2_'+str(_+1)+')\n')



    #output layer hc for 1 output
    f.write('\n')
    f.write('\n')
    f.write('!OUTPUT LAYER\n')

    f.write('b1 = dot_product('+weight_label1[no_layers1-1]+', x_hidden1_'+str(no_layers1-1)+')\n')
    f.write('b1 = b1+'+bias_label1[no_layers1-1]+'\n')

    #switch to linear out put scaling
    f.write('b1 = 0.5D0*(b1 + 1.D0)*(output_max_out - output_min_out) +output_min_out\n')
    f.write('b1 = 10**b1\n')

    f.write('b2 = dot_product('+weight_label2[no_layers2-1]+', x_hidden_'+str(no_layers2-1)+')\n')
    f.write('b2 = b1+'+bias_label2[no_layers2-1]+'\n')
    

    #switch to linear out put scaling
    f.write('b2 = 0.5D0*(b2 + 1.D0)*(output_max_out - output_min_out) +output_min_out\n')
    f.write('b2 = 10**b2\n')
    f.write(fcn_name+' = (b1*b2)/(b1+b2)\n')
    
    f.write('end function\n')





def write_loading_subroutine(f,name,weight_label,bias_label,no_layers,arch):

    f.write('subroutine load_weights_bias4'+name+'(file_name)\n')
    f.write('character(len=100) :: file_name,f1,f2,f3\n')
    f.write('integer :: n_layers,n_inputs, i,j,off\n')
    f.write('\n')
    f.write("f1 = trim(file_name)//'_arch.txt'\n")
    f.write('open(unit=88,file=f1)\n')
    f.write('read(88,*) n_inputs\n')
    f.write('read(88,*) n_layers\n')
    f.write('close(88)\n')
    f.write('\n')
    f.write("f2 = trim(file_name)//'_weights.txt'\n")
    f.write('open(unit=88,file=f2)\n')
    for _ in range(no_layers-1):
        f.write('do i = 1,size('+weight_label[_]+',1)\n')
        f.write('do j = 1,size('+weight_label[_]+',2)\n')
        f.write('read(88,*) '+weight_label[_]+'(i,j)\n')
        f.write('off = off +1\n')
        f.write('end do\n')
        f.write('end do\n')


    f.write('! FINAL LAYER\n')
    if arch[-1] >1:
        _ = no_layers-1
        f.write('do i = 1,size('+weight_label[_]+',1)\n')
        f.write('do j = 1,size('+weight_label[_]+',2)\n')
        f.write('read(88,*) '+weight_label[_]+'(i,j)\n')
        f.write('off = off +1\n')
        f.write('end do\n')
        f.write('end do\n')

        f.write('close(88)\n')
        f.write('\n')
        
        f.write('! biases\n')
        f.write("f3 = trim(file_name)//'_bias.txt'\n")
        f.write('open(unit=88,file=f3)\n')
        for _ in range(no_layers):
            f.write('do i = 1,size('+bias_label[_]+')\n')
            f.write('read(88,*) '+bias_label[_]+'(i)\n')
            f.write('end do\n')
        
    else:
    
        
        f.write('! biases\n')
        f.write("f3 = trim(file_name)//'_bias.txt'\n")
        f.write('open(unit=88,file=f3)\n')
        for _ in range(no_layers-1):
            f.write('do i = 1,size('+bias_label[_]+')\n')
            f.write('read(88,*) '+bias_label[_]+'(i)\n')
            f.write('end do\n')

        f.write('read(88,*) '+bias_label[no_layers-1]+'\n')

        # f.write('read(88,*) '+bias_label[no_layers-1]+'\n')

    f.write('close(88)\n')


    f.write('end subroutine\n')


#=================================================================
#=================================================================
def write_ReLu(f):
    f.write('elemental double precision function relu(x)\n')
    f.write('double precision, intent(in) :: x\n')
    f.write('if(x.ge.0.D0) then\n')
    f.write('relu = x\n')
    f.write('else\n')
    f.write('relu = 0.D0\n')
    f.write('end if \n')
    f.write('return\n')
    f.write('end function\n')

def load_scaling_params(f,arch,no_in,scaling):
    f.write('subroutine load_scaling(file_name)\n')
    f.write('character(len=100) :: file_name,f1,f2,f3\n')
    f.write('integer :: i,j\n')
    f.write('\n')
    f.write("f1 = trim(file_name)//'_scaling_params.txt'\n")

    f.write('open(unit=88,file=f1)\n')
    for _ in range(no_in):
        if scaling[_] == 'lin':
            f.write('read(88,*) min_in('+str(_+1)+'),max_in('+str(_+1)+')\n')
        elif scaling[_] == 'log':
            f.write('read(88,*) min_in('+str(_+1)+'),max_in('+str(_+1)+')\n')
            f.write('min_in('+str(_+1)+') = log10(min_in('+str(_+1)+'))\n')
            f.write('max_in('+str(_+1)+') = log10(max_in('+str(_+1)+'))\n')
  

    
    for _ in range(arch[-1]):
        if scaling[no_in+_] == 'lin':
            f.write('read(88,*) output_min_out('+str(_+1)+'),output_max_out('+str(_+1)+')\n')
        elif scaling[no_in+_] == 'log':
            f.write('read(88,*) output_min_out('+str(_+1)+'),output_max_out('+str(_+1)+')\n')
            f.write('output_min_out('+str(_+1)+') = log10(output_min_out('+str(_+1)+'))\n')
            f.write('output_max_out('+str(_+1)+') = log10(output_max_out('+str(_+1)+'))\n')
     
    f.write('close(88)\n')
    f.write('end subroutine\n')


with open('test.txt','w') as f:

    f.write('module ann_coag\n')
    f.write('implicit none\n')

    w_l,w,b_l,b,no_in,no_lay,arch = read_in_net('net_name')
    write_weights_declaration(f,w,w_l,no_lay)
    write_bias_declaration(f,b,b_l,no_lay)

    f.write('double precision, dimension('+str(no_in)+') :: min_in\n')
    f.write('double precision, dimension('+str(no_in)+') :: max_in\n')
    f.write('double precision, dimension('+str(arch[-1])+') :: output_max_out\n')
    f.write('double precision, dimension('+str(arch[-1])+') :: output_min_out\n')

    # w2_l,w2,b2_l,b2,no_in2,no_lay2,arch2 = read_in_net('net_name2')
    # write_weights_declaration(f,w2,w2_l,no_lay2)
    # write_bias_declaration(f,b2_l,b2_l,no_lay2)

    f.write('contains \n')
    f.write('\n')
    write_ReLu(f)
    f.write('\n')
    f.write('\n')

    # write_combined_net_fcn(f,'beta',w_l,b_l,no_in,no_lay,arch,\
    # w2_l,b2_l,no_in2,no_lay2,arch2)
    #6 inputs, 2 outputs
    scaling = ['log','log','lin','log','log','lin','log','lin']
    act = 'relu'
    write_pure_fcn(f,'beta_2out',w_l,b_l,no_in,no_lay,arch,scaling,act)

    f.write('\n')
    write_loading_subroutine(f,'beta_2out',w_l,b_l,no_lay,arch)
    # write_loading_subroutine(f,'b2',w2_l,b2_l,no_lay2)
    load_scaling_params(f,arch,no_in,scaling)
   
    f.write('\n')
    f.write('end module')














