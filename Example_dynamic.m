%%%
% H-NGPCA: Hierarchical Clustering of Data Streams with 
% Adaptive Number of Clusters and Dimensionality
%%%

%% 
clear variables
close all
addpath('hngpca', 'data');
% Reproducability
rng(0)

%% Create the H-NGPCA object
% Parameters - Not case sensitive
% Name                - Range     - Default - Description
% "potentialfunction" - "H", "N"  - "H"     - Defines the potential function used during the ranking process
% "learningrate"      - [0,1]     - 0.99    - Defines the initial learning rate for all units
% "psi"               - [0,1]     - 0.98    - Defines the % the children need to be better than the parent
% "mu"                - [0,1]     - 0.005   - Low pass filter
% "dimthreshold"      - [0,1]     - 0.99    - Defines the % of variance that has to be maintained
% "protect"           - >=1       - 50      - Unit specific number of update cycles before the dimensionality can be updated
hngpca = HNGPCA();

%% Load data - The provided .mat files contain:
% The example data set (S1) is taken from https://cs.joensuu.fi/sipu/datasets/
% Cite the database as: P. Fänti and S. Sieranoja, K-means properties on six clustering benchmark datasets, 
% Applied Intelligence, 48 (12), 4743-4759, December 2018 https://doi.org/10.1007/s10489-018-1238-7
% Name      - Description
% Filename  - Filename containing the data
% Data      - Training data
% gt        - Ground truth cluster centers used for CI
% Eigenvectors and Eigenvalues used for CI
% label     - Data point labels used for NMI and DU
load rls.mat;    

% Init units  
hngpca = init_units(hngpca, square, 'iterations', 7500);

% Train the hngpca network - Initially on the square and line data points
hngpca = fit_multiple(hngpca, [square; line]);
scatter([square(:,1); line(:,1)], [square(:,2); line(:,2)], 5, 'o', 'filled');
axis equal
axis manual
hold on
hngpca.draw();
hold off

% Add the circle to the training data 
% The iterations are increased as the data size increased
% Zeta is increased to prevent splits during the readjustment
figure
rng(0)
hngpca.iterations = 22000;
hngpca.zeta_init = 230;
hngpca = fit_multiple(hngpca, data);
scatter(data(:, 1), data(:, 2), 5, 'o', 'filled');
axis equal
axis manual
hold on
hngpca.draw();
hold off

% Plot learning rate of specific units that existed before the data
% distribution change and after
figure;
ylabel("$\epsilon_j$", "Interpreter", "latex")
xlabel("Data points", "Interpreter", "latex")
xline(7500, "LineStyle",":")
hold on
for i = [1,2,3,5]
    plot(hngpca.units{i}.lr_history)
end
legend('Dist. change t=7500','Unit 1', 'Unit 2', 'Unit 3', 'Unit 5')