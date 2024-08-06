function [m] = scale_minmax(min_max,scaling_type)
n_inputs = size(min_max,1);

for i = 1:n_inputs
    if strcmp(scaling_type{i},'linear')
        m(i,:) = min_max(i,:);
    elseif strcmp(scaling_type{i},'log')
        m(i,:) = log10(min_max(i,:));
    elseif strcmp(scaling_type{i},'ln')
        m(i,:) = log(min_max(i,:));
    end
end

end

