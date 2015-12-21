function L1norm = L1norm(X)
    %%%
    % L1 norm of matrix X
    % Returns the maximum value over the sum of each column of X
    %%%
    L1norm = max(sum(X,1));
end