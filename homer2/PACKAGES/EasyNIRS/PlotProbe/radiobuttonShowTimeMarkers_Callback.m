function radiobuttonShowTimeMarkers_Callback(hObject,evendata,handles)
global plotprobe

bit0 = get(hObject,'value');
plotprobe.tMarkShow = bit0;
bit1 = plotprobe.hidMeasShow;
TmarkPanel = plotprobe.objs.TmarkPanel;

SD = plotprobe.SD;
y = plotprobe.y;
h = plotprobe.objs.Data.h;

guiSettings = 2*bit1 + bit0;
showHiddenObjs(guiSettings,SD,y,h);
