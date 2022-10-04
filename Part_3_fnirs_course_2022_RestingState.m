% fNIRS course 2022!
%
% Part III - Graph Theory
%   Adjacency Matrix,
%   Degree,   
%   Clustering Coefficient,
%   Local Efficiency,
%   Inverse of Local Efficiency

% Clear environment
clear

% load data for Part III
load('Data_for_Part_III.mat');

% Define which heoglobin should be analyzed:
% 1 - HbO, 2 - HbR, and 3 - HbT.  
ChosenHb = 3;

% Correlation Matrix
CorrMatrix = C_SC_Phys(:,:,ChosenHb);

% Define a threshold to binarize the 
% Correlation Matrix 
threshold = 0.3;

% Compute Adjacency Matrix the chosen hemoglobin and 
% defined threshold
[A, ~] = adjacency_matrix_fnirs_course...
    (CorrMatrix,threshold,SSlist);

% Plot Correlation and Adjacency Matrix
plot_part_3_cor_adj_fnirs_course(CorrMatrix,A)

% Plot graph in the brain
plot_graph_sphere_style_with_links_fnirs_course(A,SSlist)


% *** Network/Graph Properties

% Compute Node degree
degree = nansum(A,2);

% Clustering coefficient
clustering = ...
    clustering_coef_bu_fnirs_course(A,SSlist);

% Local efficiency
local_efficieny = ...
    efficiency_bin_fnirs_course(A,1,SSlist);


%%% *** Plot properties in the brain

% Plot the degree of each node
GraphPlot_parameter_sphere_style_fnirs_course...
    (clustering,SSlist,2);
title('degree');

% Plot Clustering Coefficient
GraphPlot_parameter_sphere_style_fnirs_course...
    (clustering,SSlist,4);
title('clustering');

% Plot Local efficiency
GraphPlot_parameter_sphere_style_fnirs_course...
    (local_efficieny,SSlist,4);
title('Local efficiency');

% Plot the inverse of the local efficiency
GraphPlot_parameter_sphere_style_fnirs_course...
    (1./local_efficieny,SSlist,1);
title('Inverse of Local Efficiency');



