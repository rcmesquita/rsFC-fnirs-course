function editPlotProbeAxScl_Callback(hObject, eventdata, handles)
global plotprobe

hFig   = plotprobe.objs.Figure.h;

foo = str2num( get(hObject,'string') );
if length(foo)<2
    foo = plotprobe.axScl;
elseif foo(1)<=0 | foo(2)<=0
    foo = plotprobe.axScl;
end    
plotprobe.axScl = foo;
set(hObject,'string', sprintf('%0.1f %0.1f', plotprobe.axScl) );
hData = plotProbeAndSetProperties(hFig);

plotprobe.objs.Data.h = hData;
