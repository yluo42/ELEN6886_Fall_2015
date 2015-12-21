function FrobeniusNorm = FrobeniusNorm(X)
    %%%
    %Frobenius norm of matrix X
    % Returns sqrt(sum_i sum_j X[i,j] ^ 2)
    %%%
    
    FrobeniusNorm = sum(sum(X.^2));
end