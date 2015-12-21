function X_soft = soft_threshold(X, lambda)
    %%%
    % Apply the soft-thresholding function on X.
    % Returns V such that V[i,j] = sign(X[i,j])*max(abs(X[i,j]) - lambda,0)
    %%%
    X_soft = zeros(size(X));
    X_size = size(X,1) * size(X,2);
    for i = 1:X_size
        X_soft(i) = sign(X(i)) * max(abs(X(i)) - lambda, 0);
    end
end
    
