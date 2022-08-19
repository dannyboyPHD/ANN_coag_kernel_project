program test_in
use ann_weights_bias
implicit none

character(len = 100) :: f = 'input_files/ann_dom_all_5:6:1'


call load_weights_bias(f)






! contains 

! subroutine load_weights(file_name)
! character(len=100) :: file_name,f1,f2,f3
! integer:: n_layers, n_inputs,i,j,off

! f1 = trim(file_name)//'_arch.txt'
! open(unit=88,file = f1)
!     read(88,*) n_inputs
!     read(88,*) n_layers 
! close(88)

! f2 = trim(file_name)//'_weights.txt'

! open(unit=88,file = f2)
!     do i = 1,size(weight_1,1)
!         do j = 1,size(weight_1,2)
!             read(88,*) weight_1(i,j) 
!             off = off +1
!         end do
!     end do

! ! final layer
!     do i = 1,size(weight_2,1)
!         read(88,*) weight_2(i)
!     end do
! close(88)

! ! write(*,*) weight_2

! f3 = trim(file_name)//'_bias.txt'
! open(unit=88, file = f3)
!     do i = 1,size(b_1)
!         read(88,*) b_1(i)
!     end do

!     ! final layer
!     read(88,*) b_2
! close(88)

! write(*,*) b_1
! write(*,*) b_2

! end subroutine
end program