classdef HNGPCA
    properties
        % Optional parameters that are overwritten in Constructor if parsed
        potentialFunction = "H"     % Defines the potential function used during the ranking process
                                    % Allowed values: "H", "N" - We refer to our paper
                                    % for an explanation
        learningRate      = 0.99    % Defines the initial learning rate for all units. 
        psi               = 0.95    % Defines the threshold of how much the unborn units
                                    % need to outperform their parent unit 
        mu                = 0.005   % Low pass filter
        lambda            = 1       % Initial eigenvalue
        dimThreshold      = 0.99    % Dimensionality Threshold - Percentage of Variance 
        protect           = 50      % Number of update cycles before the dimensionality
                                    % can be adjusted. Decreased for each unit individually
        iterations        = 25000   % Sets the number of update cycles, one data point per iteration
        zeta_init         = 100     % Initial value of number of update cycles between split operations
        % Allocation of variables that are not subject to be set prior the training
        units                       % An array of local PCA units
        dataDimensionality          % Data dimensionality set to the dimensionality of input data
        data                        % Data
        candidates        = 2       % The index of the first initial unborn child unit   
        numberUnits                 % Defines the number of units to be initialized - Always 1 root and 2 children initially
        zeta                        % Number of update cycles between split operations
        quality_measure             % Quality measure of the set U_b  
        centroidIndex               % Validation: Centroid Index
        nmi                         % Validation: Normalized Mutual information
        y_pred                      % Array of labels that show which data point belongs to which cluster
        ax                          % Plot handle   
    end
    
    methods
        %-------
        % Constructor
        %-------
        function obj = HNGPCA(varargin)
            for i = 1:2:nargin
                property_name = varargin{i};
                property_value = varargin{i+1};
                switch lower(property_name)
                    case 'potentialfunction'
                        obj.potentialFunction = property_value;
                    case 'learningrate'
                        obj.learningRate = property_value;
                    case 'zeta_init'
                        obj.zeta_init = property_value;
                    case 'psi'
                        obj.psi = property_value;
                    case 'mu'
                        obj.mu = property_value;
                    case 'lambda'
                        obj.lambda = property_value;
                    case 'protect'
                        obj.protect = property_value;
                    case 'dimthreshold'
                        obj.dimThreshold = property_value;
                    otherwise
                        error('Parsed wrong parameter to constructor ngpca: ' + property_name)
                end
            end
        end

        %-------
        % Init Units
        %-------
        function obj = init_units(obj, data, varargin)
            for i = 1:2:nargin-3
                property_name = varargin{i};
                property_value = varargin{i+1};
                switch lower(property_name)
                    case 'iterations'
                        obj.iterations = property_value;
                    otherwise
                        error('Parsed wrong parameter to init_units: ' + property_name)
                end
            end
            if size(data,2) < 2
                error('Invalid input size. Data dimensionality lesser than two.')
            end 
            obj.data = data;
            obj.dataDimensionality = size(obj.data,2);
            obj = init(obj);
        end

        %-------
        % Train on one data point
        %-------
        function obj = fit_single(obj, data)
            if size(data,2) < 2
                error('Invalid input size. Data dimensionality lesser than two.')
            end
            obj.data = data;
            obj = update(obj);
        end

        %-------
        % Train on multiple data points
        %-------
        function obj = fit_multiple(obj, data)
            if size(data,1) < 2
                warning("We suggest fit_single when training on single data point")
            end
            if size(data,2) < 2
                error('Invalid input size. Data dimensionality lesser than two.')
            end
            obj.data = data;
            for i = 1 : obj.iterations
                obj = update(obj);
                obj = learningrate_history(obj);
            end
        end
        
        %-------
        % Test for unit split
        %-------
        function obj = split(obj)
            obj = split_criterion(obj);
        end

        %-------
        % Draw units
        %-------
        function obj = draw(obj)
            obj = drawupdate(obj);
        end

        %-------
        % Centroid Index Measure
        %-------
        function obj = centroidMeasure(obj, eigenvalue, eigenvector, gt)
            obj = csi(obj, eigenvalue, eigenvector, gt);
        end

        %-------
        % Assign a unit to each data point
        %-------
        function obj = predict(obj,data)
            obj.y_pred = pred(obj,data);
        end

        %-------
        % Normalized Mutual Information
        %-------
        function obj = nmiMeasure(obj,label,data)
            obj.y_pred = pred(obj,data);
            obj.nmi = normalizedmi(obj.y_pred,label);
        end

        %-------
        % Plot predictions - Color plot based on data point assignment
        %-------
        function obj = draw_pred(obj, data)
            % Create a color map
            cmap = hsv(length(obj.candidates));
            % Map the colors to each data point according to their
            % predicated labels
            mappedColors = cmap(mod(obj.y_pred - 1, length(obj.candidates)) + 1, :);
            % Plot the colored data distribution
            scatter(obj.ax, data(:, 1), data(:, 2), 3, mappedColors, 'o', 'filled');
            axis(obj.ax, "equal")
            axis(obj.ax, "manual")
            xlabel(obj.ax, "X")
            ylabel(obj.ax, "Y")
            hold(obj.ax, "on")
            % Plot units
            obj = drawupdate(obj);
        end
        %-------
        % Learningrate history
        %-------
        function obj = learningrate_history(obj)
            for i = 1 : length(obj.units)
                obj.units{i}.lr_history(end+1) = obj.units{i}.learningRate;
            end
        end

    end
end

