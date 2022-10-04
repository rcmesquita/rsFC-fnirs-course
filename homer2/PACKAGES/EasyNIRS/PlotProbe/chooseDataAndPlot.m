function chooseDataAndPlot(handles)

global plotprobe;
global HRF_OFF_CONST
global HRF_GRP_CONST
global HRF_SESS_CONST
global HRF_RUN_CONST

procResult_all = plotprobe.procResult_all;
SD             = plotprobe.SD;
iSubj          = plotprobe.currInd(3);
axScl          = plotprobe.axScl;
tMarkInt       = plotprobe.tMarkInt;
tMarkAmp       = plotprobe.tMarkAmp;
tMarkShow      = plotprobe.tMarkShow;
hidMeasShow    = plotprobe.hidMeasShow;
CtrlPanel      = plotprobe.objs.CtrlPanel;
SclPanel       = plotprobe.objs.SclPanel;
BttnDup        = plotprobe.objs.BttnDup;
BttnHidMeas    = plotprobe.objs.BttnHidMeas;
TmarkPanel     = plotprobe.objs.TmarkPanel;
hFig           = plotprobe.objs.Figure.h;

hData = [];

%%%% Find the correct data to plot
if plotprobe.plotHRF==HRF_GRP_CONST

    procResult = procResult_all{1};
    iCond = plotprobe.plotCondition;
    if iCond>size(procResult.nTrials,2)
        menu('No HRF has yet been calculated for this condition.','OK');
        if ishandles(hFig)
            delete(hFig);
        end
        return;
    end
    iCond_run = plotprobe.plotCondition_run;
    SD = getMeasListAct(SD, procResult_all, iCond, iCond_run, iSubj, 'group');
    plotname = plotprobe.grpName;
    tHRF = procResult.tHRF;

elseif plotprobe.plotHRF==HRF_SESS_CONST

    procResult = procResult_all{2};
    iCond = plotprobe.plotCondition;
    if iCond>size(procResult.nTrials,2)
        menu('No HRF has yet been calculated for this condition.','OK');
        if ishandles(hFig)
            delete(hFig);
        end
        return;
    end
    iCond_run = plotprobe.plotCondition_run;
    SD = getMeasListAct(SD, procResult_all, iCond, iCond_run, iSubj, 'subj');    
    plotname = plotprobe.subjName;
    tHRF = procResult.tHRF;

elseif plotprobe.plotHRF==HRF_RUN_CONST

    procResult = procResult_all{3};
    iCond = plotprobe.plotCondition_run;
    SD = getMeasListAct(SD, procResult_all, iCond, iCond, iSubj, 'run');
    plotname = plotprobe.runName;
    tHRF = procResult.tHRF;

else

    return;

end



%%%% Plot data
if plotprobe.plotOD == 1

    % plot the OD HRF in probe format
    if iCond~=0
        y = procResult.dodAvg(:,:,iCond);
    else
        dSize = size(procResult.dodAvg(:,:,1));
        y = zeros(dSize(1),dSize(2),1)./0;
    end
    [hData, hFig, tMarkAmp] = plotProbe( y, tHRF, SD, hFig, [], axScl, tMarkInt, tMarkAmp );
    plotname = [plotname '_ODAvg_plotProbe'];
    
elseif plotprobe.plotConc == 1

    % plot the conc HRF in probe format
    if iCond~=0
        y = procResult.dcAvg(:,:,:,iCond);
    else
        dSize = size(procResult.dcAvg(:,:,:,1));
        y = zeros(dSize(1),dSize(2),dSize(3),1)./0;
    end
    [hData, hFig, tMarkAmp] = plotProbe( y, tHRF, SD, hFig, [], axScl, tMarkInt, tMarkAmp );
    plotname = [plotname '_ConcAvg_plotProbe'];
end

if isempty(hData)
    return;
end

%%%% Modify and add graphics objects in plot probe figure
CtrlPanel    = drawPlotProbeControlsPanel( CtrlPanel, hFig );
SclPanel     = drawPlotProbeScale( SclPanel, CtrlPanel.h, axScl, hFig );
BttnDup      = drawPlotProbeDuplicate( BttnDup, CtrlPanel.h, hFig );
BttnHidMeas  = drawPlotProbeHiddenMeas( BttnHidMeas, CtrlPanel.h, hidMeasShow, hFig );
TmarkPanel   = drawPlotProbeTimeMarkers( TmarkPanel, CtrlPanel.h, tMarkInt, tMarkAmp, ...
                                         tMarkShow, hFig );
showHiddenObjs( 2*hidMeasShow+tMarkShow, SD, y, hData );


%%%%% Save plot probe to a file if option is enabled
if strcmp(get(handles.menuAutosavePlotFigsToFile,'checked'),'on')
    print(hFig,'-djpeg99',[plotname '.jpg']);
end


%%%%% Save handles of all objects in plotProbe
plotprobe.y                = y;
plotprobe.tHRF             = procResult.tHRF;
plotprobe.SD               = SD;
plotprobe.objs.CtrlPanel   = CtrlPanel;
plotprobe.objs.SclPanel    = SclPanel;
plotprobe.objs.BttnDup     = BttnDup;
plotprobe.objs.BttnHidMeas = BttnHidMeas;
plotprobe.objs.TmarkPanel  = TmarkPanel;
plotprobe.objs.Data.h      = hData;
plotprobe.tMarkAmp         = tMarkAmp;



% ----------------------------------------------------------------------
function SD = getMeasListAct(SD,procResults,iCond,iCond_run,iSubj,level)

procResult_group = procResults{1};
procResult_subj = procResults{2};
procResult_run = procResults{3};

switch level
case {'group'}
    a1=2; a2=2;
case {'subj'}
    a1=2; a2=0;
case {'run'}
    a1=0;
end

if iCond_run==0 || iCond_run>size(procResult_run.nTrials,2) || procResult_run.nTrials(iCond_run)==0
    SD.MeasListAct = zeros(length(SD.MeasListAct),1);
end
MeasListAct_manual = SD.MeasListAct;
if isfield(procResult_run,'SD') & isfield(procResult_run.SD,'MeasListAct')
    MeasListAct_auto = procResult_run.SD.MeasListAct;
else
    MeasListAct_auto = ones(length(SD.MeasListAct),1);
end
SD.MeasListAct = uint8(MeasListAct_manual & MeasListAct_auto);    
k = find(SD.MeasListAct==0);
SD.MeasListAct(k) = a1;
    
if ~isempty(procResult_group.grpAvgPass) && strcmp(level,'group')
    grpAvgPass = procResult_group.grpAvgPass;
    k = find(grpAvgPass(:,iCond,iSubj)==0);
    SD.MeasListAct(k) = a2;   
end

