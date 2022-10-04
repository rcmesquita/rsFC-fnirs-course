function hData = plotProbeAndSetProperties(hFig)
global plotprobe

y        = plotprobe.y;
tHRF     = plotprobe.tHRF;
SD       = plotprobe.SD;
tMarkInt = plotprobe.tMarkInt;
axScl    = plotprobe.axScl;
bit0     = plotprobe.tMarkShow;
bit1     = plotprobe.hidMeasShow;
TmarkPanel = plotprobe.objs.TmarkPanel;
tMarkAmp = plotprobe.tMarkAmp;

[hData hf tMarkAmp] = plotProbe( y, tHRF, SD, hFig, [], axScl, tMarkInt, tMarkAmp );
showHiddenObjs( 2*bit1+bit0, SD, y, hData );

plotprobe.tMarkAmp = tMarkAmp;
