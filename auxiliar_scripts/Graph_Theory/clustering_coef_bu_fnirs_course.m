function[C_final] = clustering_coef_bu_fnirs_course(G,SSlist)
%CLUSTERING_COEF_BU     Clustering coefficient
%
%   C = clustering_coef_bu(A);
%
%   The clustering coefficient is the fraction of triangles around a node
%   (equiv. the fraction of node?s neighbors that are neighbors of each other).
%
%   Input:      A,      binary undirected connection matrix
%
%   Output:     C,      clustering coefficient vector
%
%   Reference: Watts and Strogatz (1998) Nature 393:440-442.
%
%
%   Mika Rubinov, UNSW, 2007-2010

C_final = nan*zeros(length(G),1);

% Remove SSlist entries
chan_index = 1:1:length(G);
chan_index(SSlist) = [];


G(SSlist,:) = [];
G(:,SSlist) = [];

n=length(G);
C=zeros(n,1);

for u=1:n
    V=find(G(u,:));
    k=length(V);
    if k>=2;                %degree must be at least 2
        S=G(V,V);
        C(u)=sum(S(:))/(k^2-k);
    end
end

cnt = 0;
for Nchan = chan_index
   
   cnt = cnt+1;
   C_final(Nchan) = C(cnt);       
    
end



end