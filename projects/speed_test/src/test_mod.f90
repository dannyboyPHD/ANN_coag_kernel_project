module test_mod
implicit none
!---------------------------------
double precision, allocatable :: test_in(:,:), test_out(:),res(:)
integer :: N_inputs_tot  

!-------ANN PARAMS----------

! double precision, dimension(2,5) :: weight_1 = reshape(&
! (/-2.963633753009339E+00,-1.917269270652624E+00,6.079122866370408E-01,1.152769298396459E-01,-9.020021291046663E-01,&
! 3.408217996306773E+00,8.286377955932387E-01,-5.958908843871094E-01,4.482852536611716E-01,1.051431615441095E-01/), shape(weight_1))
! double precision, dimension(2) :: weight_2 = (/4.358950562324246E-02,4.198070576006356E-01 /)
! double precision, dimension(2) :: x_hidden_1
! double precision, dimension(2) :: b_1 = (/-7.354971883994940E+00,-8.483405189950064E+00/)
! double precision :: b_2 = -5.347006101653003E-01
! ! double precision :: beta
! double precision, dimension(5) :: min_in = (/1.0E-29,1.0E-29,2.73E+02,5.0E-08,5.0E-06/)
! double precision, dimension(5) :: max_in = (/1.E-13,1.0E-13,4.0E+03,5.0E-06,2.0E-04 /)
! double precision :: output_max_out = 1.D-13
! double precision :: output_min_out = 1.D-17
double precision :: b1 = 0.523598775598299d0
double precision :: pi             !< pi
    parameter (pi = 3.1415926535897932384d0)
double precision :: boltzmann      !< Boltzmann constant [J/K]
    parameter (boltzmann = 1.3806488d-23)
double precision :: coef(2,5)      !< Coefficients for enhancement factors [-]
    parameter (coef = reshape((/ 1.44126062412083d+00, -2.85433309497245d-01,  &
                                -1.26087336972727d-04, -1.56685886143385d-05,  &
                                -1.28580949927114d-01, -1.21424200844139d-01,  &
                                 4.84190814920071d+05,  3.54139071251940d+06,  &
                                 0.50000000000000d+00,  7.81269706389624d-02/),&
                                 (/2, 5/)))



contains
pure double precision function alCoagulationImperial_pure(params, v1, v2,pi,boltzmann,coef,b1)

  ! Modules
  ! <none>

  ! Header
  implicit none

  ! Declarations
  double precision, intent(in) :: params(3)
  double precision, intent(in) :: v1
  double precision, intent(in) :: v2

  ! Doubles
  double precision,intent(in) :: b1
  double precision :: b2,b1_dum         !< Temporary kernels [m^3/s]
  double precision :: d1, d2         !< Particle diameters [m]
  double precision :: d12            !< Sum of d1 and d2 [m]
  double precision :: Kn1, Kn2       !< Knudsen numbers [-]
  double precision :: W(2)           !< Enhancement factors [-]
  double precision,intent(in) :: pi             !< pi
  !   parameter (pi = 3.1415926535897932384d0)
  double precision, intent(in) :: boltzmann      !< Boltzmann constant [J/K]
  !   parameter (boltzmann = 1.3806488d-23)
  double precision, intent(in) :: coef(2,5)      !< Coefficients for enhancement factors [-]
  !   parameter (coef = reshape((/ 1.44126062412083d+00, -2.85433309497245d-01,  &
  !                               -1.26087336972727d-04, -1.56685886143385d-05,  &
  !                               -1.28580949927114d-01, -1.21424200844139d-01,  &
  !                                4.84190814920071d+05,  3.54139071251940d+06,  &
  !                                0.50000000000000d+00,  7.81269706389624d-02/),&
  !                                (/2, 5/)))

  !-----------------------------------------------------------------------------
  !
  ! Coagulation rate
  !
  !-----------------------------------------------------------------------------

  ! Collision diameters [m]
!   b1 = 0.523598775598299d0 ! = pi / 6
  d1 = exp(log(v1 / b1) / 3.0d0)
  d2 = exp(log(v2 / b1) / 3.0d0)
  d12 = d1 + d2

  ! Knudsen numbers [-]
  Kn1 = 2.0d0 * params(2) / d1
  Kn2 = 2.0d0 * params(2) / d2

  ! Enhancement factors [-]
  b1_dum = log(d1 / d2)
  W = 1.0d0 + (coef(:, 1) + coef(:, 2) * params(1)) * exp(coef(:, 3) * b1**2 + &
    coef(:, 5) * log(coef(:, 4) * d12 + 1.0d0))

  ! Collision frequency kinetic regime
  b1_dum = W(1) * sqrt(pi * boltzmann * params(1) / 2.0d0 / 2728.9d0) * &
    sqrt(1.0d0 / v1 + 1.0d0 / v2) * d12**2

  ! Collision frequency continuum regime
  Kn1 = 1.0d0 + (1.257d0 + 0.4d0 * exp(-1.1d0 / Kn1)) * Kn1
  Kn2 = 1.0d0 + (1.257d0 + 0.4d0 * exp(-1.1d0 / Kn2)) * Kn2
  b2 = W(2) * 2.0d0 / 3.0d0 * boltzmann * params(1) / params(3) * (Kn1 / d1 + &
    Kn2 / d2) * d12

  ! Harmonic average valid across the entire particle size range
  alCoagulationImperial_pure = b1 * b2 / (b1 + b2)

  return

