function obj = drawPlotProbeControlsPanel(obj,hFig)

if ~isempty(obj.h)
    return;
end

figure(hFig);
color_fig = get(hFig,'color');

obj.h = uipanel('parent',hFig,'units','normalized',...
                'position',obj.pos,'fontsize',10,...
                'backgroundcolor',color_fig);
