function [A,K1] = adjacency_matrix(p,C1)
% This function calculates the Adjacency Matrix from an
% undirected and unweighted Newtork
%
% Input: Threshhold and Correlation Matrix (n,n)
%
% Output: The Adjaceny matrix and the Degree of each node;
%
%
% LOB - IFGW
% Univeristy of Campinas
N = length(C1);
%A(k,:,:) = C_T1;
A = C1;
for m=1:N
    A(m,m)=0;
end


for i = 1:N
    for j = 1:N
        if A(i,j) >= p
            A(i,j) = 1;
        else A(i,j) = 0;
        end
    end
end

K1 = sum(A);
end