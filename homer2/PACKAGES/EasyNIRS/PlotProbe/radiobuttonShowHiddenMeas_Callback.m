function radiobuttonShowHiddenMeas_Callback(hObject,handles)
global plotprobe

bit1 = get(hObject,'value');
plotprobe.hidMeasShow = bit1;
bit0 = plotprobe.tMarkShow;

SD = plotprobe.SD;
y = plotprobe.y;
h = plotprobe.objs.Data.h;

guiSettings = 2*bit1 + bit0;
showHiddenObjs(guiSettings,SD,y,h);

