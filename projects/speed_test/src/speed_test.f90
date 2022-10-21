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
double precision :: s,err

! double precision, dimension(6) :: min_in= (/log10(1.0E-29),log10(1.0E-29),1.008666641639102E+07,&
! &                                           log10(2.965046918551264E-24),log10(2.043573318742417E-24),2.0E3/)

! double precision, dimension(6) :: max_in = (/log10(6.E-18),log10(3.0E-18),7.976974777473704E+08,&
! &                                           log10(1.149182144837694e-10),log10(4.695329873548609e-11),4.0E3 /)

! double precision, dimension(2) :: output_max_out= (/ log10(6.864598034203446E-09), 1.7681926484592953E1/)
! double precision, dimension(2) :: output_min_out= (/log10(1.291248315591270E-15), -9.83811724070242E-1 /)

character(len=100) :: f = 'input_files/beta_comb_relu_all_6:12:2'

call load_weights_bias4beta_2out(f)
call load_scaling(f)

N_inputs_tot = 5

call load_test_data

allocate(res(size(test_out)))
allocate(data_in(size(test_out),6))


! order particle volumes - although aggregation map, seems to obey this ordering
! as only v_max/2 is considered in v2 when counting combinations

data_in(:,1:2) = test_in(:,1:2)

do i = 1,size(test_out)
    if(data_in(i,1).gt.data_in(i,2)) then

    else
        s = data_in(i,1)
        data_in(i,1) = data_in(i,2)
        data_in(i,2) = s
    end if 
    
    data_in(i,3) = test_in(i,3)/test_in(i,5) ! T/viscosity

    data_in(i,4) = data_in(i,1)/test_in(i,4) ! v1/mfp
    data_in(i,5) = data_in(i,2)/test_in(i,4) ! v2/mfp
    data_in(i,6) = test_in(i,3) ! T

end do

write(*,*) data_in(1,:)
read(*,*)



call system_clock(clock0, clockRate, clockMax)
do k= 1,100
    do i =1,size(test_out)

! v1 = test_in(i,1)
! v2 = test_in(i,2)
! params(:) = test_in(i,3:5)
!------ UNCOMMENT FOR EXACT TIMING COMPARISON ---------    
        
        ! res(i) = alCoagulationImperial(test_in(i,3:5),test_in(i,1), test_in(i,2))
       
!--------------------------------------------------------
        ! res(i) = alCoagulationImperial_pure(params, v1, v2,pi,boltzmann,coef,b1)
        ! res(i) = alCoagulationImperial_pure(params, v1, v2,pi,boltzmann,coef,b1)
        ! res(i) = ANN_hard_coded(test_in(i,:))
        ! res(i) = ANN_hard_coded_pure(test_in(i,:),weight_1,weight_2,b_1,b_2,min_in,max_in,output_max_out,output_min_out)
        ! res(i) = ann_hc_pure(test_in(i,:),min_in,max_in,output_max_out,output_min_out&
        ! &,weight_1,b_1,weight_2,b_2)


! 2 LAYER
!         res(i) = beta_2out(data_in(i,:),min_in,max_in,output_&
! &max_out,output_min_out,weight_ann_hc_pure_1,b_ann_hc_pure_1&
! &,weight_ann_hc_pure_2,b_ann_hc_pure_2,weight_ann_hc_pure_3,b_ann_hc_pure_3)

! 1 LAYER
            res(i) = beta_2out(data_in(i,:),min_in,max_in,output_&
&max_out,output_min_out,weight_ann_hc_pure_1,b_ann_hc_pure_1,weight_ann_hc_pure_2,b_ann_hc_pure_2)

! 3 LAYER
!         res(i) = beta_2out(data_in(i,:),min_in,max_in,output_&
! &max_out,output_min_out,weight_ann_hc_pure_1,b_ann_hc_pure_1,weight_ann_hc_pure_2,&
! &b_ann_hc_pure_2,weight_ann_hc_pure_3,b_ann_hc_pure_3,weight_ann_hc_pure_4,b_ann_hc_pure_4,&
! &weight_ann_hc_pure_5,b_ann_hc_pure_5,weight_ann_hc_pure_6,b_ann_hc_pure_6)
  


    end do
end do
call system_clock(clock1, clockRate, clockMax)

write(*,*) 'time taken: ', dble(clock1 - clock0) / clockRate

err = 0.D0
open(112,file='res.dat')
do i = 1,size(test_out)
    write(112,*) test_out(i),res(i)
    err = err + abs(res(i) - test_out(i))/test_out(i)
end do
close(112)

err = err/size(test_out)
write(*,*) 'error is: ',err

deallocate(test_in,test_out,res)




end program

