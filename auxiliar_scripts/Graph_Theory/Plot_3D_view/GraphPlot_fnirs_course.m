function[] = GraphPlot_fnirs_course(CorrelationMatrix,ROI,limit)
% Load fwMC file
load fwMC_fnirs_course

% Load Coordinates of each Channels
%load opt_Reg.mat


% Take coordinates based on fwMC
CoorOpt_reg = [];
for nchn = 1:129
    [~,index] = max(fwMC.Adot(nchn,:));
    CoorOpt_reg = [CoorOpt_reg;fwMC.mesh.vertices(index,:)];
end


%%% Top View Brain Hemisphere
%%%-----------------------------------------------------------------------

figure()
axis off

patch('Vertices',fwMC.mesh.vertices,...
    'SpecularStrength',0.12,...
    'DiffuseStrength',0.9,...
    'AmbientStrength',0.2,...
    'Faces',fwMC.mesh.faces,...
    'EdgeAlpha',0,'FaceColor',[1 1 1],...
    'FaceLighting','phong','FaceAlpha',.5);

% Set the remaining axes properties
set(gca,'CameraPosition',...
    [-78.544945992385 545.692074826472 4604.59793108604],'CameraTarget',...
    [129.6960774264 138.177489128 141.54136287528],'CameraUpVector',...
    [0.00734845636125674 0.995861375240189 -0.0905876453708009],...
    'CameraViewAngle',2.2124039229879,'DataAspectRatio',[1 1 1],...
    'LineStyleOrderIndex',50,'PlotBoxAspectRatio',...
    [1 1.18303201283536 1.08555630447355]);


% Create light
light(gca,...
    'Position',[-12.1761048068871 -21.0403042499821 -10.584375361544],...
    'Style','local',...
    'Color',[0.4 0.4 0.4]);

% Create light
light(gca,...
    'Position',[-12.1761048068871 -21.0403042499821 285.939319434555],...
    'Style','local',...
    'Color',[0.4 0.4 0.4]);

% Create light
light(gca,...
    'Position',[-12.1761048068871 293.129906236909 -10.584375361544],...
    'Style','local',...
    'Color',[0.4 0.4 0.4]);

% Create light
light(gca,...
    'Position',[-12.1761048068871 293.129906236909 285.939319434555],...
    'Style','local',...
    'Color',[0.4 0.4 0.4]);

% Create light
light(gca,...
    'Position',[268.858903682521 -21.0403042499821 -10.584375361544],...
    'Style','local',...
    'Color',[0.4 0.4 0.4]);

% Create light
light(gca,...
    'Position',[268.858903682521 -21.0403042499821 285.939319434555],...
    'Style','local',...
    'Color',[0.4 0.4 0.4]);

% Create light
light(gca,...
    'Position',[268.858903682521 293.129906236909 -10.584375361544],...
    'Style','local',...
    'Color',[0.4 0.4 0.4]);

% Create light
light(gca,...
    'Position',[268.858903682521 293.129906236909 285.939319434555],...
    'Style','local',...
    'Color',[0.4 0.4 0.4]);


%%% plot Source and Detector Positions
hold on;
% plot3(CoorOpt_reg(:,1),CoorOpt_reg(:,2),CoorOpt_reg(:,3),'o',...
%     'MarkerFaceColor',[0.1 0.1 0.1],'MarkerSize',8,'MarkerEdgeColor',...
%     [0.1 0.1 0.1]);

tam = 3;

[x,y,z] = sphere(50,50);
for N=1:size(CoorOpt_reg,1)
    surf(tam*x+CoorOpt_reg(N,1),tam*y+CoorOpt_reg(N,2),...
        tam*z+CoorOpt_reg(N,3),'FaceColor',...
        [0.3 0.3 0.3],'EdgeColor','none');
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

for Nchan=1:129
    
    for Nchan2 = 1:129
        
        if Nchan2>Nchan
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
end
