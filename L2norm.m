function L2norm = L2norm(X)
    %%%
    % L2 norm of matrix X
    % Returns the maximum value over the sum of each column of X
    %%%
    L2norm = sqrt(sum(sum(X.^2)));
end