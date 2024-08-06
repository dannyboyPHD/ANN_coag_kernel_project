function [scaled_out] = output_scaling_2output(unscaled_out,min_max)
beta_min = min_max(1,1);
beta_max = min_max(1,2);

scaled_out(:,1) = -1+2*(log10(unscaled_out(:,1)) - log10(beta_min))/(log10(beta_max)-log10(beta_min));

corr_min = min_max(2,1);
corr_max = min_max(2,2);

scaled_out(:,2) = -1+ 2*(unscaled_out(:,2) - corr_min)/(corr_max - corr_min);  % correction factors

end

