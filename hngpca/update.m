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
          
        % Update unit center according to equation 
        obj.units{k}.center = obj.units{k}.center + obj.units{k}.learningRate .* obj.units{k}.x_c;
    
        % Update unit PCA estimates
        obj.units{k} = eforrlsa(obj.units{k}); 
          
        % Update residual variance/spread 
        if(obj.dataDimensionality ~= obj.units{k}.m)
            obj.units{k}.sigma = obj.units{k}.sigma + obj.units{k}.learningRate * (obj.units{k}.x_c' * obj.units{k}.x_c - obj.units{k}.y' * obj.units{k}.y - obj.units{k}.sigma);
            obj.units{k}.totalVariance = sum(obj.units{k}.eigenvalue) + obj.units{k}.sigma;
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
        activity_winner = obj.units{k}.activity + obj.mu;
        activity_loser = obj.units{obj.units{k}.sibling}.activity;
        
        % Normalize activities
        obj.units{k}.activity = (2 * activity_winner) / (activity_winner + activity_loser);
        obj.units{obj.units{k}.sibling}.activity = (2 * activity_loser) / (activity_winner + activity_loser);

        % Continue with the parent in next loop
        k = obj.units{k}.parent_idx;
    end

%-------------------------------------------------------------------------%
% THIRDS PART OF MAIN LOOP: UNIT SIMILARITY MEASURES                      %
%-------------------------------------------------------------------------%
    % Update the similarity measures for all units
    % Intra for winner units and inter for looser units
    % Further, update the tree wide activities (apriori), in contrast to
    % the only locally used activities
    for i = obj.candidates
        k = obj.units{i}.parent_idx;
        if i == winner_unit || i+1 == winner_unit
            % Update Winner parent
            obj.units{k}.intra = obj.units{k}.intra * (1 - obj.mu) + obj.mu * obj.units{k}.distance;
            obj.units{k}.apriori = obj.units{k}.apriori * (1 - obj.mu) + obj.mu;
            % Update Winner Unit 
            obj.units{winner_unit}.intra = obj.units{winner_unit}.intra * (1 - obj.mu) + obj.mu * obj.units{winner_unit}.distance;
            obj.units{winner_unit}.apriori = obj.units{winner_unit}.apriori * (1 - obj.mu) + obj.mu;
            % Update Winner sibling
            sibling = obj.units{winner_unit}.sibling;
            obj.units{sibling}.inter = obj.units{sibling}.inter * (1 - obj.mu) + obj.mu * obj.units{sibling}.distance;
            obj.units{sibling}.apriori = obj.units{sibling}.apriori * (1 - obj.mu);
            continue;
        end
        obj.units{k}.inter = obj.units{k}.inter * (1 - obj.mu) + obj.mu * obj.units{k}.distance;
        obj.units{k}.apriori = obj.units{k}.apriori * (1 - obj.mu);
        obj.units{i}.inter = obj.units{i}.inter * (1 - obj.mu) + obj.mu * obj.units{i}.distance;
        obj.units{i}.apriori = obj.units{i}.apriori * (1 - obj.mu);
        sibling = obj.units{i}.sibling;    
        obj.units{sibling}.inter = obj.units{sibling}.inter * (1 - obj.mu) + obj.mu * obj.units{sibling}.distance;
        obj.units{sibling}.apriori = obj.units{sibling}.apriori * (1 - obj.mu);
    end

%-------------------------------------------------------------------------%
% Fourth PART OF MAIN LOOP: UNIT Split                                    %
%-------------------------------------------------------------------------%
    % Intra and inter measures that will be filled with the intra and inter
    % values of the lowest fully developed unit of each branch. These
    % values are then used to obtain the current Quality measure of the
    % network and to replace units one by one with their respective
    % children
    intra_measure = zeros(length(obj.candidates),1);
    inter_measure = zeros(length(obj.candidates),1);
    apriori = zeros(length(obj.candidates),1);

    % Extract parent indices for candidates
    parent_indices = cellfun(@(unit) unit.parent_idx, obj.units(obj.candidates));

    % Extract and normalize apriori values for parent units
    apriori(parent_indices) = cellfun(@(unit) unit.apriori, obj.units(parent_indices));
    apriori_sum = sum(apriori);
    % Normalize apriori
    normalized_apriori = apriori / apriori_sum;

    % Update apriori values in units and intra and inter measure
    for i = obj.candidates
        j = obj.units{i}.parent_idx;
        intra_measure(j) = normalized_apriori(j) * obj.units{j}.intra;
        inter_measure(j) = normalized_apriori(j) * obj.units{j}.inter;
        obj.units{j}.apriori = normalized_apriori(j);
    end
    
    % Always replace 1 parent unit by its unborn children
    for i = obj.candidates
        j = obj.units{i}.parent_idx;
        local_inter_measure = inter_measure;
        local_intra_measure = intra_measure;
        sibling = obj.units{i}.sibling;

        % Replace the j-th parent by its two unborn child units. 
        local_intra_measure(j) = obj.units{j}.apriori * (obj.units{i}.activity*obj.units{i}.intra + obj.units{sibling}.activity*obj.units{sibling}.intra);
        local_inter_measure(j) = obj.units{j}.apriori * (obj.units{i}.activity*obj.units{i}.inter + obj.units{sibling}.activity*obj.units{sibling}.inter);

        obj.units{i}.quality_measure(end+1) = sum(local_intra_measure) / sum(local_inter_measure);
    end
    obj.quality_measure = sum(intra_measure) / sum(inter_measure);
    
    obj.intra_measure = (1-obj.mu) * obj.intra_measure + obj.mu * sum(intra_measure);
    obj.inter_measure = (1-obj.mu) * obj.inter_measure + obj.mu * sum(inter_measure);
    
    %% Split decision
    if obj.split_counter == 0
        for i = obj.candidates
            quality_measures(i) = obj.units{i}.quality_measure(end);
        end
        [~, unitToSplit] = min(quality_measures(quality_measures > 0));  
        if isempty(unitToSplit) == 0
            if obj.psi * obj.units{obj.candidates(unitToSplit)}.quality_measure(end) < obj.quality_measure
                obj = unit_split(obj, obj.candidates(unitToSplit)); 
                obj.split_counter = obj.split_counter_init * length(obj.candidates);
            end
        end
    else
        obj.split_counter = obj.split_counter - 1;
    end
end