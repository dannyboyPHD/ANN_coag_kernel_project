from ann_src_writer import*


def read_in_net(net_file):
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