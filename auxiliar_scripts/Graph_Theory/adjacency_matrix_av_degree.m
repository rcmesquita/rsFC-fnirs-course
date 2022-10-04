function [A,av_K1,K1] = adjacency_matrix_av_degree(p,C1)

% This function calculates the Average Degree of an
% undirected and unweighted Newtork
%
% Input: Threshhold and Correlation Matrix (n,n)
%
% Output: The adjacency matrix and The Average Degree and its error;
%
%
% LOB - IFGW
% Univeristy of Campinas

[A,K1] = adjacency_matrix(p,C1);
K1 = K1';
%     a = find(K1==0);
%     K1(a) = NaN;
%     av_K1 = nanmean(K1);
%     error = nanstd(K1);
%     error = error/sqrt(length(C1) - length(a));
%


av_K1 = mean(K1);
%error = std(K1);


end