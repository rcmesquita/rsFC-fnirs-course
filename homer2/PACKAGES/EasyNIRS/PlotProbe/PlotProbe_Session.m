function hFig = PlotProbe_Session(hmr, gui_enable, handles)
global plotprobe


% Get current listboxFiles selection and the 
% group level
[iFile i j k] = listboxFiles_getCurrSelection(handles);
i = get(handles.popupmenuGroupList,'value');

plotprobe.SD = hmr.SD;
plotprobe.currInd = [iFile i j k];
plotprobe.procResult_all{1} = hmr.group(i).procResult;
plotprobe.procResult_all{2} = hmr.group(i).subjs(j).procResult;
plotprobe.procResult_all{3} = hmr.procResult;
plotprobe.plotCondition_run = hmr.group(i).conditions.CondRunIdx(iFile,hmr.plotCondition);
plotprobe.plotCondition = hmr.plotCondition;
plotprobe.plotHRF = hmr.plotHRF;
plotprobe.plotOD = hmr.plotOD;
plotprobe.plotConc = hmr.plotConc;
plotprobe.grpName = hmr.group(i).name;
plotprobe.subjName = hmr.group(i).subjs(j).name;
k=findstr(hmr.filename,'.nirs');    
plotprobe.runName = hmr.filename(1:k-1);
if hmr.flagPlotRange==true
    plotprobe.tMarkAmp = hmr.plotRange*1e-6;
else
    plotprobe.tMarkAmp = 0;
end

hFig = [];
if(gui_enable==1 & (isempty(plotprobe.objs.Figure.h) || ...
                    ~ishandle(plotprobe.objs.Figure.h)))

    hFig = figure;
    p = plotprobe.objs.Figure.pos;
    set(hFig, 'position', p);
    set(hFig,'DeleteFcn',@PlotProbe_DeleteFcn);
    xlim([0 1]);
    ylim([0 1]);
    plotprobe.objs.Figure.h = hFig;

elseif(gui_enable==0 & ishandle(plotprobe.objs.Figure.h))

    % Record latest plotProbe position and size in plotprobe
    % variable. This will be the next position/size parameters
    % next time plotProbe is activated.
    pos = get(plotprobe.objs.Figure.h,'position');
    plotprobe.objs.Figure.pos = pos;
    delete(plotprobe.objs.Figure.h);
    plotprobe.objs.Figure.h = [];
    return;

elseif gui_enable==1
    
    hFig = plotprobe.objs.Figure.h;
    
elseif gui_enable==0
    
    return;

end
chooseDataAndPlot(handles);