end function alCoagulationImperial_pure
!------------------------------------------------------------------------------
!------------------------------------------------------------------------------
double precision function alCoagulationImperial(params, v1, v2)

  ! Modules
  ! <none>

  ! Header
  implicit none

  ! Declarations
  double precision, intent(in) :: params(3)
  double precision, intent(in) :: v1
  double precision, intent(in) :: v2

  ! Doubles
  double precision :: b1, b2         !< Temporary kernels [m^3/s]
  double precision :: d1, d2         !< Particle diameters [m]
  double precision :: d12            !< Sum of d1 and d2 [m]
  double precision :: Kn1, Kn2       !< Knudsen numbers [-]
  double precision :: W(2)           !< Enhancement factors [-]
  double precision :: pi             !< pi
    parameter (pi = 3.1415926535897932384d0)
  double precision :: boltzmann      !< Boltzmann constant [J/K]
    parameter (boltzmann = 1.3806488d-23)
  double precision :: coef(2,5)      !< Coefficients for enhancement factors [-]
    parameter (coef = reshape((/ 1.44126062412083d+00, -2.85433309497245d-01,  &
                                -1.26087336972727d-04, -1.56685886143385d-05,  &
                                -1.28580949927114d-01, -1.21424200844139d-01,  &
                                 4.84190814920071d+05,  3.54139071251940d+06,  &
                                 0.50000000000000d+00,  7.81269706389624d-02/),&
                                 (/2, 5/)))

  !-----------------------------------------------------------------------------
  !
  ! Coagulation rate
  !
  !-----------------------------------------------------------------------------

  ! Collision diameters [m]
  b1 = 0.523598775598299d0 ! = pi / 6
  d1 = exp(log(v1 / b1) / 3.0d0)
  d2 = exp(log(v2 / b1) / 3.0d0)
  d12 = d1 + d2

  ! Knudsen numbers [-]
  Kn1 = 2.0d0 * params(2) / d1
  Kn2 = 2.0d0 * params(2) / d2

  ! Enhancement factors [-]
  b1 = log(d1 / d2)
  W = 1.0d0 + (coef(:, 1) + coef(:, 2) * params(1)) * exp(coef(:, 3) * b1**2 + &
    coef(:, 5) * log(coef(:, 4) * d12 + 1.0d0))

  ! Collision frequency kinetic regime
  b1 = W(1) * sqrt(pi * boltzmann * params(1) / 2.0d0 / 2728.9d0) * &
    sqrt(1.0d0 / v1 + 1.0d0 / v2) * d12**2

  ! Collision frequency continuum regime
  Kn1 = 1.0d0 + (1.257d0 + 0.4d0 * exp(-1.1d0 / Kn1)) * Kn1
  Kn2 = 1.0d0 + (1.257d0 + 0.4d0 * exp(-1.1d0 / Kn2)) * Kn2
  b2 = W(2) * 2.0d0 / 3.0d0 * boltzmann * params(1) / params(3) * (Kn1 / d1 + &
    Kn2 / d2) * d12

  ! Harmonic average valid across the entire particle size range
  alCoagulationImperial = b1 * b2 / (b1 + b2)

  return

end function alCoagulationImperial
!---------------------------------------------------------------------------

!---------------------------------------------------------------------------
double precision function ANN_hard_coded(data_in)
! double precision, dimension(5), intent(in) :: data_in
double precision, dimension(5) :: data_in
double precision, dimension(2,5) :: weight_1
! = reshape(&
! (/-2.963633753009339E+00,-1.917269270652624E+00,6.079122866370408E-01,1.152769298396459E-01,-9.020021291046663E-01,&
! 3.408217996306773E+00,8.286377955932387E-01,-5.958908843871094E-01,4.482852536611716E-01,1.051431615441095E-01/), shape(weight_1))
double precision, dimension(2) :: weight_2 
! = (/4.358950562324246E-02,4.198070576006356E-01 /)
double precision, dimension(2) :: x_hidden_1
double precision, dimension(2) :: b_1 
! = (/-7.354971883994940E+00,-8.483405189950064E+00/)
double precision :: b_2 
! = -5.347006101653003E-01
double precision :: beta
double precision, dimension(5) :: min_in = (/1.0E-29,1.0E-29,2.73E+02,5.0E-08,5.0E-06/)
double precision, dimension(5) :: max_in = (/1.E-13,1.0E-13,4.0E+03,5.0E-06,2.0E-04 /)
double precision :: output_max_out = 1.D-13
double precision :: output_min_out = 1.D-17
double precision, dimension(2) :: x_hidden_2

! hard code values
weight_1 = 0.75D0
weight_2 = 1.2D0
b_1 = 0.5D0
b_2 = -0.25D0
! min_in = 1.D0
! max_out = 10.D0
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




end module
