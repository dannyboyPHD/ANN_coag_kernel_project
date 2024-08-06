function [v1,v2] = order_v1v2(in)
v1 = zeros(length(in),1);
v2 = zeros(length(in),1);

for i= [1:length(in)]

    if in(i,1)>in(i,2)
       v2(i) = in(i,2);
       v1(i) = in(i,1);
    else
        v1(i) = in(i,2);
        v2(i) = in(i,1);
    end

end



end

