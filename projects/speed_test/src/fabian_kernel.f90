!-------------------------------------------------------------------------------
!
!> \brief Evaluate the coagulation rate [m^3/s]
!
!> \note The parameter array PARAMS contains the temperature T [K] as well as
!> the mean free path of the gas mixture l [m] and the viscosity of the gas
!> mixture mu [Ns/m^2]. The values typically lie in the following intervals.
!>
!> T in [273, 4000]
!> l in [5e-8, 1.5e-6]
!> mu in [5e-6, 2e-4]
!
!> \author Jannis Finke
!> \date 20/06/2022
!
! INPUT
!> \param[in]   PARAMS            Temperature [K], Mean free path of gas mixture
!>                                [m] and viscosity of gas mixture [Ns/m^2]
!> \param[in]   V1                Volume of parent particle 1 [m^3]
!> \param[in]   V2                Volume of parent particle 2 [m^3]
!
! OUTPUT
!> \param[out]  ALCOAGULATIONIMPERIAL  Coagulation rate [m^3/s]
!
!-------------------------------------------------------------------------------

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