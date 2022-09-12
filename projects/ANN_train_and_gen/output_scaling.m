function [scaled_out] = output_scaling(unscaled_out)
out_min = 10^-17;
out_max = 5*10^-5;

scaled_out(:,1) = -1+2*(log10(unscaled_out(:,1)) - log10(out_min))/(log10(out_max)-log10(out_min));
% m = min(unscaled_out(:,2));
m = -0.8;

% n = max(unscaled_out(:,2));
n = 3*10^6;

% scaled_out(:,2) = -1 + 2*(log10(unscaled_out(:,2)+abs(2*m)) - log10(abs(2*m)+m) )/(log10(n+abs(2*m))-log10(abs(2*m) +m) );
scaled_out(:,2) = -1+ 2*(unscaled_out(:,2) - m)/(n - m);
end

