%%% Create a Colormap
Colormap = jet(1000);
%Color_index = round(a*Graph_Parameter +b);

corr_values(corr_values>limit(2)) = limit(2);
corr_values(corr_values<limit(1)) = limit(1);

a = 999/(limit(2)-limit(1));
b = 1 - a*limit(1);

Color_index = round(a*corr_values +b);


tam = 4;
[x,y,z] = sphere(50,50);
for N=1:size(CoorOpt_reg,1)
    
    if isempty(find(N==SSlist)==1)
        surf(tam*x+CoorOpt_reg(N,1),tam*y+CoorOpt_reg(N,2),...
            tam*z+CoorOpt_reg(N,3),'FaceColor',...
            Colormap(Color_index(N),:),'EdgeColor','none');
        
        % Roi will be black to contrast better
        if N==Roi
           surf(tam*x+CoorOpt_reg(N,1),tam*y+CoorOpt_reg(N,2),...
            tam*z+CoorOpt_reg(N,3),'FaceColor',...
            [0 0 0],'EdgeColor','none');
            
        end
    end
end



