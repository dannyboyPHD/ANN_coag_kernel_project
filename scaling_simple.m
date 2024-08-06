function [samples_out] = scaling_simple(samples,min_max,scaling_type)

n_samples = size(samples);
samples_out = zeros(n_samples);

for i = [1:size(min_max,1)]
    if strcmp(scaling_type{i},'log')
        min = min_max(i,1);
        max = min_max(i,2);
        
        samples_out(:,i) = 2*(log10(samples(:,i))-log10(min))./((log10(max) - log10(min)))-1;
    elseif strcmp(scaling_type{i},'ln')
        min = min_max(i,1);
        max = min_max(i,2);
        
        samples_out(:,i) = 2*(log(samples(:,i))-log(min))./((log(max) - log(min)))-1;

    elseif strcmp(scaling_type{i},'linear')
        min = min_max(i,1);
        max = min_max(i,2);
        samples_out(:,i) = 2*(samples(:,i)-min)/(max-min) -1;
    end  
end

end