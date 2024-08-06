
pure double precision function ANN_hard_coded_pure(data_in,weight_1,weight_2,b_1,b_2,min_in,max_in,output_max_out,output_min_out)
double precision, dimension(5), intent(in) :: data_in
double precision, dimension(5) :: data_inputs
double precision, dimension(2,5),intent(in) :: weight_1
!= reshape(&
! (/-2.963!6306773E+00,8.286377955932387E-01,-5.958908843871094E-01,4.482852536611716E-01,1.051431615441095E-01/), shape(weight_1))
double precision, dimension(2),intent(in) :: weight_2
! = (/4.358950562324246E-02,4.198070576006356E-01 /)
double precision, dimension(2) :: x_hidden_1
double precision, dimension(2),intent(in) :: b_1
! = (/-7.354971883994940E+00,-8.483405189950064E+00/)
double precision,intent(in) :: b_2
!= -5.347006101653003E-01
! double precision :: beta
double precision, dimension(5),intent(in) :: min_in
! = (/1.0E-29,1.0E-29,2.73E+02,5.0E-08,5.0E-06/)
double precision, dimension(5),intent(in) :: max_in
! = (/1.E-13,1.0E-13,4.0E+03,5.0E-06,2.0E-04 /)
double precision,intent(in) :: output_max_out
! = 1.D-13
double precision,intent(in) :: output_min_out
! = 1.D-17
! double precision, dimension(2) :: x_hidden_2

! hard code values
! weight_1 = 0.75D0
! weight_2 = 1.2D0
! b_1 = 0.5D0
! b_2 = -0.25D0
! min_in = 1.D0
! ! max_out = 10.D0
! output_max_out = 1.D0
! output_min_out = -1.D0
! !input scaling

data_inputs = data_in
data_inputs(1) = -1.D0 + 2.D0*(log10(data_in(1)) - min_in(1))/(max_in(1) - min_in(1))
data_inputs(2) = -1.D0 + 2.D0*(log10(data_in(2)) - min_in(2))/(max_in(2) - min_in(2))
data_inputs(3) =  -1.D0+ 2.D0*(data_in(3) - min_in(3))/(max_in(3) - min_in(3))
data_inputs(4) =  -1.D0+ 2.D0*(data_in(4) - min_in(4))/(max_in(4) - min_in(4))
data_inputs(5) =  -1.D0+ 2.D0*(data_in(5) - min_in(5))/(max_in(5) - min_in(5))

! !LAYER 1
x_hidden_1 = matmul(weight_1, data_in)
x_hidden_1 = x_hidden_1 + b_1
x_hidden_1 = dtanh(x_hidden_1)
! !LAYER OUTPUT
ANN_hard_coded_pure = dot_product(weight_2, x_hidden_1)
ANN_hard_coded_pure = ANN_hard_coded_pure + b_2

ANN_hard_coded_pure = 0.5d0*(output_max_out-output_min_out) &
      *(ANN_hard_coded_pure+1.d0)+output_min_out

return

end function


