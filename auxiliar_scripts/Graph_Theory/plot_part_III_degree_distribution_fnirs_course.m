function[] = plot_part_III_degree_distribution_fnirs_course(degree,SSlist)

% Plot degree distribution
figure
degree_aux = degree;
degree_aux(SSlist) = [];

[counts bins] = hist(degree_aux);
semilogy(bins, counts/sum(counts),'-k');
grid on;
xlabel('Degree')
ylabel('Probability')
title('Degree Distribution')
set(gca,'FontName','Times','FontSize',14);


end
