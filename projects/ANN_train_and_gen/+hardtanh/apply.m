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

    a = exp(n);
    if(a>2)
        a = 2
    end

end


