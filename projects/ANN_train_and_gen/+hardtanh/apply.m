function a = apply(n,param)
%LOGSIG.APPLY Apply transfer function to inputs

% Copyright 2012-2015 The MathWorks, Inc.
%   if(n<-1)
%       a = -1;
%   elseif(n>1)
%       a = 1;
%   else
%       a = n;
%           
%   end

    a = n./(1 - (n.^2)/3 + (2/15)*n.^4);

end


