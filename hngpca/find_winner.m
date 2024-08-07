function unit  = find_winner(x, unit, potentialFunction, dataDimensionality)

    % Distance between data point and unit center
    unit.x_c = x - unit.center;
    % Project centered input onto eigenvectors
    unit.y   = unit.weight' * unit.x_c;

    %% Basisterm that is always considered. 
    % Equation 4
    basisTerm = unit.y' * (unit.y ./ unit.eigenvalue);
    % For m < n the reconstruction error is added
    if unit.m < dataDimensionality
        lambda_rest = unit.sigma_sqr / (dataDimensionality - unit.m);
        if(lambda_rest <= eps)
            lambda_rest = eps;
        end  
        % Equation 4 - additive term for m < n
        basisTerm = basisTerm + (1 ./ lambda_rest) * (unit.x_c' * unit.x_c - unit.y' * unit.y);
    end
    
    %% Desired volume / radius / alpha control
    switch potentialFunction
        %(H)offmann - Equation 5 
        case "H"
            control = sqrt(prod(unit.eigenvalue))^(2/dataDimensionality);
            if unit.m < dataDimensionality
                control = exp(sum(log(unit.eigenvalue)))^(1/dataDimensionality) * lambda_rest^((dataDimensionality - unit.m) / dataDimensionality);
            end
        case "N"
            control = 1;
        otherwise
            disp("Wrong potentialfunction passed. Allowed are H and N.")
    end
    
    %% Combine terms and calculate distance 
    unit.distance = basisTerm * control;
end

