function PlotProbe_Init(hParent)
global plotprobe;

plotprobe = [];

plotprobe.axScl = [1 1];
plotprobe.plotname = [];
plotprobe.tMarkInt = 5;
plotprobe.tMarkAmp = 0;
plotprobe.tMarkShow = 0;
plotprobe.hidMeasShow = 0;
plotprobe.plotCondition_run = 1;
plotprobe.plotCondition = 1;


plotprobe.objs.Data.h = [];
plotprobe.objs.Data.pos = [];

plotprobe.objs.CtrlPanel.h = [];
plotprobe.objs.CtrlPanel.pos = [0 0 1 .18];

plotprobe.objs.TmarkPanel.h = [];
plotprobe.objs.TmarkPanel.pos =  [0.20 0.00 0.30 1.0];

plotprobe.objs.SclPanel.h = [];
plotprobe.objs.SclPanel.pos    = [0.00 0.00 0.20 1.0];

plotprobe.objs.BttnDup.h = [];
plotprobe.objs.BttnDup.pos     = [0.52 0.54 0.15 0.25];

plotprobe.objs.BttnHidMeas.h = [];
plotprobe.objs.BttnHidMeas.pos = [0.52 0.14 0.30 0.25];

%{
scrsz = get(0,'ScreenSize');
rdfx = 2.2;
rdfy = rdfx-.5;
plotprobe.objs.Figure.h = [];
plotprobe.objs.Figure.pos = [1 scrsz(4)/2-scrsz(4)*.2 scrsz(3)/rdfx scrsz(4)/rdfy];
%}

pos = get(hParent,'position');
rdfx = 1.3;
rdfy = 1.3;
offsetx = 20;
offsety = 20;
plotprobe.objs.Figure.h = [];
plotprobe.objs.Figure.pos = [pos(1)+offsetx pos(2)+offsety pos(3)/rdfx pos(4)/rdfy];

