function unit = unit_dim(unit, dimThreshold, dataDimensionality, protect)

    % Add n Dimensions
    % Sort
    [sortedEigenvalue, ~] = sort(unit.eigenvalue, 'descend');

    % Transform eigenvalues into log scale
    logEigenvalues = log(sortedEigenvalue);
    x = (1:unit.m)';

    % Fit line through the log eigenvalues
    P = polyfit(x,logEigenvalues,1);
    x = (1:unit.m)';
    % Best Fit line to predict the initial values for new dimensions
    x1 = (max(x)+1:dataDimensionality)';
    approximatedEigenvaluesLog = P(1)*x1+P(2);

    % Transform back into normal scale
    approximatedEigenvalues = exp(approximatedEigenvaluesLog);

    % Combine eigenvalues
    allEigenvalues = [sortedEigenvalue; approximatedEigenvalues];
    % Determine new dimensionality
    newDim = max(find(cumsum(allEigenvalues) > dimThreshold * unit.totalVariance,1),2);
    
    if newDim > unit.m
        %Increase Dim
        addedDim = newDim - unit.m;
        for i = 1 : addedDim
            unit.weight= modifiedGramSchmidt(unit.weight);
        end
        unit.eigenvalue = [unit.eigenvalue; approximatedEigenvalues(1:addedDim)];
        unit.m = unit.m + addedDim;
        unit.eta_bar = [unit.eta_bar; repmat(unit.eta_bar(end),addedDim,1)];
        unit.l_bar = [unit.l_bar; repmat(unit.l_bar(end),addedDim,1)]; 
        unit.gamma_bar = [unit.gamma_bar;repmat(unit.gamma_bar(end),addedDim,1)]; 
        unit.sigma_sqr = unit.sigma_sqr - addedDim * unit.sigma_sqr / (dataDimensionality - unit.m);
        unit.protect = protect;
    elseif newDim < unit.m
        %Reduce Dim
        reducedDim = unit.m - newDim;
        unit.m = newDim;
        unit.weight(:,unit.m+1:end) = [];      
        unit.eigenvalue(unit.m+1:end) = [];   
        unit.eta_bar = repmat(unit.eta_bar(1:unit.m), 1);
        unit.l_bar = repmat(unit.l_bar(1:unit.m), 1);
        unit.gamma_bar = repmat(unit.gamma_bar(1:unit.m), 1);
        unit.sigma_sqr = unit.sigma_sqr + reducedDim * unit.sigma_sqr / (dataDimensionality - unit.m);
        unit.protect = protect;
    end