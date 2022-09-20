program speed_test
use test_mod
use ann_coag
implicit none
integer :: i,j,k
double precision :: v1,v2
double precision, dimension(3) :: params
integer(8) :: clock0            !< Start of time measurement
integer(8) :: clock1            !< End of time measurement
integer(8) :: clockMax          !< Clock tick granularity
double precision :: clockRate   !< Number of clock ticks per second
double precision, allocatable :: data_in(:,:)
double precision :: s



! !----- ANN pure
! double precision, dimension(8,5) :: weight_1
! ! = reshape(&
! ! (/-2.963633753009339E+00,-1.917269270652624E+00,6.079122866370408E-01,1.152769298396459E-01,-9.020021291046663E-01,&
! ! 3.408217996306773E+00,8.286377955932387E-01,-5.958908843871094E-01,4.482852536611716E-01,1.051431615441095E-01/), shape(weight_1))
! double precision, dimension(8) :: weight_2
! double precision, dimension(10) :: weight_3
! double precision, dimension(2) :: weight_4
! !  = (/4.358950562324246E-02,4.198070576006356E-01 /)
! double precision :: b_2
! double precision, dimension(8) :: b_1
! ! double precision, dimension(10) :: b_2
! ! double precision, dimension(2) :: b_3
! double precision :: b_3
! double precision :: b_4
! = (/-7.354971883994940E+00,-8.483405189950064E+00/)
! double precision :: b_2
! = -5.347006101653003E-01
double precision, dimension(6) :: min_in= (/log10(1.0E-29),log10(1.0E-29),1.0038E7,log10(3.0732E-24),log10(2.0298E-24),2.0E3/)
double precision, dimension(6) :: max_in = (/log10(6.E-18),log10(3.0E-18),7.9811E8,log10(1.1515E-10),log10(5.276E-11),4.0E3 /)
double precision, dimension(2) :: output_max_out= (/ log10(6.851E-9), 1.94950E1/)
double precision, dimension(2) :: output_min_out= (/log10(1.2902E-15), -9.836E-1 /)
character(len=100) :: f = 'input_files/beta_comb_relu_all_6:20:20:2'
! weight_1 = 1.D0
! weight_2 = 1.D0
! weight_3 = 1.D0
! weight_4 = 1.D0
! b_1 = 0.4d0
! b_2 = -0.25D0
! b_3 = 0.4d0
! b_4 = -0.25D0


call load_weights_bias4beta_2out(f)

N_inputs_tot = 5
call load_test_data
allocate(res(size(test_out)))
allocate(data_in(size(test_out),6))
! order particle volumes
data_in(:,1:2) = test_in(:,1:2)
do i = 1,size(test_out)
    if(data_in(i,1).gt.data_in(i,2)) then

    else
        s = data_in(i,1)
        data_in(i,1) = data_in(i,2)
        data_in(i,2) = s
    end if 
    
    data_in(i,3) = test_in(i,3)/test_in(i,5) ! T/viscosity

    data_in(i,4) = data_in(i,1)/data_in(i,4) ! v/mfp
    data_in(i,5) = data_in(i,2)/data_in(i,4) ! v2/mfp
    data_in(i,6) = test_in(i,3) ! T

end do





call system_clock(clock0, clockRate, clockMax)
do k= 1,100
    do i =1,size(test_out)
        v1 = test_in(i,1)
        v2 = test_in(i,2)
        params(:) = test_in(i,3:5)
        test_out(i) = alCoagulationImperial(params, v1, v2)
        ! res(i) = alCoagulationImperial_pure(params, v1, v2,pi,boltzmann,coef,b1)
        ! res(i) = ANN_hard_coded(test_in(i,:))
        ! res(i) = ANN_hard_coded_pure(test_in(i,:),weight_1,weight_2,b_1,b_2,min_in,max_in,output_max_out,output_min_out)
        ! res(i) = ann_hc_pure(test_in(i,:),min_in,max_in,output_max_out,output_min_out&
        ! &,weight_1,b_1,weight_2,b_2)

        res(i) = beta_2out(data_in,min_in,max_in,output_&
&max_out,output_min_out,weight_ann_hc_pure_1,b_ann_hc_pure_1,weight_ann_hc_pure_2,b_ann_hc_pure_2)



    end do
end do
call system_clock(clock1, clockRate, clockMax)

write(*,*) 'time taken: ', dble(clock1 - clock0) / clockRate


open(112,file='res.dat')
do i = 1,size(test_out)
    write(112,*) test_out(i),res(i)
end do
close(112)




deallocate(test_in,test_out)




end program

