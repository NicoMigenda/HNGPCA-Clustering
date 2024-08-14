function obj = unit_split(obj,winner_idx)

new_units = [winner_idx, winner_idx+1];

for i = new_units
    % Child indicies for the parent unit
    obj.units{i}.child_idx = [length(obj.units) + 1, length(obj.units) + 2];
    % Set the pi value according to the parents pi value and its own
    % activity. This way both new developed units represent the correct share of
    % the model
    obj.units{i}.pi = obj.units{obj.units{i}.parent_idx}.pi * obj.units{i}.activity;
    
    % Initialize two new obj.units within the new parent unit
    for k = obj.units{i}.child_idx
        if k == obj.units{i}.child_idx(1)
            obj.units{k}.sibling = obj.units{i}.child_idx(2);
            obj.candidates = [obj.candidates, k];
            obj.candidates = obj.candidates(obj.candidates~=i);
        else
            obj.units{k}.sibling = obj.units{i}.child_idx(1);
        end
        % Set parent index
        obj.units{k}.parent_idx = i;
        % As an unborn unit it has no children
        obj.units{k}.child_idx = [0,0];
        % Initialize dimensionality to two
        obj.units{k}.m = 2; 
        % Inherit parent units center
        obj.units{k}.center = obj.units{i}.center;
        % Inherit parent units eigenvectors
        obj.units{k}.weight = obj.units{i}.weight(:,1:2);
        % Set eigenvalues to half its parent unit
        obj.units{k}.eigenvalue = obj.units{i}.eigenvalue(1:2) / 2;
        % Inherit residual variance from parent unit
        obj.units{k}.sigma_sqr = obj.units{i}.sigma_sqr;
    
        % Slightly vary the low-passes for eta and l, otherwise the
        % learning rate will directly drop to 0 
        obj.units{k}.eta_bar = obj.units{i}.eta_bar(1:2) * 1.1;
        obj.units{k}.l_bar = obj.units{i}.l_bar(1:2) / 1.1;
        obj.units{k}.gamma_bar = obj.units{k}.eta_bar(1:2) - obj.units{k}.l_bar(1:2);
        obj.units{k}.learningRate = 0.99;
        obj.units{k}.lr_history = [0.99];
        % Inherit intra and inter 
        obj.units{k}.intra_bar = obj.units{i}.intra_bar;
        obj.units{k}.inter_bar = obj.units{i}.inter_bar; 
        % Init quality measure, value is overwritten before usage so the
        % value does not matter
        obj.units{k}.quality_measure = 0;
        % Both childs start with an activaion of 0.5, so that the sum is 1
        obj.units{k}.activity = 0.5;
        % Inherit protect from parents
        obj.units{k}.protect = obj.protect;
        
        % Reset the distances 
        obj.units{k}.x_c   = zeros(obj.dataDimensionality, 1);
        obj.units{k}.y     = zeros(obj.units{i}.m, 1);
        obj.units{k}.distance = 0;
        
        % Initialize the plot handles
        obj.units{k}.image_handle = 0;
        obj.units{k}.dim_handle = 0;
        
        % Increase number of unit count by 1 
        obj.numberUnits = obj.numberUnits + 1;
    end
end
