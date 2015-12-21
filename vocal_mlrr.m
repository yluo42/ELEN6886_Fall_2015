function [Z1, Z2, E] = vocal_mlrr(X, D_v, D_b, lambda, beta)
    %%% Calculate the multiple low-rank representation(MLRR) for the vocal
    %%% parts using inexact ALM.
    % Inputs are spectrogram of the vocal part, the learnt dictionary for
    % singing voice, parameters lambda and beta for inexact ALM.
    % Returns three matrices Z1, Z2 and E, Z1 represents the coefficient
    % matrix for singing voice (i.e. D*Z1 is the singing voice), Z2 is the
    % background music and E is the noise.
    
    % initialization
    J1 = zeros(size(D_v,2), size(X,2));
    Z1 = zeros(size(D_v,2), size(X,2));
    Y1 = zeros(size(D_v,2), size(X,2));
    J2 = zeros(size(D_b,2), size(X,2));
    Z2 = zeros(size(D_b,2), size(X,2));
    Y2 = zeros(size(D_b,2), size(X,2));
    E = zeros(size(X));
    Y3 = zeros(size(X));
    mu_max = 1e6;
    mu = 1e-6;
    p = 1.1;
    eps = 1e-6;
    
    error = L_inf_norm(X-D_v*Z1-D_b*Z2-E);
    %fprintf('Error = %.9f\n', error);
    
    while error > eps
        % update J1
        J1 = svd_shrink(Z1+Y1/mu, 1/mu); 
        
        % update J2
        J2 = svd_shrink(Z2+Y2/mu, lambda/mu);
        
        % update Z1
        Z1 = (eye(size(D_v,2))+transpose(D_v)*D_v)\(transpose(D_v)*(X-D_b*Z2-E)+J1+...
            (transpose(D_v)*Y3-Y1)/mu);
        %Z1_max = max(max(Z1))
        % update Z2
        Z2 = (eye(size(D_b,2))+transpose(D_b)*D_b)\(transpose(D_b)*(X-D_v*Z1-E)+J2+...
            (transpose(D_b)*Y3-Y2)/mu);
        %Z1_max = max(max(Z2))
        % update E
        E = soft_threshold(X-D_v*Z1-D_b*Z2+Y3/mu, beta/mu);
        
        % update Y1,Y2,Y3
        Y1 = Y1 + mu*(Z1-J1);
        Y2 = Y2 + mu*(Z2-J2);
        Y3 = Y3 + mu*(X-D_v*Z1-D_b*Z2-E);
        
        error = L_inf_norm(X-D_v*Z1-D_b*Z2-E);
        %fprintf('Error = %.9f\n', error);
        
        % update mu
        mu = min(p*mu, mu_max);
    end
    Z1 = D_v * Z1;
    Z2 = D_b * Z2;
end
    
    