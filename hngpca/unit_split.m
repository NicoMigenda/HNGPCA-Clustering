function obj = unit_split(obj,winner_idx)

% Remove new parent from candiate model
if length(obj.units) == 3
    new_units = [2,3];
else
    new_units = [winner_idx, winner_idx+1];
end

for i = new_units
    % Kinder Indices für die Eltern unit
    obj.units{i}.child_idx = [length(obj.units) + 1, length(obj.units) + 2];
    
    % Initialize two new obj.units (leafs) within the new parent unit
    for k = obj.units{i}.child_idx
        if k == obj.units{i}.child_idx(1)
            obj.units{k}.sibling = obj.units{i}.child_idx(2);
            obj.candidates = [obj.candidates, k];
            obj.candidates = obj.candidates(obj.candidates~=i);
        else
            obj.units{k}.sibling = obj.units{i}.child_idx(1);
        end
        obj.units{k}.parent_idx = i;
        obj.units{k}.child_idx = [0,0];
        obj.units{k}.m = 2; 
        obj.units{k}.center = obj.units{i}.center;
        obj.units{k}.weight = obj.units{i}.weight(:,1:2);
        obj.units{k}.eigenvalue = obj.units{i}.eigenvalue(1:2) / 5;
        obj.units{k}.sigma = obj.units{i}.sigma;
    
        obj.units{k}.y_bar = obj.units{i}.y_bar(1:2) * 1.1;
        obj.units{k}.l_bar = obj.units{i}.l_bar(1:2) / 1.1;
        obj.units{k}.mt = obj.units{k}.y_bar(1:2) - obj.units{k}.l_bar(1:2);
        obj.units{k}.intra = obj.units{i}.intra;
        obj.units{k}.inter = obj.units{i}.inter; 
        obj.units{k}.quality_measure = 0;
        obj.units{k}.learningRate = 0.99;
        obj.units{k}.apriori = obj.units{i}.apriori;
        obj.units{k}.activity = 1;
        obj.units{k}.protect = obj.protect;
        obj.units{k}.lR_history = obj.units{k}.learningRate;
        obj.units{k}.m_history = 2;
    
        obj.units{k}.x_c   = zeros(obj.dataDimensionality, 1);
        obj.units{k}.y     = zeros(obj.units{i}.m, 1);
        obj.units{k}.match = 0;
        obj.units{k}.alpha = 0;
        obj.units{k}.distance = 0;
        obj.units{k}.distance_controlled = 0;
    
        obj.units{k}.image_handle = 0;
        obj.units{k}.dim_handle = 0;
    
        obj.numberUnits = obj.numberUnits + 1;
    end
end
