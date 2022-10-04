function editPlotProbeTimeMarkersAmp_Callback(hObject, eventdata, handles)
global plotprobe

plotprobe.tMarkAmp = str2num(get(hObject,'string'));
if plotprobe.plotConc;
    plotprobe.tMarkAmp = plotprobe.tMarkAmp/1e6;
end

hFig   = plotprobe.objs.Figure.h;

hData = plotProbeAndSetProperties(hFig);
plotprobe.objs.Data.h = hData;
