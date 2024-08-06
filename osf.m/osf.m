function y = osf(n, p, i, j)

%     Y = OSF(N, P, I, J) Returns the uniformly-distributed sample 'Y' of 
%     'N' points in 'P' dimensions using 'I' cycles of 'J' iterations per 
%     cycle maximising the minimum distance between points.

    
    % Parse input arguments
    if nargin < 3 || isempty(i)
        i = 10;
    end
    if nargin < 4 || isempty(j)
        j = 100;
    end
    
    % Iterate for best sample
    u = 0;
    for i = 1 : i
        
        % Initialise sample
        x = rand(n, p);
        
        % Iterate for best distribution
        for j = 1 : j
            
            % Find pairs of adjacent points
            [k, d] = nn(x, n);
            x = x + rand(n, 1) .* (x - x(k, :)) ./ (2 * n * d);
            
            % Correct outlying points
            x(x > 1) = 1;
            x(x < 0) = 0;
        end
        
        % Update best sample
        v = mean(d) - std(d);
        if v > u
            y = x;
            u = v;
        end
    end
end

% Find nearest neighbour
function [i, d] = nn(x, n)

    % Initialise indices and distances
    i(n, 1) = 0;
    d = i;
    [d(n), i(n)] = min(sum((x(n, :) - x(1 : n - 1, :)) .^ 2, 2));
    [d(1), i(1)] = min(sum((x(1, :) - x(2 : n, :)) .^ 2, 2));
    i(1) = i(1) + 1;
    
    % Brute force search
    for k = 2 : n - 1
        j = i * 0 + 1;
        j(k) = Inf;
        [d(k), i(k)] = min(sum((x(k, :) - x .* j) .^ 2, 2));
    end
    
    % Correction of distance magnitude
    d = sqrt(d);
end