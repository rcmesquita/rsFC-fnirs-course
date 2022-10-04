function[] = ...
    plot_graph_sphere_style_with_links_fnirs_course(A,SSlist)

% Load fwMC file
load fwMC_fnirs_course


% Take coordinates based on fwMC
CoorOpt_reg = [];
for nchn = 1:129
    [~,index] = max(fwMC.Adot(nchn,:));
    CoorOpt_reg = [CoorOpt_reg;fwMC.mesh.vertices(index,:)];
end


figure()
subplot(1,3,3)
background_graph_Image_fnirs_course;
hold on;
draw_links_in_the_brain(A,CoorOpt_reg,SSlist);

set(gca,'CameraPosition',...
    [4465.88633611231 -122.094067886442 1263.15589092293],'CameraTarget',...
    [129.6960774264 138.177489128 141.54136287528],'CameraUpVector',...
    [-0.228800956760502 0.24649272775698 0.941749147782148],'CameraViewAngle',...
    1.85583529548837,'DataAspectRatio',[1 1 1],'LineStyleOrderIndex',50,...
    'PlotBoxAspectRatio',[1 1.18303201283536 1.08555630447355]);



subplot(1,3,2)
background_graph_Image_fnirs_course;
hold on;
draw_links_in_the_brain(A,CoorOpt_reg,SSlist);

subplot(1,3,1)
background_graph_Image_fnirs_course;
hold on;
draw_links_in_the_brain(A,CoorOpt_reg,SSlist);
set(gca,'CameraPosition',...
    [-4293.28582052796 792.180042497397 512.780077175186],'CameraTarget',...
    [129.6960774264 138.177489128 141.54136287528],'CameraUpVector',...
    [0.116422989695643 0.240336181114654 0.963682628004444],'CameraViewAngle',...
    1.85583529548837,'DataAspectRatio',[1 1 1],'LineStyleOrderIndex',50,...
    'PlotBoxAspectRatio',[1 1.18303201283536 1.08555630447355]);



end





