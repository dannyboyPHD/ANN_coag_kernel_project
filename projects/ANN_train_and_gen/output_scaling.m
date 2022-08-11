function [scaled_out] = output_scaling(unscaled_out)
out_min = 10^-17;
out_max = 5*10^-5;

scaled_out = -1+2*(log10(unscaled_out(:)) - log10(out_min))/(log10(out_max)-log10(out_min));


end

