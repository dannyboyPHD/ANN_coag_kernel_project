function [dz_half] = scan_till_limit(v_start,dz_1,nonLin_limit,params)

% dz_1  = [1,0]*10^-27;
res = 250;

max_db = max_dev(v_start,dz_1,res,params,'');
dz_2 = dz_1;

%roughly locates cross-over point
disp('== step 1===')
disp(max_db - nonLin_limit);
a = dz_1;
r = 1.5;
j = 1;
while(max_db - nonLin_limit < 0)
    
    res = 100;
    dz_2 = a.*j^r;
    max_db = max_dev(v_start,dz_2,res,params,'')
    j=j+1;
end
disp(max_dev(v_start,dz_2,res,params,'') - nonLin_limit);
disp(max_dev(v_start,dz_1,res,params,'') - nonLin_limit);

%reverse tesing to find breakeven
j=1;
while(max_db - nonLin_limit > 0)
    dz_1 = dz_2 - a.*j^r;
    max_db = max_dev(v_start,dz_1,res,params,'');
    j=j+1;
end

disp(max_dev(v_start,dz_2,res,params,'') - nonLin_limit);
disp(max_dev(v_start,dz_1,res,params,'') - nonLin_limit);


% C = abs(max_db-nonLin_limit);
C= 1;
tol = 0.01; % 1%
disp('======= bisection method ===========')
iter = 0;



while(C>tol && iter< 25 )
    res = 2000;
% simple bisection method
    dz_half = 0.5*(dz_1 + dz_2);

    if((max_dev(v_start,dz_1,res,params,'') - nonLin_limit)*(max_dev(v_start,dz_2,res,params,'') - nonLin_limit)< 0)
        dz_2 = dz_half;
        max_db = max_dev(v_start,dz_2,res,params,'');
    else
        dz_1 = dz_half;
        max_db = max_dev(v_start,dz_1,res,params,'');
    end
 
    C = abs(max_db-nonLin_limit);
    iter = iter +1;
    C
end

if(C > 0.01)
    max_dev(v_start,dz_half,res,params,'check_error')
end
iter
C
dz_half
end

