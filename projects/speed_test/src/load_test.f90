! Simulate trained MLPs on some test data, record time and result


subroutine load_test_data()

  use test_mod

  implicit none

  integer :: i,N_data,iflag
  logical :: exists
  character(len=5)frmt

  ! call ann_init_mat

  ! Prepare formatting
  write(frmt,118) 2
118 format(I4)

  ! Read in test data
  ! inquire(file='testdata.dat',exist=exists)
  ! if (.not.exists) then
  !   write(*,*) 'File not found -> testdata.dat'
  !   stop
  ! end if
  open(110,file='./input_files/no_samples.in')
  read(110,*) N_data
  open(111,file='./input_files/testdata.dat')

  write(*,*) 'N_data',N_data
  allocate(test_in(N_data,N_inputs_tot))
  allocate(test_out(N_data))

  do i = 1,N_data !N_data
    read(111,*) test_in(i,:),test_out(i)
  end do

  ! call cpu_time(time1)
  ! do i = 1,N_data
  !   call ann_sim(test_in(1,:),res(1),iflag)
  ! end do
  ! call cpu_time(time2)
  close(111)
 

  ! deallocate(test_in,test_out,res)

  ! call ann_finish_mat

  ! time = time2-time1
  write(*,*) 'test data loaded in'
  ! write(*,*) test_in(1,:),test_out(1)

end subroutine load_test_data