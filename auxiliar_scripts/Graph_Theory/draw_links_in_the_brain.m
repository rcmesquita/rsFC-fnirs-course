function[] = draw_links_in_the_brain(A,CoorOpt_reg,SSlist)

tam = 3;
[x,y,z] = sphere(50,50);
for N=1:size(CoorOpt_reg,1)
    
    if isempty(find(N==SSlist)==1)
        surf(tam*x+CoorOpt_reg(N,1),tam*y+CoorOpt_reg(N,2),...
            tam*z+CoorOpt_reg(N,3),'FaceColor',...
            [0.3 0.3 0.3],'EdgeColor','none');
    end
end


for Nchan=1:129
    
    for Nchan2 = 1:129
        
        if Nchan2>Nchan
            if  A(Nchan,Nchan2)>0
                
                P1 = CoorOpt_reg(Nchan,:);
                P2 = CoorOpt_reg(Nchan2,:);
                
                DrawTubes(P1,P2,[0.3 0.3 0.3]);
                
            end
            
        end
        
    end
end




end