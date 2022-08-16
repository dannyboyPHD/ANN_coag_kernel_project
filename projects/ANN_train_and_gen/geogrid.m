function [x] = geogrid(min,max,n)
    x = zeros(n,1);
    r = (max/min)^(1/n);
    x(1) = min;
    for i = 2:n
        x(i) = x(i-1).*r^(n-1);
        
    end
end

