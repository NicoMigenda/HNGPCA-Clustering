function obj = init(obj)
    obj.numberUnits = 3;
    obj.units = cell(obj.numberUnits,1);
    obj.split_counter = obj.split_counter_init;
    for k = 1 : 3
        %Unit specific Output Dimension, for 2d it remains 2, otherwise
        %adaptivly adjusted 
        obj.units{k}.m = 2;

        if obj.units{k}.m > obj.dataDimensionality
            error("PCA dimension greater than data dimension (m>n)");
        end

        if k == 1
            % Init the root unit
            % Indices of the two child units
            obj.units{k}.child_idx = [2,3];
            % Identifies if the unit has a parent unit
            obj.units{k}.parent_idx = 0;
            obj.units{k}.sibling = 0;
        else
            % Init the 2 unborn childs
            obj.units{k}.child_idx = 0;
            obj.units{k}.parent_idx = 1;
            if k == 2
                obj.units{k}.sibling = 3;
            elseif k == 3
                obj.units{k}.sibling = 2;
            end
        end
    
        % Init centers 
        if size(obj.data,1) == 1
            for i = 1:obj.dataDimensionality
                obj.units{k}.center(i) = obj.data(:, i) * rand;
            end
        else
            obj.units{k}.center = obj.data(ceil(size(obj.data,1) .* rand), :);
        end
        obj.units{k}.center = obj.units{k}.center';
    
        % first m principal axes (weights)
        % orhonormal (as needed by distance measure)        
        obj.units{k}.weight = orth(rand(obj.dataDimensionality, obj.units{k}.m));
    
        % first m eigenvalues                                
        obj.units{k}.eigenvalue = repmat(obj.lambda, obj.units{k}.m, 1);
    
        % residual variance in the minor (m -n) eigendirections
        obj.units{k}.sigma = obj.lambda;
        obj.units{k}.totalVariance = sum(obj.units{k}.eigenvalue);
    
        % deviation between input and center
        obj.units{k}.x_c = zeros(obj.dataDimensionality, 1);

        % Unit specific low pass values for intra, inter and quality
        % Initial values doesnt matter
        obj.units{k}.intra = 10;
        obj.units{k}.inter = 10;
        obj.units{k}.quality= 1;
        obj.units{k}.quality_measure = 0;
    
        % unit output (activation) for input x_c
        obj.units{k}.y = zeros(obj.units{k}.m, 1);
        obj.units{k}.protect = obj.protect;
    
        % unit activity
        obj.units{k}.apriori = 1;
        obj.units{k}.activity = 1;
    
        % unit matching measure
        obj.units{k}.y_bar = obj.lambda^2 * ones(obj.units{k}.m, 1);
        obj.units{k}.l_bar = repmat(obj.lambda, obj.units{k}.m, 1);
        obj.units{k}.mt = obj.units{k}.y_bar + obj.units{k}.l_bar;
    
        % Learning rate 
        obj.units{k}.learningRate = obj.learningRate;
    
        obj.units{k}.distance = 0;

        obj.units{k}.image_handle = 0;
        obj.units{k}.dim_handle = 0;
    end
end