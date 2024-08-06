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
! double precision :: b1 = 0.523598775598299d0
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
elemental double precision function relu(x)
double precision, intent(in) :: x
if(x.ge.0.D0) then
relu = x
else
relu = 0.D0
end if 
return
end function


double precision function beta_ann(data_in)
! no_inputs = 6, [ v1, v2, T/vis, v1/mfp, v2/mfp,T ]
! no_outputs = 2, [beta_av, corr_factor]
! no_layers = 2, arch = [6],[12, 2]
double precision, dimension(6), intent(in) :: data_in
double precision, dimension(6) :: data_inputs
double precision, dimension(12,6) :: weight_ann_hc_pure_1=reshape((/ &
0.683947703706851,&
-0.584227321822418,&
0.370106464402196,&
-2.13699935938095e-29,&
0.418031782526364,&
0.140152633275425,&
-0.896669423125442,&
0.412573518177418,&
0.265539138652817,&
0.279395158891451,&
-0.379649242304127,&
-1.14873377673428,&
0.751236466354445,&
-0.646147312331225,&
-0.34658284152416,&
-9.45035533487232e-29,&
-0.282548598186665,&
-0.221439237840064,&
-0.916907679540119,&
0.430383839954701,&
0.279242907683664,&
0.290087359624933,&
0.212645488731479,&
-1.21699884112948,&
0.0586173081289307,&
0.452832398132738,&
0.00223609647573026,&
1.43711129576897e-28,&
0.00788987501987058,&
-0.000235612099993015,&
-0.51832174123033,&
0.00758232453339172,&
0.206911360516902,&
0.10389605032209,&
-0.0128940480361241,&
-0.15373188059247,&
-0.559227168115033,&
0.456254459654262,&
0.326200239734041,&
4.29618135608145e-29,&
0.363573106791419,&
0.179117863550231,&
0.783784605943439,&
-0.0460849145986368,&
-0.483772716579299,&
-0.392368601028422,&
-0.340280451338842,&
0.942801206408373,&
-0.529462375191061,&
0.430591807420611,&
-0.290257621656068,&
7.20496848335955e-29,&
-0.241002980317216,&
-0.132685268753267,&
0.809455218997602,&
-0.0430049657797159,&
-0.485132210536096,&
-0.395481218568916,&
0.170630609475265,&
0.933181726068436,&
-1.05431961898437e-05,&
-0.00327920154085667,&
-0.000347378179723216,&
-7.47592026553007e-29,&
-0.000331778799852811,&
-0.000295922610231993,&
0.00847984553731399,&
-0.00212809847666897,&
-0.00763893181081616,&
0.00631619300735946,&
0.000398159350837663,&
0.00783580945991119/),shape(weight_ann_hc_pure_1))
double precision, dimension(2,12) :: weight_ann_hc_pure_2=reshape((/ &
-0.0719710956517362,&
1.30440271612654,&
-0.0335302190047631,&
-1.3712731592151,&
0.674113936537917,&
-0.0115012377312724,&
7.70079200023622e-29,&
-2.2267000137735e-29,&
0.717884546224336,&
-0.0361312662098877,&
0.453248699500871,&
-0.0454745583912274,&
-0.0202135421288485,&
-2.07005035320887,&
-0.607171373544747,&
0.234149536861783,&
-0.0839964748291403,&
-0.834849272544102,&
0.0595034531500327,&
0.707303743820963,&
-0.609078778459772,&
0.0619283637253709,&
-0.0432384826628136,&
2.2568792220521/),shape(weight_ann_hc_pure_2))
double precision, dimension(12) :: b_ann_hc_pure_1= (/ &
-0.279240255439953,&
0.723917817482532,&
-0.0829371454111074,&
-1.38366973623772e-28,&
-0.268453803163448,&
-0.298564229168829,&
1.05158084365528,&
-0.25299898658261,&
0.208029820571454,&
0.142818399812165,&
0.201539451701207,&
0.715065783029571/)
double precision, dimension(2) :: b_ann_hc_pure_2= (/ &
-0.52022194301416,&
0.731599051789057/)
double precision, dimension(6) :: min_in=(/ log10(1e-29),&
log10(1e-29),&
10047551.6125148,&
log10(2.5488000925875e-24),&
log10(2.10601093458117e-24),&
2000.0/)
double precision, dimension(6) :: max_in=(/ log10(6e-18),&
log10(3e-18),&
796886585.002239,&
log10(1.14849012070595e-10),&
log10(5.40387367367813e-11),&
4000.0/)
double precision, dimension(2) :: output_min_out=(/ log10(1.29620372987691e-15),&
-0.983775313843295 /)
double precision, dimension(2) :: output_max_out=(/ log10(6.75552413335702e-09),&
16.748769915268/) 
double precision, dimension(12) :: x_hidden_1
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


