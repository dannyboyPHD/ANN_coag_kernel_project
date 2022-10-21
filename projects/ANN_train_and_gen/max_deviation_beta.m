function [delta] = max_deviation_beta(xy,res,b1,b2)

L = sqrt( (xy(res,1) - xy(1,1))^2 + (xy(res,2) - xy(1,2))^2 + (b2-b1)^2 );

for i = 1,res
   eta = sqrt((xy(i,1)-xy(1,1))^2+(xy(i,2) - xy(1,2))^2 );
   
   b = ((b2 - b1)/L)*eta + b2;
   
   
    
end





end

