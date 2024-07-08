function unit = unit_dim(unit, dimThreshold, dataDimensionality, protect)

    % Add n Dimensions
    % Sort
    [sortedEigenvalue, ~] = sort(unit.eigenvalue, 'descend');

    % Transform eigenvalues into log scale
    logEigenvalues = log(sortedEigenvalue);
    x = (1:unit.m)';

    % Fit line through the log eigenvalues
    P = polyfit(x,logEigenvalues,1);
    %x = (1:dataDimensionality)';
    x = (1:unit.m)';
    % Best Fit line to predict the initial values for new dimensions
    x1 = (max(x)+1:dataDimensionality)';
    approximatedEigenvaluesLog = P(1)*x1+P(2);

    % Transform back into normal scale
    approximatedEigenvalues = exp(approximatedEigenvaluesLog);

    allEigenvalues = [sortedEigenvalue;approximatedEigenvalues];
    newDim = max(find(cumsum(allEigenvalues) > dimThreshold * unit.totalVariance,1),2);
    
    if newDim > unit.m
        %Increase Dim
        addedDim = newDim - unit.m;
        %if addedDim > 1
        %    addedDim = 1;
        %end
        for i = 1 : addedDim
            unit.weight= mgsog(unit.weight);
        end
        unit.eigenvalue = [unit.eigenvalue; approximatedEigenvalues(1:addedDim)];
        unit.m = unit.m + addedDim;
        unit.y_bar = [unit.y_bar; repmat(unit.y_bar(end),addedDim,1)]; %repmat(mean(approximatedEigenvalues)^2
        unit.l_bar = [unit.l_bar; repmat(unit.l_bar(end),addedDim,1)]; % repmat(mean(approximatedEigenvalues)
        unit.mt = [unit.mt;repmat(unit.mt(end),addedDim,1)]; %mean(approximatedEigenvalues)^2 + mean(approximatedEigenvalues)
        unit.sigma = unit.sigma - addedDim * unit.sigma / (dataDimensionality - unit.m);
        unit.protect = protect;
    elseif newDim < unit.m
        %Reduce Dim
        reducedDim = unit.m - newDim;
        unit.m = newDim;
        unit.weight(:,unit.m+1:end) = [];      
        unit.eigenvalue(unit.m+1:end) = [];   
        unit.y_bar = repmat(unit.y_bar(1:unit.m), 1);
        unit.l_bar = repmat(unit.l_bar(1:unit.m), 1);
        unit.mt = repmat(unit.mt(1:unit.m), 1);
        unit.sigma = unit.sigma + reducedDim * unit.sigma / (dataDimensionality - unit.m);
        unit.protect = protect;
    end
    if isinf(unit.eigenvalue)
        disp("Inf Dim")
    end