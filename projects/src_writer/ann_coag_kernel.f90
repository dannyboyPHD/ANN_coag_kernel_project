pure double precision function ann_hc_pure(data_in,min_in,max_in,outpu&
&t_max_out,output_min_out,weight_1,b_1,weight_2,b_2,weight_3,b_3,weight_4,b_4)
double precision, dimension(5), intent(in) :: data_in
double precision, dimension(5) :: data_inputs
double precision, dimension(2,5), intent(in) :: weight_1
double precision, dimension(2,2), intent(in) :: weight_2
double precision, dimension(2,2), intent(in) :: weight_3
double precision, dimension(2), intent(in) :: weight_4
double precision, dimension(2), intent(in) :: b_1
double precision, dimension(2), intent(in) :: b_2
double precision, dimension(2), intent(in) :: b_3
double precision, intent(in) :: b_4
double precision, dimension(5) ,intent(in) :: min_in
double precision, dimension(5) ,intent(in) :: max_in
double precision,intent(in) :: output_max_out
double precision,intent(in) :: output_min_out
double precision, dimension(2) :: x_hidden_1
double precision, dimension(2) :: x_hidden_2
double precision, dimension(2) :: x_hidden_3


data_inputs(1) = -1.D0 + 2.D0*(log10(data_in(1)) - min_in(1))/(max_in(1) - min_in(1))
data_inputs(2) = -1.D0 + 2.D0*(log10(data_in(2)) - min_in(2))/(max_in(2) - min_in(2))
data_inputs(3) =  -1.D0+ 2.D0*(data_in(3) - min_in(3))/(max_in(3) - min_in(3))
data_inputs(4) =  -1.D0+ 2.D0*(data_in(4) - min_in(4))/(max_in(4) - min_in(4))
data_inputs(5) =  -1.D0+ 2.D0*(data_in(5) - min_in(5))/(max_in(5) - min_in(5))
!LAYER 1
x_hidden_1 = matmul(weight_1, data_in)
x_hidden_1 = x_hidden_1+b_1
x_hidden_1 = dtanh(x_hidden_1)
!LAYER 2
x_hidden_2 = matmul(weight_2,x_hidden_1)
x_hidden_2 = x_hidden_2+b_2
x_hidden_2 = dtanh(x_hidden_2)
!LAYER 3
x_hidden_3 = matmul(weight_3,x_hidden_2)
x_hidden_3 = x_hidden_3+b_3
x_hidden_3 = dtanh(x_hidden_3)


!OUTPUT LAYER
ann_hc_pure = dot_product(weight_4, x_hidden_3)
ann_hc_pure = ann_hc_pure+b_4
ann_hc_pure = 0.5D0*(ann_hc_pure + 1.D0)*(output_max_out - output_min_out) +output_min_out
ann_hc_pure = 10**ann_hc_pure
end function