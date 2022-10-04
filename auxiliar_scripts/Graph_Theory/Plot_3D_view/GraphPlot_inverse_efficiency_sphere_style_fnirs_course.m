function[] = ...
    GraphPlot_inverse_efficiency_sphere_style_fnirs_course...
    (Graph_Parameter,SSlist)

% Function to plot network parameters in the brain
% 
% Input: 
%   Graph_Parameter: metric/parameter to be plotted. 
%   SSlist: Short channel list. Short channels are not plotted. 


% Check if there are Inf/Nan in the input data. 
% If so, add these NAN to the SSlist so that they 
% are not plotted
dummyInfList = find(Graph_Parameter==Inf)';
dummyNANList = find(isnan(Graph_Parameter)==1)';

SSlist = unique([SSlist,dummyInfList,dummyNANList]);    

Graph_Parameter(SSlist) = nan;

% Load fwMC file
load fwMC_fnirs_course


% Take coordinates based on fwMC
CoorOpt_reg = [];
for nchn = 1:129
    [~,index] = max(fwMC.Adot(nchn,:));
    CoorOpt_reg = [CoorOpt_reg;fwMC.mesh.vertices(index,:)];
end

figure()
%subplot(1,2,1)
background_graph_Image_fnirs_course;

%%% plot Source and Detector Positions
hold on;

% For visual purposes only: 
%The size of each ball increaes as a sigmoid function defined below

alpha = .9;
aux_max = max(max(Graph_Parameter));
x = Graph_Parameter - (alpha*aux_max); 

tam = 15./(1+exp(-1*(x)));

%%% Create a Colormap: the color of each ball has a linear dependency
Colormap = jet(1000);

a = 999/(max(tam)-min(tam));
b = 1 - a*min(tam);

Color_index = round(a*tam +b);

[x,y,z] = sphere(50,50);
for N=1:size(CoorOpt_reg,1)
    
    if isempty(find(N==SSlist)==1)
        surf(tam(N)*x+CoorOpt_reg(N,1),tam(N)*y+CoorOpt_reg(N,2),...
            tam(N)*z+CoorOpt_reg(N,3),'FaceColor',...
            Colormap(Color_index(N),:),'EdgeColor','none');
    end
end



end





