function[] = GraphPlot_links_fnirs_course(A,SSlist)

% Load fwMC file
load fwMC_fnirs_course

% Take coordinates based on fwMC
CoorOpt_reg = [];
for nchn = 1:129
    [~,index] = max(fwMC.Adot(nchn,:));
    CoorOpt_reg = [CoorOpt_reg;fwMC.mesh.vertices(index,:)];
end

figure()
background_graph_Image_fnirs_course;

%%% plot Source and Detector Positions
hold on;

tam = 3;

[x,y,z] = sphere(50,50);
for N=1:size(CoorOpt_reg,1)
    if isempty(find(N==SSlist)==1)
        surf(tam*x+CoorOpt_reg(N,1),tam*y+CoorOpt_reg(N,2),...
            tam*z+CoorOpt_reg(N,3),'FaceColor',...
            [0.3 0.3 0.3],'EdgeColor','none');
    end
    
end

% Change Color Node for ROI
tam = 8;
for N=1:size(ROI,2)
    surf(tam*x+CoorOpt_reg(ROI(N),1),tam*y+CoorOpt_reg(ROI(N),2),...
        tam*z+CoorOpt_reg(ROI(N),3),'FaceColor',...
        'b','EdgeColor','none');
end



%%% Create a Colormap
Colormap = jet(1000);

% line equation for color
% F(x) = ax + b;

a = 999/(limit(2)-limit(1));
b = 1 - a*limit(1);



% Draw Link between channels
% For drawing it, I will do tube with surf plot
% The width of the tube is gonna be proportional to the
% correlation value.

for Nchan=ROI
    
    for Nchan2 = 1:129
        
        if CorrelationMatrix(Nchan,Nchan2)>0
            
            P1 = CoorOpt_reg(Nchan,:);
            P2 = CoorOpt_reg(Nchan2,:);
            
            value = CorrelationMatrix(Nchan,Nchan2);
            
            if value>limit(2)
                
                value = limit(2);
                
            end
            
            if value<limit(1)
                
                value = limit(1);
                
            end
            
            % Define Color
            color = round(a*value +b);
            
            DrawTubes(P1,P2,Colormap(color,:));
            
        end
        
        
    end
end
