function [outs] = lhs_subdomains(no_samples,cols)

lower_half = 0.5*lhsdesign(no_samples/2,cols);
upper_half = 0.5*lhsdesign(no_samples/2,cols) + 0.5;

outs = cat(1,lower_half,upper_half);
% 
for i = 1:5
   x = randperm(numel(outs(:,i)));
   outs(:,i) = reshape(outs(x,i),size(outs(:,i)));
    
end










end

