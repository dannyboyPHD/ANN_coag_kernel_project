function [D_star] = star_discrepancy(X)
    % Function to calculate the star discrepancy of a set of samples X
    % X is an N-by-d matrix where N is the number of samples and d is the dimension
    
    [N, d] = size(X);
    D_star = 0;

    % Iterate through each point in the sample
    for i = 1:N
        % Calculate volume of the hyperrectangle formed by the origin and X(i, :)
        V = prod(X(i, :));
        
        % Number of points in the hyperrectangle [0, X(i, :)]
        P = sum(all(bsxfun(@le, X, X(i, :)), 2)) / N;
        
        % Update the discrepancy
        D_star = max(D_star, abs(V - P));
    end
end

