function converged = converged(S, B, V, P, J1, J2, J3, E, D1, D2, eps)
    %%% Evaluate the error rate, check if the algorithm is converged.
    % Returns bool variable.
    
    converged = false;
    
    residual1 = S-B-D1*V-D2*P-E;
    residual2 = B-J1;
    residual3 = V-J2;
    residual4 = P-J3;
    
    error1 = max(residual1(:));
    error2 = max(residual2(:));
    error3 = max(residual3(:));
    error4 = max(residual4(:));
    
    max_error = max([error1, error2, error3, error4]);
    fprintf('Error = %f\n', max_error);
    if max_error < eps
        converged = true;
    end
end