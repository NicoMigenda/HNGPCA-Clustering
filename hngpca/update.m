function obj = update(obj)
%-------------------------------------------------------------------------%
% FIRST PART OF MAIN LOOP: DETERMINE WINNER BRANCH                        %
%-------------------------------------------------------------------------%
    % Sample random data point
    x = obj.data(ceil(size(obj.data,1) .* rand), :)';

    k = 1;
    units_to_update = k;
    % Root unit
    obj.units{1} = find_winner(x, obj.units{1}, obj.potentialFunction, obj.dataDimensionality);
    % Travel through the unit tree from top to bottom
    while 1
        % Distances for both children of the respective parent unit
        for idx = obj.units{k}.child_idx
            obj.units{idx} = find_winner(x,obj.units{idx}, obj.potentialFunction, obj.dataDimensionality);
        end
        % Find winner children
        if obj.units{obj.units{k}.child_idx(1)}.distance <= obj.units{obj.units{k}.child_idx(2)}.distance
            k = obj.units{k}.child_idx(1);
        else
            k = obj.units{k}.child_idx(2);
        end
        
        % Add winner child to the list of units to be updated
        units_to_update = [units_to_update, k];

        % Run down the tree until an unborn unit is reached.
        if obj.units{k}.child_idx == 0
            winner_unit = k;
            break; 
        end
    end

%-------------------------------------------------------------------------%
% SECOND PART OF MAIN LOOP: WINNER BRANCH ADAPTATION                      %
%-------------------------------------------------------------------------%
    % Update the Tree from Bottom to Top
    k = winner_unit;
    while 1
        % Learning rate control
        obj.units{k} = unit_learningrate(obj.units{k}, obj.mu);
          
        % Update unit center according to equation 7
        obj.units{k}.center = obj.units{k}.center + obj.units{k}.learningRate .* obj.units{k}.x_c;
    
        % Update unit PCA estimates
        obj.units{k} = eforrlsa(obj.units{k}); 
          
        % Update residual variance/spread 
        if(obj.dataDimensionality ~= obj.units{k}.m)
            obj.units{k}.sigma = obj.units{k}.sigma_sqr + obj.units{k}.learningRate * (obj.units{k}.x_c' * obj.units{k}.x_c - obj.units{k}.y' * obj.units{k}.y - obj.units{k}.sigma_sqr);
            obj.units{k}.totalVariance = sum(obj.units{k}.eigenvalue) + obj.units{k}.sigma_sqrt;
        end

        % Update unit dimensionality
         if obj.dataDimensionality > 2 
             if obj.units{k}.protect == 0
                obj.units{k} = unit_dim(obj.units{k}, obj.dimThreshold, obj.dataDimensionality, obj.protect);
             else
                 obj.units{k}.protect = obj.units{k}.protect - 1;
             end
         end

        % When a unit has no parent, the root is reached
        if obj.units{k}.parent_idx == 0
            break;
        end
        
        % Update the activity between the winner unit and its sibling
        % equation 8+9
        activity_winner = obj.units{k}.activity * (1 - obj.mu) + obj.mu;
        activity_loser = obj.units{obj.units{k}.sibling}.activity * (1 - obj.mu);
        
        % Normalize activities
        obj.units{k}.activity = activity_winner / (activity_winner + activity_loser);
        obj.units{obj.units{k}.sibling}.activity = activity_loser / (activity_winner + activity_loser);

        % Continue with the parent in next loop
        k = obj.units{k}.parent_idx;
    end

