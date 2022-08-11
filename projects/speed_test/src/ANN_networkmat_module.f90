! ANN simulation module (handles one MLP of any architecture)

module networkmat

implicit none

! One MLP only, with 'N_layers' layers, each with 'N_neu' neurons
! Each layer has neurons, inputs, outputs, total inputs, weights and biases
! outputs = act(total inputs) = act(weights*inputs + biases)
type layerStruct
  double precision, allocatable :: weights(:,:)
  double precision, allocatable :: bias(:)
  double precision, allocatable :: in(:)
  double precision, allocatable :: totin(:)
  double precision, allocatable :: out(:)
  integer :: N_neu
end type layerStruct

! Each MLP has a number of layers and weights
type mlpStruct
integer :: N_layers
integer :: N_weights
integer, allocatable :: which_in(:)
type(layerStruct), allocatable :: lay(:)
double precision, allocatable :: max_out(:), min_out(:)
end type mlpStruct

! Only one mlp
type(mlpStruct) :: mlp

integer :: N_inputs_tot                               ! Total number of inputs
double precision, allocatable :: max_in(:), min_in(:) ! Scaling parameters for each input

contains

  subroutine ann_init_mat

  implicit none

  integer :: k,l,m,offset
  integer :: tempwhich_in
  integer, allocatable :: temp(:)
  double precision, allocatable :: weightstemp(:)
  character(len=160) :: weightsfile

  ! Open network information file and read total number of inputs
  open(340,file='ann/ann_mlp.in')
  read(340,*)
  read(340,*)
  read(340,*) N_inputs_tot
  allocate(max_in(N_inputs_tot))
  allocate(min_in(N_inputs_tot))
  ! Read in max_in and min_in from input_scaling.in
  open(341,file='ann/input_scaling.in')
  read(341,*) max_in
  read(341,*) min_in
  close(341)
  ! Go back to reading network specific information
  read(340,*)
  read(340,*)
  ! Read in number of layers of each MLP
  read(340,*) mlp%N_layers
  allocate(mlp%lay(mlp%N_layers))
  allocate(temp(mlp%N_layers))
  ! Read in number of neurons in each layer of each MLP
  read(340,*) temp
  ! Set number of neurons in each layer of each MLP
  do l = 1,mlp%N_layers
    mlp%lay(l)%N_neu = temp(l)
  end do
  allocate(mlp%which_in(mlp%lay(1)%N_neu))
  ! Allocate matrices for each MLP
  do l = 1,mlp%N_layers-1  
    allocate(mlp%lay(l)%weights(temp(l+1),temp(l)))
    allocate(mlp%lay(l)%bias(temp(l+1))) 
    allocate(mlp%lay(l)%in(temp(l)))
    allocate(mlp%lay(l)%out(temp(l+1)))
    allocate(mlp%lay(l)%totin(temp(l+1)))
  end do
  ! Read in which inputs for each MLP
  read(340,*) tempwhich_in
  if (tempwhich_in==-1) then ! if -1 then take all inputs
    mlp%which_in = [(k,k=1,N_inputs_tot)]
  else ! otherwise read in which inputs
    backspace(340)
    read(340,*) mlp%which_in
  end if
  ! Read in min and max output scaling parameters for each MLP
  allocate(mlp%max_out(temp(mlp%N_layers)))
  allocate(mlp%min_out(temp(mlp%N_layers)))
  read(340,*) mlp%max_out
  read(340,*) mlp%min_out
  ! Calculate number of weights in each MLP
  mlp%N_weights = 0
  do l = 1,mlp%N_layers-1
    mlp%N_weights = mlp%N_weights + (temp(l)+1)*temp(l+1)
  end do
  deallocate(temp)
  allocate(weightstemp(mlp%N_weights))
  ! call random_number(weightstemp) 
  ! Read in MLP weights as a vector
  write(weightsfile,'(a)') 'ann/weights_mlp/trained.in'
  open(341,file=weightsfile)
  do k = 1,mlp%N_weights
    read(341,*) weightstemp(k)
  end do
  close(341) 
  ! Convert weights vector to matrices
  offset = 1
  do l = 1,mlp%N_layers-1
    k = mlp%lay(l)%N_neu
    do m = 1,mlp%lay(l+1)%N_neu
      mlp%lay(l)%weights(m,:) = weightstemp(offset+(m-1)*k:(offset-1)+m*k)
      mlp%lay(l)%bias(m) = weightstemp(offset+m*k)
      offset = offset + 1
    end do
    offset = offset + k*mlp%lay(l+1)%N_neu 
  end do
  deallocate(weightstemp)
  close(340)

  end subroutine ann_init_mat

  subroutine ann_sim(data_in,data_out,iflag)

  implicit none

  integer :: i,l
  integer, intent(out) :: iflag
  double precision, dimension(N_inputs_tot), intent(in) :: data_in
  double precision, intent(out) :: data_out
  double precision, dimension(N_inputs_tot) :: scale_in
  double precision :: scale_out
  double precision, allocatable :: temp_in(:)

  iflag = 0

  ! Scale all inputs
  do i = 1,N_inputs_tot
    if ((data_in(i)>max_in(i)).or.(data_in(i)<min_in(i))) then
      iflag = i
      return
    else 
      scale_in(i) = -1.d0 + 2.d0*(data_in(i)-min_in(i))/(max_in(i)-min_in(i))
    end if 
  end do

! Forward propagate and output unscaling
  ! Select the correct inputs
  allocate(temp_in(mlp%lay(1)%N_neu))
  temp_in = scale_in(mlp%which_in)
  do l = 1,mlp%N_layers-1
    ! Set inputs
    if (l.eq.1) then
      mlp%lay(l)%in = temp_in
      deallocate(temp_in)
    else
      mlp%lay(l)%in = mlp%lay(l-1)%out
    end if
    ! Calculate total input
    mlp%lay(l)%totin =  &
      matmul(mlp%lay(l)%weights,mlp%lay(l)%in) &
        + mlp%lay(l)%bias
    ! Calculate output
    if (l.ne.mlp%N_layers-1) then
      mlp%lay(l)%out = dtanh(mlp%lay(l)%totin)
    else
      mlp%lay(l)%out = mlp%lay(l)%totin
    end if
  end do
  ! Output unscaling
  scale_out = mlp%lay(mlp%N_layers-1)%out(1)
  data_out = 0.5d0*(mlp%max_out(1)-mlp%min_out(1)) &
      *(scale_out+1.d0)+mlp%min_out(1)

  end subroutine ann_sim

  subroutine ann_finish_mat

  implicit none

  deallocate(max_in,min_in)

  end subroutine

end module