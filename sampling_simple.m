function [samples_out] = sampling_simple(samples,min_max,scaling_type)

n_samples = size(samples);
samples_out = zeros(n_samples);

for i = [1:size(min_max,1)]
    if strcmp(scaling_type{i},'log')
        min = min_max(i,1);
        max = min_max(i,2);

        samples_out(:,i) = samples(:,i)*(log10(max) - log10(min)) + log10(min);%v_1       
        samples_out(:,i) = 10.^samples_out(:,i);

    elseif strcmp(scaling_type{i},'linear')
        min = min_max(i,1);
        max = min_max(i,2);
        samples_out(:,i) = samples(:,i)*(max - min) + min;
        
    elseif strcmp(scaling_type{i},'log_and_linear')
            %linear
            min = min_max(i,1);
            max = min_max(i,2);
            
            samples_out(1:n_samples/2,i) = samples(1:n_samples/2,i)*(max - min) + min;
            % half log
            samples_out(n_samples/2:end,i) = samples(n_samples/2:end,i)*(log10(max) - log10(min)) + log10(min);% v_1       
            samples_out(n_samples/2:end,i) = 10.^samples_out(n_samples/2:end,i);
    end  
end

end

