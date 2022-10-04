function[] = plot_part_cor_adj_fnirs_course(CorrMatrix,A)

% Input:
%   CorrMatrix: Correlation Matrix
%   A: Adjacency Matrix (binary and unweighted)

% Plot Correlation and Adjacency Matrices for HbT
figure('Renderer', 'painters', 'Position', [50 100 900 300]);
subplot_1 = subplot(1,2,1);
imagesc(CorrMatrix,[-1 1]);
colormap(subplot_1,jet);
title('Correlation Matrix: HbT');


subplot_2 = subplot(1,2,2);
imagesc(A,[0 1]);
colormap(subplot_2,gray)
title('Adjacency Matrix');

end

