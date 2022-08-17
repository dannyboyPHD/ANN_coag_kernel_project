function [v_lim] = search_dz(v_start,dz,n,nonLin,params,domain_limits)

v_lim = zeros(n,2);

for i = 1:n

    if(v_start(1)> domain_limits(1))
        break
    elseif(v_start(2)> domain_limits(2))
        break
    end
    
    dz_50 = scan_till_limit(v_start,dz,nonLin,params);
    
    
    disp(dz_50)
    v_lim(i,:) = v_start;
    v_start = v_start +  dz_50;
    dz = 0.001*dz_50;
    
end

end