!OUTPUT LAYER
beta_results = matmul(weight_ann_hc_pure_2, x_hidden_1)
beta_results = beta_results +b_ann_hc_pure_2
beta_results(1) = 0.5D0*(beta_results(1) + 1.D0)*(output_max_out(1) - output_min_out(1)) +output_min_out(1)
beta_results(1) = 10**beta_results(1)
beta_results(2) = 0.5D0*( beta_results(2)+ 1.D0)*(output_max_out(2) - output_min_out(2)) +output_min_out(2)
beta_ann = beta_results(2)*beta_results(1) + beta_results(1)
return
end function

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

! !---------------------------------------------------------------------------
! double precision function ANN_hard_coded(data_in)
! ! double precision, dimension(5), intent(in) :: data_in
! double precision, dimension(5) :: data_in
! double precision, dimension(2,5) :: weight_1
! ! = reshape(&
! ! (/-2.963633753009339E+00,-1.917269270652624E+00,6.079122866370408E-01,1.152769298396459E-01,-9.020021291046663E-01,&
! ! 3.408217996306773E+00,8.286377955932387E-01,-5.958908843871094E-01,4.482852536611716E-01,1.051431615441095E-01/), shape(weight_1))
! double precision, dimension(2) :: weight_2 
! ! = (/4.358950562324246E-02,4.198070576006356E-01 /)
! double precision, dimension(2) :: x_hidden_1
! double precision, dimension(2) :: b_1 
! ! = (/-7.354971883994940E+00,-8.483405189950064E+00/)
! double precision :: b_2 
! ! = -5.347006101653003E-01
! double precision :: beta
! double precision, dimension(5) :: min_in = (/1.0E-29,1.0E-29,2.73E+02,5.0E-08,5.0E-06/)
! double precision, dimension(5) :: max_in = (/1.E-13,1.0E-13,4.0E+03,5.0E-06,2.0E-04 /)
! double precision :: output_max_out = 1.D-13
! double precision :: output_min_out = 1.D-17
! double precision, dimension(2) :: x_hidden_2

