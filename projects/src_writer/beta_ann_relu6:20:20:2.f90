module ann_coag
implicit none
double precision, dimension(20,6) :: weight_ann_hc_pure_1
double precision, dimension(20,20) :: weight_ann_hc_pure_2
double precision, dimension(2,20) :: weight_ann_hc_pure_3
double precision, dimension(20) :: b_ann_hc_pure_1
double precision, dimension(20) :: b_ann_hc_pure_2
double precision, dimension(2) :: b_ann_hc_pure_3
double precision, dimension(6) :: min_in
double precision, dimension(6) :: max_in
double precision, dimension(2) :: output_max_out
double precision, dimension(2) :: output_min_out
contains 

elemental double precision function relu(x)
double precision, intent(in) :: x
if(x.ge.0.D0) then
relu = x
else
relu = 0.D0
end if 
return
end function


pure double precision function beta_2out(data_in,min_in,max_in,output_&
&max_out,output_min_out,weight_ann_hc_pure_1,b_ann_hc_pure_1,weight_ann_hc_pure_2,b_ann_hc_pure_2,weight_ann_hc_pure_3,b_ann_hc_pure_3)
double precision, dimension(6), intent(in) :: data_in
double precision, dimension(6) :: data_inputs
double precision, dimension(20,6), intent(in) :: weight_ann_hc_pure_1
double precision, dimension(20,20), intent(in) :: weight_ann_hc_pure_2
double precision, dimension(2,20), intent(in) :: weight_ann_hc_pure_3
double precision, dimension(20), intent(in) :: b_ann_hc_pure_1
double precision, dimension(20), intent(in) :: b_ann_hc_pure_2
double precision, dimension(2), intent(in) :: b_ann_hc_pure_3
double precision, dimension(6) ,intent(in) :: min_in
double precision, dimension(6) ,intent(in) :: max_in
double precision, dimension(2), intent(in) :: output_max_out
double precision, dimension(2), intent(in) :: output_min_out
double precision, dimension(20) :: x_hidden_1
double precision, dimension(20) :: x_hidden_2
double precision, dimension(2) :: beta_results


data_inputs(1) =  -1.D0+ 2.D0*(log10(data_in(1)) - min_in(1))/(max_in(1) - min_in(1))
data_inputs(2) =  -1.D0+ 2.D0*(log10(data_in(2)) - min_in(2))/(max_in(2) - min_in(2))
data_inputs(3) =  -1.D0+ 2.D0*(data_in(3) - min_in(3))/(max_in(3) - min_in(3))
data_inputs(4) =  -1.D0+ 2.D0*(log10(data_in(4)) - min_in(4))/(max_in(4) - min_in(4))
data_inputs(5) =  -1.D0+ 2.D0*(log10(data_in(5)) - min_in(5))/(max_in(5) - min_in(5))
data_inputs(6) =  -1.D0+ 2.D0*(data_in(6) - min_in(6))/(max_in(6) - min_in(6))
!LAYER 1
x_hidden_1 = matmul(weight_ann_hc_pure_1, data_inputs)
x_hidden_1 = x_hidden_1+b_ann_hc_pure_1
x_hidden_1 = relu(x_hidden_1)
!LAYER 2
x_hidden_2 = matmul(weight_ann_hc_pure_2,x_hidden_1)
x_hidden_2 = x_hidden_2+b_ann_hc_pure_2
x_hidden_2 = relu(x_hidden_2)


!OUTPUT LAYER
beta_results = matmul(weight_ann_hc_pure_3, x_hidden_2)
beta_results = beta_results +b_ann_hc_pure_3
beta_results(1) = 0.5D0*(beta_results(1) + 1.D0)*(output_max_out(1) - output_min_out(1)) +output_min_out(1)
beta_results(1) = 10**beta_results(1)
beta_results(2) = 0.5D0*( beta_results(2)+ 1.D0)*(output_max_out(2) - output_min_out(2)) +output_min_out(2)
beta_2out = beta_results(2)*beta_results(1) + beta_results(1)
return
end function

subroutine load_weights_bias4beta_2out(file_name)
character(len=100) :: file_name,f1,f2,f3
integer :: n_layers,n_inputs, i,j,off

f1 = trim(file_name)//'_arch.txt'
open(unit=88,file=f1)
read(88,*) n_inputs
read(88,*) n_layers
close(88)

f2 = trim(file_name)//'_weights.txt'
open(unit=88,file=f2)
do i = 1,size(weight_ann_hc_pure_1,1)
do j = 1,size(weight_ann_hc_pure_1,2)
read(88,*) weight_ann_hc_pure_1(i,j)
off = off +1
end do
end do
do i = 1,size(weight_ann_hc_pure_2,1)
do j = 1,size(weight_ann_hc_pure_2,2)
read(88,*) weight_ann_hc_pure_2(i,j)
off = off +1
end do
end do
! FINAL LAYER
do i = 1,size(weight_ann_hc_pure_3,1)
do j = 1,size(weight_ann_hc_pure_3,2)
read(88,*) weight_ann_hc_pure_3(i,j)
off = off +1
end do
end do
close(88)

! biases
f3 = trim(file_name)//'_bias.txt'
open(unit=88,file=f3)
do i = 1,size(b_ann_hc_pure_1)
read(88,*) b_ann_hc_pure_1(i)
end do
do i = 1,size(b_ann_hc_pure_2)
read(88,*) b_ann_hc_pure_2(i)
end do
do i = 1,size(b_ann_hc_pure_3)
read(88,*) b_ann_hc_pure_3(i)
end do
close(88)
end subroutine
subroutine load_scaling(file_name)
character(len=100) :: file_name,f1,f2,f3
integer :: i,j

f1 = trim(file_name)//'_scaling_params.txt'
open(unit=88,file=f1)
read(88,*) min_in(1),max_in(1)
min_in(1) = log10(min_in(1))
max_in(1) = log10(max_in(1))
read(88,*) min_in(2),max_in(2)
min_in(2) = log10(min_in(2))
max_in(2) = log10(max_in(2))
read(88,*) min_in(3),max_in(3)
read(88,*) min_in(4),max_in(4)
min_in(4) = log10(min_in(4))
max_in(4) = log10(max_in(4))
read(88,*) min_in(5),max_in(5)
min_in(5) = log10(min_in(5))
max_in(5) = log10(max_in(5))
read(88,*) min_in(6),max_in(6)
read(88,*) output_min_out(1),output_max_out(1)
output_min_out(1) = log10(output_min_out(1))
output_max_out(1) = log10(output_max_out(1))
read(88,*) output_min_out(2),output_max_out(2)
close(88)
end subroutine

end module