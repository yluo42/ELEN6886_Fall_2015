function X_shrink = svd_shrink(X, lambda)
    %%%
    % Apply the SVD thresholding function on X.
    % Returns the matrix obtained by computing U * soft_threshold(S) * V
    % where U, S, V are the result of [U,S,V] = SVD(X)
    %%%
    [U,S,V] = svd(X, 'econ');
    X_shrink = U * soft_threshold(S, lambda) * transpose(V);
end
    