function[L,L_std] = average_pathlength(D)

N = length(D);
% L=0;
% for i=1:N
%     for j=1:N
%         if j>i
%             L = L+D(i,j);
%         end
%     end
% end
% L = 2*L/(N*(N-1));


nD = D;
for i=1:N
    clear lst
    lst = find(isinf(nD(:,i)));
    nD(lst,i)=NaN;
end

for i=1:N
    N_inf = length ( find(isnan(nD(:,i)))) + 1;
    avg_path(i,1) = sum(nD(:,i),'omitnan') / (N - N_inf);
end
clear lst 
lst = length(find( isnan(avg_path) ));
L = sum(avg_path,'omitnan')/(length(avg_path)-lst);
L_std = nanstd(avg_path);

return
