function A_new = modifiedGramSchmidt(A)
[n,m] = size(A); 

% Maximum number of iterations to reach convergence of the newly added
% dimension
max_iter = 1000; 
% Tolerance for convergence
tolerance = 1e-6; 

% Repeat until convergence or maximum iterations reached
for j = 1 : max_iter
    % Randomly initialize the new dimension
    new_dim = randn(n, 1);
    
    % Apply Modified Gram-Schmidt process
    for i = 1:m
        % Orthogonalize the new dimension with respect to the existing
        % vectors - equation 18
        new_dim = new_dim - A(:, i) * (A(:, i)' * new_dim);
    end
    
    % Normalize the new dimension to make it unit length - equation 19
    new_dim = new_dim / norm(new_dim);
    
    % Check for convergence
    if norm(new_dim - A(:, end)) < tolerance
        break;
    end
end

% Add the new dimension to the eigenvector matrix
A_new = [A, new_dim];
