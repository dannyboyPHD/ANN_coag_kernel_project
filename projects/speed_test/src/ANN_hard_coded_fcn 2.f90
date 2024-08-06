double precision function ANN_hard_coded(data_in)
! double precision, dimension(5), intent(in) :: data_in
double precision, dimension(5) :: data_in
double precision, dimension(2,5) :: weight_1= reshape(&
 (/-2.963633753009339E+00,-1.917269270652624E+00,6.079122866370408E-01,1.152769298396459E-01,-9.020021291046663E-01,&
3.408217996306773E+00,8.286377955932387E-01,-5.958908843871094E-01,4.482852536611716E-01,1.051431615441095E-01/), shape(weight_1))
double precision, dimension(2) :: weight_2 = (/4.358950562324246E-02,4.198070576006356E-01 /)
double precision, dimension(2) :: x_hidden_1
double precision, dimension(2) :: b_1 = (/-7.354971883994940E+00,-8.483405189950064E+00/)
double precision :: b_2= -5.347006101653003E-01
double precision :: beta
double precision, dimension(5) :: min_in = (/1.0E-29,1.0E-29,2.73E+02,5.0E-08,5.0E-06/)
double precision, dimension(5) :: max_in = (/1.E-13,1.0E-13,4.0E+03,5.0E-06,2.0E-04 /)
double precision :: output_max_out = 1.D-13
double precision :: output_min_out = 1.D-17
double precision, dimension(2) :: x_hidden_2

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


data_in(1) = -1.D0 + 2.D0*(log10(data_in(1)) - log10(min_in(1)))/(log10(max_in(1)) - log10(min_in(1)))
data_in(2) = -1.D0 + 2.D0*(log10(data_in(2)) - log10(min_in(2)))/(log10(max_in(2)) - log10(min_in(2)))
data_in(3) =  -1.D0+ 2.D0*(data_in(3) - min_in(3))/(max_in(3) - min_in(3))
data_in(4) =  -1.D0+ 2.D0*(data_in(4) - min_in(4))/(max_in(4) - min_in(4))
data_in(5) =  -1.D0+ 2.D0*(data_in(5) - min_in(5))/(max_in(5) - min_in(5))

! !LAYER 1
x_hidden_1 = matmul(weight_1, data_in)
x_hidden_1 = x_hidden_1 + b_1
x_hidden_1 = dtanh(x_hidden_1)
! !LAYER OUTPUT
beta = dot_product(weight_2, x_hidden_1)
beta = beta + b_2

beta = 0.5d0*(output_max_out-output_min_out) &
      *(beta+1.d0)+output_min_out
ANN_hard_coded = beta
return

end function