! ! hard code values
! weight_1 = 0.75D0
! weight_2 = 1.2D0
! b_1 = 0.5D0
! b_2 = -0.25D0
! ! min_in = 1.D0
! ! max_out = 10.D0
! ! output_max_out = 1.D0
! ! output_min_out = -1.D0
! ! !input scaling
! data_in(1) = -1.D0 + 2.D0*(log10(data_in(1)) - log10(min_in(1)))/(log10(max_in(1)) - log10(min_in(1)))
! data_in(2) = -1.D0 + 2.D0*(log10(data_in(2)) - log10(min_in(2)))/(log10(max_in(2)) - log10(min_in(2)))
! data_in(3) =  -1.D0+ 2.D0*(data_i---------------------------------------------------
! double precision function ANN_hard_coded(data_in)
! ! double precision, dimension(5), intent(in) :: data_in
! double precision, dimension(5) :: data_in
! double precision, dimension(2,5) :: weight_1
! ! = reshape(&
! ! (/-2.963633753009339E+00,-1.917269270652624E+00,6.079122866370408E-01,1.152769298396459E-01,-9.020021291046663E-01,&
! ! 3.408217996306773E+00,8.286377955932387E-01,-5.958908843871094E-01,4.482852536611716E-01,1.051431615441095E-01/), shape(weight_1))
! double precision, dimension(2) :: weight_2 
! ! = (/4.358950562324246E-02,4.198070576006356E-01 /)
! double precision, dimension(2) :: x_hidden_1
! double precision, dimension(2) :: b_1 
! ! = (/-7.354971883994940E+00,-8.483405189950064E+00/)
! double precision :: b_2 
! ! = -5.347006101653003E-01
! double precision :: beta
! double precision, dimension(5) :: min_in = (/1.0E-29,1.0E-29,2.73E+02,5.0E-08,5.0E-06/)
! double precision, dimension(5) :: max_in = (/1.E-13,1.0E-13,4.0E+03,5.0E-06,2.0E-04 /)
! double precision :: output_max_out = 1.D-13
! double precision :: output_min_out = 1.D-17
! double precision, dimension(2) :: x_hidden_2

! ! hard code values
! weight_1 = 0.75D0
! weight_2 = 1.2D0
! ANN_hard_coded = beta
! return

! end function



! pure double precision function ANN_hard_coded_pure(data_in,weight_1,weight_2,b_1,b_2,min_in,max_in,output_max_out,output_min_out)
! double precision, dimension(5), intent(in) :: data_in
! double precision, dimension(5) :: data_inputs
! double precision, dimension(2,5),intent(in) :: weight_1
! != reshape(&
! ! (/-2.963!6306773E+00,8.286377955932387E-01,-5.958908843871094E-01,4.482852536611716E-01,1.051431615441095E-01/), shape(weight_1))
! double precision, dimension(2),intent(in) :: weight_2
! ! = (/4.358950562324246E-02,4.198070576006356E-01 /)
! double precision, dimension(2) :: x_hidden_1
! double precision, dimension(2),intent(in) :: b_1
! ! = (/-7.354971883994940E+00,-8.483405189950064E+00/)
! double precision,intent(in) :: b_2
! != -5.347006101653003E-01
! ! double precision :: beta
! double precision, dimension(5),intent(in) :: min_in
! ! = (/1.0E-29,1.0E-29,2.73E+02,5.0E-08,5.0E-06/)
! double precision, dimension(5),intent(in) :: max_in
! ! = (/1.E-13,1.0E-13,4.0E+03,5.0E-06,2.0E-04 /)
! double precision,intent(in) :: output_max_out
! ! = 1.D-13
! double precision,intent(in) :: output_min_out
! ! = 1.D-17
! ! double precision, dimension(2) :: x_hidden_2

! ! hard code values
! ! weight_1 = 0.75D0
! ! weight_2 = 1.2D0
! ! b_1 = 0.5D0
! ! b_2 = -0.25D0
! ! min_in = 1.D0
! ! ! max_out = 10.D0
! ! output_max_out = 1.D0
! ! output_min_out = -1.D0
! ! !input scaling

! data_inputs = data_in
! data_inputs(1) = -1.D0 + 2.D0*(log10(data_in(1)) - min_in(1))/(max_in(1) - min_in(1))
! data_inputs(2) = -1.D0 + 2.D0*(log10(data_in(2)) - min_in(2))/(max_in(2) - min_in(2))
! data_inputs(3) =  -1.D0+ 2.D0*(data_in(3) - min_in(3))/(max_in(3) - min_in(3))
! data_inputs(4) =  -1.D0+ 2.D0*(data_in(4) - min_in(4))/(max_in(4) - min_in(4))
! data_inputs(5) =  -1.D0+ 2.D0*(data_in(5) - min_in(5))/(max_in(5) - min_in(5))

! ! !LAYER 1
! x_hidden_1 = matmul(weight_1, data_in)
! x_hidden_1 = x_hidden_1 + b_1
! x_hidden_1 = dtanh(x_hidden_1)
! ! !LAYER OUTPUT
! ANN_hard_coded_pure = dot_product(weight_2, x_hidden_1)
! ANN_hard_coded_pure = ANN_hard_coded_pure + b_2

! ANN_hard_coded_pure = 0.5d0*(output_max_out-output_min_out) &
!       *(ANN_hard_coded_pure+1.d0)+output_min_out

! return

! ! end function
! pure double precision function ann_hc_pure(data_in,min_in,max_in,output_max_out,output_min_out,weight_1,b_1,weight_2,b_2)
! double precision, dimension(5), intent(in) :: data_in
! double precision, dimension(5) :: data_inputs
! double precision, dimension(8,5), intent(in) :: weight_1
! double precision, dimension(8), intent(in) :: weight_2
! double precision, dimension(8), intent(in) :: b_1
! double precision, intent(in) :: b_2
! double precision, dimension(5) ,intent(in) :: min_in
! double precision, dimension(5) ,intent(in) :: max_in
! double precision,intent(in) :: output_max_out
! double precision,intent(in) :: output_min_out
! double precision, dimension(8) :: x_hidden_1


! data_inputs(1) = -1.D0 + 2.D0*(log10(data_in(1)) - min_in(1))/(max_in(1) - min_in(1))
! data_inputs(2) = -1.D0 + 2.D0*(log10(data_in(2)) - min_in(2))/(max_in(2) - min_in(2))
! data_inputs(3) =  -1.D0+ 2.D0*(data_in(3) - min_in(3))/(max_in(3) - min_in(3))
! data_inputs(4) =  -1.D0+ 2.D0*(data_in(4) - min_in(4))/(max_in(4) - min_in(4))
! data_inputs(5) =  -1.D0+ 2.D0*(data_in(5) - min_in(5))/(max_in(5) - min_in(5))
! !LAYER 1
! x_hidden_1 = matmul(weight_1, data_in)
! x_hidden_1 = x_hidden_1+b_1
! x_hidden_1 = dtanh(x_hidden_1)


! ! !OUTPUT LAYER
! ann_hc_pure = dot_product(weight_2, x_hidden_1)
! ann_hc_pure = ann_hc_pure+b_2
! ann_hc_pure = 0.5D0*(ann_hc_pure + 1.D0)*(output_max_out - output_min_out) +output_min_out
! ann_hc_pure = 10**ann_hc_pure
! end function


! pure double precision function ann_hc_pure1(data_in,min_in,max_in,output_max_out,output_min_out,weight_1,b_1,weight_2,b_2)
! double precision, dimension(5), intent(in) :: data_in
! double precision, dimension(5) :: data_inputs
! double precision, dimension(10,5), intent(in) :: weight_1
! double precision, dimension(10), intent(in) :: weight_2
! double precision, dimension(10), intent(in) :: b_1
! double precision, intent(in) :: b_2
! double precision, dimension(5) ,intent(in) :: min_in
! double precision, dimension(5) ,intent(in) :: max_in
! double precision,intent(in) :: output_max_out
! double precision,intent(in) :: output_min_out
! double precision, dimension(10) :: x_hidden_1
! integer(kind=1) :: i,j


! data_inputs(1) = -1.D0 + 2.D0*(log10(data_in(1)) - min_in(1))/(max_in(1) - min_in(1))
! data_inputs(2) = -1.D0 + 2.D0*(log10(data_in(2)) - min_in(2))/(max_in(2) - min_in(2))
! data_inputs(3) =  -1.D0+ 2.D0*(data_in(3) - min_in(3))/(max_in(3) - min_in(3))
! data_inputs(4) =  -1.D0+ 2.D0*(data_in(4) - min_in(4))/(max_in(4) - min_in(4))
! data_inputs(5) =  -1.D0+ 2.D0*(data_in(5) - min_in(5))/(max_in(5) - min_in(5))
! !LAYER 1
! x_hidden_1 = matmul(weight_1, data_in)
! ! forall(i = 1:10, j=1:5)
! !         x_hidden_1(i) = x_hidden_1(i) + weight_1(i,j)*data_inputs(j) 
! ! !         ! weight_1(i,1:5)*data_inputs(1:5) 
! ! end forall
! ! forall( i=1:10)
! !   x_hidden_1(i) =x_hidden_1(i) + b_1(i)
! ! end forall
! x_hidden_1 = x_hidden_1+b_1

! ! x_hidden_1 = dtanh(x_hidden_1)
! x_hidden_1 = pow_approx(x_hidden_1)


! !OUTPUT LAYER
! forall(i = 1:10)
! ! ann_hc_pure = dot_product(weight_2, x_hidden_1)
! ann_hc_pure1 = ann_hc_pure1 + weight_2(i)*x_hidden_1(i) 
! end forall
! ann_hc_pure1 = ann_hc_pure1+b_2
! ann_hc_pure1 = 0.5D0*(ann_hc_pure1 + 1.D0)*(output_max_out - output_min_out) +output_min_out
! ! ann_hc_pure = 10.D0**ann_hc_pure
! ann_hc_pure1= pow_approx(ann_hc_pure1)
! return
! end function

! pure elemental double precision function pow_approx(x)
! double precision, intent(in) :: x


! pow_approx = x - 0.3333*x*x*x + (2.d0/15.D0)*x*x*x*x*x

! return
! end function

end module
