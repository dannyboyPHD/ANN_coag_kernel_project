function [v1v2] = req_v1v2points(v_start,v_end,n)
%v_start and v_end are [v1, v2] vectors
L = sqrt(    (v_end(2) - v_start(2))^2 + (v_end(1) - v_start(1))^2);

theta = atan(( v_end(2) - v_start(2) )/( v_end(1) - v_start(1) ));
v1v2 = zeros(n,2);
a = 1/n;
for i = 1:n
    v1v2(i,:) = [i*a*L*cos(theta)+v_start(1), i*a*L*sin(theta)+v_start(2)];
end



end