%-------------------------------------------------------------------------%
% THIRDS PART OF MAIN LOOP: UNIT SIMILARITY MEASURES                      %
%-------------------------------------------------------------------------%
    % Update the distances for all units
    % Intra for winner units and inter for looser units - equation 16 + 17
    % Further, update the tree wide activities (pi), in contrast to
    % the only locally used activities
    for i = obj.candidates
        k = obj.units{i}.parent_idx;
        if i == winner_unit || i+1 == winner_unit
            % Update Winner parent
            obj.units{k}.intra_bar = obj.units{k}.intra_bar * (1 - obj.mu) + obj.mu * obj.units{k}.distance;
            obj.units{k}.pi = obj.units{k}.pi * (1 - obj.mu) + obj.mu;
            % Update Winner Unit 
            obj.units{winner_unit}.intra_bar = obj.units{winner_unit}.intra_bar * (1 - obj.mu) + obj.mu * obj.units{winner_unit}.distance;
            obj.units{winner_unit}.pi = obj.units{winner_unit}.pi * (1 - obj.mu) + obj.mu;
            % Update Winner sibling
            sibling = obj.units{winner_unit}.sibling;
            obj.units{sibling}.inter_bar = obj.units{sibling}.inter_bar * (1 - obj.mu) + obj.mu * obj.units{sibling}.distance;
            obj.units{sibling}.pi = obj.units{sibling}.pi * (1 - obj.mu);
            continue;
        end
        obj.units{k}.inter_bar = obj.units{k}.inter_bar * (1 - obj.mu) + obj.mu * obj.units{k}.distance;
        obj.units{k}.pi = obj.units{k}.pi * (1 - obj.mu);
        obj.units{i}.inter_bar = obj.units{i}.inter_bar * (1 - obj.mu) + obj.mu * obj.units{i}.distance;
        obj.units{i}.pi = obj.units{i}.pi * (1 - obj.mu);
        sibling = obj.units{i}.sibling;    
        obj.units{sibling}.inter_bar = obj.units{sibling}.inter_bar * (1 - obj.mu) + obj.mu * obj.units{sibling}.distance;
        obj.units{sibling}.pi = obj.units{sibling}.pi * (1 - obj.mu);
    end

%-------------------------------------------------------------------------%
% Fourth PART OF MAIN LOOP: UNIT Split                                    %
%-------------------------------------------------------------------------%
    % Intra and inter measures that will be filled with the intra and inter
    % values of the lowest fully developed unit of each branch. These
    % values are then used to obtain the current Quality measure of the
    % network and to replace units one by one with their respective
    % children
    intra_measures_bar = zeros(length(obj.candidates),1);
    inter_measures_bar = zeros(length(obj.candidates),1);
    pi = zeros(length(obj.candidates),1);

    % Extract parent indices for candidates
    parent_indices = cellfun(@(unit) unit.parent_idx, obj.units(obj.candidates));

    % Extract and normalize pi values for parent units
    pi(parent_indices) = cellfun(@(unit) unit.pi, obj.units(parent_indices));
    pi_sum = sum(pi);
    % Normalize pi
    normalized_pi = pi / pi_sum;

    % Update pi values in units and intra and inter measure
    for i = obj.candidates
        j = obj.units{i}.parent_idx;
        intra_measures_bar(j) = normalized_pi(j) * obj.units{j}.intra_bar;
        inter_measures_bar(j) = normalized_pi(j) * obj.units{j}.inter_bar;
        obj.units{j}.pi = normalized_pi(j);
    end
    
    % Always replace 1 parent unit by its unborn children
    for i = obj.candidates
        j = obj.units{i}.parent_idx;
        local_inter_measure = inter_measures_bar;
        local_intra_measure = intra_measures_bar;
        sibling = obj.units{i}.sibling;

        % Replace the j-th parent by its two unborn child units. equation
        % 18
        local_intra_measure(j) = obj.units{j}.pi * (obj.units{i}.activity*obj.units{i}.intra_bar + obj.units{sibling}.activity*obj.units{sibling}.intra_bar);
        local_inter_measure(j) = obj.units{j}.pi * (obj.units{i}.activity*obj.units{i}.inter_bar + obj.units{sibling}.activity*obj.units{sibling}.inter_bar);

        obj.units{i}.quality_measure(end+1) = sum(local_intra_measure) / sum(local_inter_measure);
    end
    % Quality measure of the set U_b equation 18
    obj.quality_measure = sum(intra_measures_bar) / sum(inter_measures_bar);
    
    %% Split decision
    if obj.zeta == 0
        % Save all quality measures (equation 18) in an array
        for i = obj.candidates
            quality_measures(i) = obj.units{i}.quality_measure(end);
        end
        % Find the best pair of unborn children. As the loop above fills
        % the gaps in the array with 0 by default, we exclude them here
        [~, unitToSplit] = min(quality_measures(quality_measures > 0));  
        % If the quality measure containing two unborn children is better
        % than the current model, perform the split operation
        if obj.units{obj.candidates(unitToSplit)}.quality_measure(end) < obj.psi * obj.quality_measure
            obj = unit_split(obj, obj.candidates(unitToSplit)); 
            obj.zeta = obj.zeta_init * length(obj.candidates);
        end
    else
        obj.zeta = obj.zeta - 1;
    end
end