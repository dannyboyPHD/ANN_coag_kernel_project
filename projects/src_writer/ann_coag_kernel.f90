pure double precision function ann_hc_pure(data_in,min_in,max_in,output_max_out,output_min_out,weight_1,b_1,weight_2,b_2)
double precision, dimension(5), intent(in) :: data_in
double precision, dimension(5) :: data_inputs
double precision, dimension(8,5), intent(in) :: weight_1
double precision, dimension(8), intent(in) :: weight_2
double precision, dimension(8), intent(in) :: b_1
double precision, intent(in) :: b_2
double precision, dimension(5) ,intent(in) :: min_in
double precision, dimension(5) ,intent(in) :: max_in
double precision,intent(in) :: output_max_out
double precision,intent(in) :: output_min_out
double precision, dimension(8) :: x_hidden_1


data_inputs(1) = -1.D0 + 2.D0*(log10(data_in(1)) - min_in(1))/(max_in(1) - min_in(1))
data_inputs(2) = -1.D0 + 2.D0*(log10(data_in(2)) - min_in(2))/(max_in(2) - min_in(2))
data_inputs(3) =  -1.D0+ 2.D0*(data_in(3) - min_in(3))/(max_in(3) - min_in(3))
data_inputs(4) =  -1.D0+ 2.D0*(data_in(4) - min_in(4))/(max_in(4) - min_in(4))
data_inputs(5) =  -1.D0+ 2.D0*(data_in(5) - min_in(5))/(max_in(5) - min_in(5))
!LAYER 1
x_hidden_1 = matmul(weight_1, data_in)
x_hidden_1 = x_hidden_1+b_1
x_hidden_1 = dtanh(x_hidden_1)


!OUTPUT LAYER
ann_hc_pure = dot_product(weight_2, x_hidden_1)
ann_hc_pure = ann_hc_pure+b_2
ann_hc_pure = 0.5D0*(ann_hc_pure + 1.D0)*(output_max_out - output_min_out) +output_min_out
ann_hc_pure = 10**ann_hc_pure
end function