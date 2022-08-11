function [v1,v2] = order_v1v2(in)
if in(1)>in(2)
   v2 = in(1);
   v1 = in(2);
else
    v1 = in(1);
    v2 = in(2);
end

end

