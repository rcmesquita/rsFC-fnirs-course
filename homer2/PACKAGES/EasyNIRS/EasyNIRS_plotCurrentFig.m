function [hf plotname]=EasyNIRS_plotCurrentFig()

hf=figure;
set(hf,'color',[1 1 1]);

% DISPLAY DATA
ha=axes('position',[0.05 0.05 0.6 0.9]);
plotname = EasyNIRS_DisplayData(ha);

% DISPLAY SDG
ha=axes('position',[0.65 0.05 0.3 0.9]);
EasyNIRS_plotAxesSDG(ha);
axis off

