function [B,V] = RPCAm(S, D, lambda)
    % RPCA-masking (RPCAm) for source separation.
    % Assume bgm act as a mask to the vocal, i.e., no overlapping between
    % bgm and vocal.
    % Dictionary is for bgm.
    
    % initialization
    B = zeros(size(D,2), size(S,2));
    V = zeros(size(S));
    
    J = zeros(size(D,2), size(S,2));
    
    Y1 = zeros(size(S));
    Y2 = zeros(size(D,2), size(S,2));
    
    
    mu_max = 1e6;
    mu = 1e-6;
    p = 1.1;
    eps = 1e-7;
    
    error = L_inf_norm(S-D*B-V);
    %fprintf('Error = %.8f\n', error);
    while error > eps
        % update J
        J = svd_shrink(B+Y2/mu, 1/mu); 
        
        % update B
        B = (eye(size(D,2)) + transpose(D)*D)\(transpose(D)*(S-V)+J+(transpose(D)...
            *Y1-Y2)/mu);
        
        
        % update V
        V = soft_threshold(S-D*B+Y1/mu, lambda/mu);
        
        % update Y
        Y1 = Y1 + mu*(S-D*B-V);
        Y2 = Y2 + mu*(B-J);

        % update mu
        mu = min(p*mu, mu_max);
        
        error = L_inf_norm(S-D*B-V);
        %fprintf('Error = %.8f\n', error);
    end
    B = D*B;
end