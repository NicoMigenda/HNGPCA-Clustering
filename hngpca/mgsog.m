function A_new = mgsog(A)
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
        % Orthogonalize the new dimension with respect to the existing vectors
        new_dim = new_dim - A(:, i) * (A(:, i)' * new_dim);
    end
    
    % Normalize the new dimension to make it unit length
    new_dim = new_dim / norm(new_dim);
    
    % Check for convergence
    if norm(new_dim - A(:, end)) < tolerance
        break;
    end
end

% Add the new dimension to the eigenvector matrix
A_new = [A, new_dim];

%% Debugging part - Check if the newly added vector is actually orthogonal to the existing eigenvectors
% Check if columns are orthogonal
orthogonal_check = abs(A_new' * A_new - eye(size(A_new, 2))) < tolerance;

% Check if columns have unit norm
norm_check = abs(arrayfun(@(idx) norm(A_new(:, idx)) - 1, 1:size(A_new, 2))) < tolerance;

% Check if all conditions are satisfied
is_orthonormal = all(orthogonal_check(:)) && all(norm_check);

if ~is_orthonormal
    disp('The new weights are not orthonormal.');
end