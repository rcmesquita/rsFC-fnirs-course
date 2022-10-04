function [A,K1] = adjacency_matrix_fnirs_course(C,p,SSlist)
% This function calculates the Adjacency Matrix from an
% undirected and unweighted Newtork. 
%
% Input: 
%       C - Correlation Matrix for specific hemoglobin
%       p - Threshold to binarize the correlation matrix
%       SSlist - List of Short Channels
%
%
% Output: The Adjaceny matrix and the Degree of each node;
%
%

A = C;

for m=1:size(A,1)
    A(m,m)=0;
end

for i = 1:size(A,1)
    for j = 1:size(A,1)
        if A(i,j) >= p
            A(i,j) = 1;
        else
            A(i,j) = 0;
        end
    end
end

% Assign short channel enties as nan
A(SSlist,:) = nan;
A(:,SSlist) = nan;

K1 = nansum(A);



end