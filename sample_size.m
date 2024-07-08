%%
% Determine the sample size for the experiments
%%

close all
clear variables

% Effect size
delta = 0.25;
% Type 2 Error
beta = 0.05;
% Type 1 Error
alpha = 0.05;

% Number of algorithms to be tested
num_m = 13;
% Number of data sets to be tested
num_s = 16;

% Number of individual comparisons 
k = num_m*(num_m-1)/2;
% Bonferroni correction
alphaK = alpha/k;

zbeta = norminv(beta);
zalphaK = norminv(1-alphaK/2);

s = ((zbeta-zalphaK)/delta)^2;

% Number of runs per data set
s_single = s/num_s;

disp(ceil(s_single))

