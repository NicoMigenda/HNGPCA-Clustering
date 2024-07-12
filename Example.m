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
% "zeta_init"         - >=1       - 100     - Initial value of number of update cycles between split operations
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
load('s1.mat','data','gt','label','eigenvalues','eigenvectors');    

% Init the root unit and the 2 unborn children. Optionally set number of
% iterations
hngpca = init_units(hngpca, data, 'iterations', 35000);

% Train the hngpca network
hngpca = fit_multiple(hngpca, data);

% Draw
scatter(data(:, 1), data(:, 2), 5, 'o', 'filled');
axis equal
axis manual
hold on
hngpca.draw();
