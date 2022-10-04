function plotname = EasyNIRS_DisplayData(displayAxes)
global hmr
global HRF_OFF_CONST
global HRF_GRP_CONST
global HRF_SESS_CONST
global HRF_RUN_CONST

if ~exist('displayAxes','var') || isempty(displayAxes)
    displayAxes = hmr.handles.displayAxes;
end

if isempty(displayAxes)
    return;
end

sclConc = 1e6; % convert Conc from Molar to uMolar

axes(displayAxes(1))
cla

if(ishandle(hmr.stim.LegendHdl))
   delete(hmr.stim.LegendHdl);
   hmr.stim.LegendHdl = -1;
end

d = [];
procResult = [];
plotname = [];

% DISPLAY DATA
if ~isempty(hmr.plotLst)

    %%% Determine which channels' data to plot
    ChLst = hmr.plotLst;
    lst2 = [];
    lst3 = find(hmr.SD.MeasList(:,4)==1);
    for ii=1:length(ChLst);
        lst2(ii) = find(hmr.SD.MeasList(lst3,1)==hmr.SD.MeasList(ChLst(ii),1) & ...
            hmr.SD.MeasList(lst3,2)==hmr.SD.MeasList(ChLst(ii),2) );
    end
    plotLst = lst2;
    nCh = length(lst3);

    %%% Exclude marked time points 
    ChLst = [];
    t = hmr.t;
    nTrials = [];
    if ~hmr.flagShowExcluded & isfield(hmr,'tIncMan')
        tranges = timeExcludeRanges(hmr.tIncMan,t);
        for ii=1:size(tranges,1)
            ChLst = [ChLst; find(t>=tranges(ii,1) & t<=tranges(ii,2))];
        end
    end

    %%% Get the data to be plotted from the procResult of the 
    %%% user-selected node in the group tree
    iF = hmr.listboxFileCurr.iFile;
    i = hmr.listboxFileCurr.iGrp;
    j = hmr.listboxFileCurr.iSubj;
    k = hmr.listboxFileCurr.iRun;
    iS = 0;
    if hmr.plotRaw==1 && k>0
        procResult = hmr.procResult;
        d = hmr.d;
        d(ChLst,:) = NaN;
        k=findstr(hmr.filename,'.nirs');
        plotname = [hmr.filename(1:k-1) '_RawData'];
    elseif hmr.plotOD==1
        if hmr.plotHRF==HRF_OFF_CONST && k>0
            procResult = hmr.procResult;
            d = procResult.dod;
            d(ChLst,:) = NaN;
            k=findstr(hmr.filename,'.nirs');
            plotname = [hmr.filename(1:k-1) '_OD'];
        elseif hmr.plotHRF==HRF_GRP_CONST
            procResult = hmr.group(i).procResult;
            nTrials = procResult.nTrials;
            iS = hmr.plotCondition;

            % Handle case of new conditions being added after HRF calculation
            if iS<=size(nTrials,2)
                d = procResult.dodAvg(:,:,iS);
            else
                dSize = size(procResult.dodAvg(:,:,1));
                d = zeros(dSize(1),dSize(2),1)./0;
            end
            t = procResult.tHRF;
            plotname = [hmr.group(i).name '_ODAvg'];
        elseif hmr.plotHRF==HRF_SESS_CONST
            procResult = hmr.group(i).subjs(j).procResult;
            nTrials = procResult.nTrials;
            iS = hmr.plotCondition;

            % Handle case of new conditions being added after HRF calculation
            if iS<=size(nTrials,2)
                d = procResult.dodAvg(:,:,iS);
                if hmr.plotHRFStdErr==1
                    dStd = procResult.dodAvgStd(:,:,iS);
                end
            else
                dSize = size(procResult.dodAvg(:,:,1));
                d = zeros(dSize(1),dSize(2),1)./0;
                if hmr.plotHRFStdErr==1
                    dStd = zeros(dSize(1),dSize(2),1)./0;
                end             
            end
            t = procResult.tHRF;
            plotname = [hmr.group(i).subjs(j).name '_ODAvg'];
        elseif hmr.plotHRF==HRF_RUN_CONST
            procResult = hmr.procResult;
            iS = hmr.group(i).conditions.CondRunIdx(iF,hmr.plotCondition);
            if iS>0 && iS<=size(procResult.nTrials,2)
                d = procResult.dodAvg(:,:,iS);
                if hmr.plotHRFStdErr==1
                    dStd = procResult.dodAvgStd(:,:,iS);
                end 
            else
                dSize = size(procResult.dodAvg(:,:,1));
                d = zeros(dSize(1),dSize(2),1)./0;
                if hmr.plotHRFStdErr==1
                    dStd = zeros(dSize(1),dSize(2),1)./0;
                end             
            end
            t = procResult.tHRF;
            nTrials = procResult.nTrials;
            k=findstr(hmr.filename,'.nirs');
            plotname = [hmr.filename(1:k-1) '_ODAvg'];
        end
    elseif hmr.plotConc==1
        if hmr.plotHRF==HRF_OFF_CONST && k>0
            procResult = hmr.procResult;
            d = procResult.dc * sclConc;
            d(ChLst,:,:) = NaN;
            kk=findstr(hmr.filename,'.nirs');
            plotname = [hmr.filename(1:kk-1) '_Conc'];
        elseif hmr.plotHRF==HRF_GRP_CONST
            procResult = hmr.group(i).procResult;
            nTrials = procResult.nTrials;
            iS = hmr.plotCondition;

            % Handle case of new conditions being added after HRF calculation
            if iS<=size(nTrials,2)
                d = procResult.dcAvg(:,:,:,iS) * sclConc;
            else
                dSize = size(procResult.dcAvg(:,:,:,1));
                d = zeros(dSize(1),dSize(2),dSize(3),1)./0;
            end            
            t = procResult.tHRF;
            plotname = [hmr.group(i).name '_ConcAvg'];
        elseif hmr.plotHRF==HRF_SESS_CONST
            procResult = hmr.group(i).subjs(j).procResult;
            nTrials = procResult.nTrials;
            iS = hmr.plotCondition;

            % Handle case of new conditions being added after HRF calculation
            if iS<=size(nTrials,2)
                d = procResult.dcAvg(:,:,:,iS) * sclConc;
                if hmr.plotHRFStdErr==1
                    dStd = procResult.dcAvgStd(:,:,:,iS) * sclConc;
                end
            else
                dSize = size(procResult.dcAvg(:,:,:,1));
                d = zeros(dSize(1),dSize(2),dSize(3),1)./0;
                if hmr.plotHRFStdErr==1
                    dStd = zeros(dSize(1),dSize(2),dSize(3),1)./0;
                end             
            end
            t = procResult.tHRF;
            plotname = [hmr.group(i).subjs(j).name '_ConcAvg'];
        elseif hmr.plotHRF==HRF_RUN_CONST
            procResult = hmr.procResult;
            iS = hmr.group(i).conditions.CondRunIdx(iF,hmr.plotCondition);
            if iS>0 && iS<=size(procResult.nTrials,2)
                d = procResult.dcAvg(:,:,:,iS) * sclConc;
                if hmr.plotHRFStdErr==1
                    dStd = procResult.dcAvgStd(:,:,:,iS) * sclConc;
                end
            else
                dSize = size(procResult.dcAvg(:,:,:,1));
                d = zeros(dSize(1),dSize(2),dSize(3),1)./0;
                if hmr.plotHRFStdErr==1
                    dStd = zeros(dSize(1),dSize(2),dSize(3),1)./0;
                end             
            end
            t = procResult.tHRF;
            nTrials = procResult.nTrials;
            kk=findstr(hmr.filename,'.nirs');
            plotname = [hmr.filename(1:kk-1) '_ConcAvg'];
        end
    end
    grpAvgPass = hmr.group(i).procResult.grpAvgPass;


    if hmr.plotAux(1)~=0 & hmr.plotHRF==0
        aux = hmr.aux(:,hmr.plotAux);
        aux(ChLst,:) = NaN;
    else
        aux = [];
    end
    
    
    %%% Plot data 
    ChLst = find(hmr.SD.MeasListVis(plotLst)==1);
    if ~isempty(ChLst) && ~isempty(d)
        xx = xlim();
        yy = ylim();
        if strcmpi(get(displayAxes(1),'ylimmode'),'manual')
            flagReset = 0;
        else
            flagReset = 1;
        end
        cla
        hold on
        
        % Set the axes ranges  
        if flagReset==1
                set(displayAxes(1),'xlimmode','auto');
                set(displayAxes(1),'ylimmode','auto');
        else
            xlim(xx);
            ylim(yy);
        end
        
        % set up context menu
        hcmenu = uicontextmenu;
        item1 = uimenu(hcmenu, 'Label', 'Export this trace', 'Callback', 'EasyNIRS_DisplayData_ContextMenu(1)');
        item2 = uimenu(hcmenu, 'Label', 'Export all visible traces', 'Callback', 'EasyNIRS_DisplayData_ContextMenu(2)');

        % Plot data
        if hmr.plotOD || hmr.plotRaw            % plot d or dod
            dold = d;
            lst1 = find(hmr.SD.MeasList(:,4)==1);
            d = zeros(size(dold,1),length(lst1),length(hmr.SD.Lambda));
            if(exist('dStd','var')) 
                dStdold = dStd;
                dStd = zeros(size(dold,1),length(lst1),length(hmr.SD.Lambda));
            end
            for iML = 1:length(lst1)
                for iLambda = 1:length(hmr.SD.Lambda)
                    idx = find(hmr.SD.MeasList(:,1)==hmr.SD.MeasList(lst1(iML),1) & ...
                        hmr.SD.MeasList(:,2)==hmr.SD.MeasList(lst1(iML),2) & ...
                        hmr.SD.MeasList(:,4)==iLambda );
                    d(:,iML,iLambda) = dold(:,idx);
                    if(exist('dStd','var')) 
                        dStd(:,iML,iLambda) = dStdold(:,idx);
                    end
                end
            end                 
%            d = reshape(d,size(d,1),nCh,length(hmr.SD.Lambda));  % THIS ASSUMES AN ORDER TO ml THAT WE MIGHT NOT WANT TO ASSUME
            for iWl=1:length(hmr.plotLambdaLst)
                for ii=1:length(ChLst)
                    dWlMl = squeeze(d( :, plotLst(ChLst(ii)), hmr.plotLambdaLst(iWl)));
                    dWlMl = dWlMl + (ii-1)*hmr.plotWaterfall;
                    h     = plot(t,dWlMl);
                    set(h,'color',hmr.color(ChLst(ii),:));
                    set(h,'linestyle',hmr.linestyle{hmr.plotLambdaLst(iWl)});
                    set(h,'linewidth',2);

                    if ~isContributingHRF(plotLst(ChLst(ii)), iS, nTrials, hmr.plotHRF, [iF,i,j,k]) && ...
                       hmr.plotHRF ~= HRF_OFF_CONST                   
                        set(h,'linewidth',0.5);
                    end
                    
                    % set the context menu for the data traces
                    set(h,'uicontextmenu',hcmenu)
                    
                    % set tag so indicate which SD pair
                    fooC = sprintf('%dnm',hmr.SD.Lambda(hmr.plotLambdaLst(iWl)) );
                    foos = sprintf( 'S%d_D%d_%s',hmr.SD.MeasList(lst1(plotLst(ChLst(ii))),1), ...
                                              hmr.SD.MeasList(lst1(plotLst(ChLst(ii))),2), fooC );
                    set(h,'tag',foos)
                    
                end
                if(exist('dStd','var')) && ~all(all(all(isnan(dStd))))
%                    dStd = reshape(dStd, size(d,1), nCh, length(hmr.SD.Lambda));
                    for ii=1:length(ChLst)
                        dWlMl       = squeeze(d( :, plotLst(ChLst(ii)), hmr.plotLambdaLst(iWl)));
                        dWlMl       = dWlMl + (ii-1)*hmr.plotWaterfall;
                        dWlMlStd    = squeeze(dStd( :, plotLst(ChLst(ii)), hmr.plotLambdaLst(iWl)));
                        dWlMlStdErr = dWlMlStd./sqrt(nTrials(iS));
                        idx         = [1:10:length(t)];
                        h2          = errorbar(t(idx), dWlMl(idx), dWlMlStdErr(idx),'.');
                        set(h2,'color',hmr.color(ChLst(ii),:));
                    end
                end
            end
        else
            % plot dc
            lst1 = find(hmr.SD.MeasList(:,4)==1);
            for iConc = 1:length(hmr.plotConcLst)
                for ii=length(ChLst):-1:1
                    dHbMl = squeeze(d( :, hmr.plotConcLst(iConc), plotLst(ChLst(ii))));
                    dHbMl = dHbMl + (ii-1)*hmr.plotWaterfall;
                    h     = plot(t, dHbMl);
                    set(h,'color',hmr.color(ChLst(ii),:));
                    set(h,'linewidth',2);
                    set(h,'linestyle',hmr.linestyle{hmr.plotConcLst(iConc)});
                    
                    if ~isContributingHRF(plotLst(ChLst(ii)), iS, nTrials, hmr.plotHRF, [iF,i,j,k]) && ...
                            hmr.plotHRF ~= HRF_OFF_CONST
                        set(h,'linewidth',0.5);
                    end
                    
                    % set the context menu for the data traces
                    set(h,'uicontextmenu',hcmenu)
                    
                    % set tag so indicate which SD pair
                    if hmr.plotConcLst(iConc)==1
                        fooC = 'HbO';
                    elseif hmr.plotConcLst(iConc)==2
                        fooC = 'HbR';
                    else
                        fooC = 'HbT';
                    end
                    foos = sprintf( 'S%d_D%d_%s',hmr.SD.MeasList(lst1(plotLst(ChLst(ii))),1), ...
                                              hmr.SD.MeasList(lst1(plotLst(ChLst(ii))),2), fooC );
                    set(h,'tag',foos)
                    
                end
            end
            if(exist('dStd','var')) && ~all(all(all(all(isnan(dStd)))))
                for iConc = 1:length(hmr.plotConcLst)
                    for ii=length(ChLst):-1:1
                        dHbMl       = squeeze(d( :, hmr.plotConcLst(iConc), plotLst(ChLst(ii))));
                        dHbMl       = dHbMl + (ii-1)*hmr.plotWaterfall;
                        dHbMlStd    = squeeze(dStd( :, hmr.plotConcLst(iConc), plotLst(ChLst(ii))));
                        dHbMlStdErr = dHbMlStd./sqrt(nTrials(iS));
                        idx         = [1:10:length(t)];
                        h2          = errorbar(t(idx), dHbMl(idx), dHbMlStdErr(idx),'.');
                        set(h2,'color',hmr.color(ChLst(ii),:));
                    end 
                end     
            end
        end
        
        if hmr.flagPlotRange
            ylim(hmr.plotRange);
        else
            ylim('auto')
        end
                
        if hmr.flagPlottRange
            xlim(hmr.plottRange);              
        else
            xlim('auto')
            set(displayAxes(1), 'xlim',[t(1), t(end)]);
        end
        
        %%% Plot aux
        if ~isempty(aux)
            for ii=1:size(aux,2)
                yrange = ylim();
                h = plot(t, aux(:,ii)*yrange(2)/max(aux(:,ii)), 'k' );
                set(h,'linewidth',1);
            end
        end
        

        %%% Zoom panel settings. This has to be done before 
        %%% displaying exclude time points patches. 
        if hmr.ZoomEtc==1    % Zoom
            h=zoom;
            set(h,'ButtonDownFilter',@myZoom_callback);
            set(h,'enable','on')
        elseif hmr.ZoomEtc==4 % Pan
            h=pan;
            set(h,'ButtonDownFilter',@myZoom_callback);
            set(h,'enable','on')
        elseif hmr.ZoomEtc==2 % Exclude Time
            zoom off
            pan off
            set(displayAxes(1),'ButtonDownFcn', 'EasyNIRS(''axesPlot_ButtonDownFcn'',gcbo,[],guidata(gcbo))');
            set(get(displayAxes(1),'children'), 'ButtonDownFcn', 'EasyNIRS(''axesPlot_ButtonDownFcn'',gcbo,[],guidata(gcbo))');
        elseif hmr.ZoomEtc==3 % Stim
            zoom off
            pan off
            set(displayAxes(1),'ButtonDownFcn', 'EasyNIRS_DisplayData_StimCallback()');
            set(get(displayAxes(1),'children'), 'ButtonDownFcn', 'EasyNIRS_DisplayData_StimCallback()');
        end


        %%% Get manually excluded time points
        if ~isempty(hmr.tIncMan)
            tIncMan = hmr.tIncMan;
        else
            tIncMan = ones(length(hmr.t),1);
        end


        %%% Plot stim marks. This has to be done before plotting exclude time 
        %%% patches because stim legend doesn't work otherwise.
        if ~isempty(hmr.s) & hmr.plotStim & hmr.plotHRF==HRF_OFF_CONST
            hmr.s = enStimRejection(hmr.t,hmr.s,[],tIncMan,[0 0]);
            s = hmr.s;
            
            % Plot included and excluded stims
            yrange = ylim();
            hLg=[]; idxLg=[];
            kk=1;
            CondColTbl = hmr.group(i).conditions.CondColTbl;
            for iS = 1:size(s,2)
                iCond = find(hmr.group(i).conditions.CondRunIdx(iF,:)==iS);

                lstS          = find(hmr.s(:,iS)==1 | hmr.s(:,iS)==-1);
                lstExclS_Auto = [];
                lstExclS_Man  = find(s(:,iS)==-1);
                if isfield(procResult,'s') && ~isempty(procResult.s)
                    lstExclS_Auto = find(s(:,iS)==1 & sum(procResult.s,2)<=-1);
                end
                 
                for iS2=1:length(lstS)
                    if ~isempty(find(lstS(iS2) == lstExclS_Auto))
                        hl=plot(hmr.t(lstS(iS2))*[1 1],yrange,'-.');
                        set(hl,'linewidth',1);
                        set(hl,'color',CondColTbl(iCond,:));
                    elseif ~isempty(find(lstS(iS2) == lstExclS_Man))
                        hl=plot(hmr.t(lstS(iS2))*[1 1],yrange,'--');
                        set(hl,'linewidth',1);
                        set(hl,'color',CondColTbl(iCond,:));
                    else
                        hl=plot(hmr.t(lstS(iS2))*[1 1],yrange,'-');
                        set(hl,'linewidth',1);
                        set(hl,'color',CondColTbl(iCond,:));
                    end
                end

                % Get handles and indices of each stim condition 
                % for legend display
                if ~isempty(lstS)
                    % We don't want dashed lines appearing in legend, so 
                    % we draw invisible solid stims over all stims to 
                    % trick the legend into only showing solid lines.
                    hLg(kk) = plot(hmr.t(lstS(iS2))*[1 1],yrange,'-','visible','off');
                    set(hLg(kk),'color',CondColTbl(iCond,:));
                    idxLg(kk) = iCond;
                    kk=kk+1;
                end

            end

            if ~isempty(hLg)
                hmr.stim.LegendHdl = legend(hLg, hmr.group(i).conditions.CondNamesAct(idxLg));
            end
        end
        hold off


        %%% Show excluded time points as patches
        if hmr.flagShowExcluded & hmr.plotStim & hmr.plotHRF==HRF_OFF_CONST

            % automatically excluded
            if isfield(procResult,'tIncAuto')
                tIncAuto = procResult.tIncAuto;
            else
                tIncAuto = ones(length(tIncMan),1);
            end
            if hmr.flagShowMotionByChannel & isfield(procResult,'tIncChAuto') & (hmr.plotOD | hmr.plotRaw)
                for iWl=1:length(hmr.plotLambdaLst)
                    for ii=length(ChLst):-1:1
                        iCh0 = plotLst(ChLst(ii));
                        iCh = find(hmr.SD.MeasList(:,1)==hmr.SD.MeasList(iCh0,1) & ...
                                   hmr.SD.MeasList(:,2)==hmr.SD.MeasList(iCh0,2) & ...
                                   hmr.SD.MeasList(:,4)==hmr.plotLambdaLst(iWl) );
                        displayTimeExcludePatches(procResult.tIncChAuto(:,iCh),hmr.t,'auto',hmr.color(ChLst(ii),:) );
                    end
                end
            elseif hmr.flagShowMotionByChannel & isfield(procResult,'tIncChAuto') & hmr.plotConc
                for ii=length(ChLst):-1:1
                    iCh0 = plotLst(ChLst(ii));
                    iCh = find(hmr.SD.MeasList(:,1)==hmr.SD.MeasList(iCh0,1) & ...
                        hmr.SD.MeasList(:,2)==hmr.SD.MeasList(iCh0,2) );
                    tIncChAuto0 = min( procResult.tIncChAuto(:,iCh),[],2);
                    displayTimeExcludePatches(tIncChAuto0,hmr.t,'auto',hmr.color(ChLst(ii),:) );
                end
            else
                displayTimeExcludePatches(tIncAuto,hmr.t,'auto');
            end

            % manually excluded
            displayTimeExcludePatches(tIncMan,hmr.t,'manual');

        end

    else
        cla %this use to be clf but that crashed
    end

end  %%% if ~isempty(hmr.plotLst)

set(gca,'ygrid','on');





% -------------------------------------------------------------------------
function [flag] = myZoom_callback(obj,event_obj)

if strcmpi( get(obj,'Tag'), 'axesPlot' )
    flag = 0;
else
    flag = 1;
end



% -------------------------------------------------------------------------
function displayTimeExcludePatches(tInc,t,mode,col)

if strcmp(mode,'manual') | ~exist('col')
    col = setColor(mode);
end

% Patch in some versions of matlab messes up the renreder, that is it changes the 
% renderer property. Therefore we save current renderer before patch to
% restore it to what it was to pre-patch time. 
renderer = get(gcf, 'renderer');

hold on
p = timeExcludeRanges(tInc,t);
yy = ylim();
for ii=1:size(p,1)
    h=patch([p(ii,1) p(ii,2) p(ii,2) p(ii,1) p(ii,1)], [yy(1) yy(1) yy(2) yy(2) yy(1)], col, ...
            'facealpha',0.3, 'edgecolor','none' );
    if strcmp(mode,'manual')
        set(h,'ButtonDownFcn', sprintf('EasyNIRS_DisplayData_PatchCallback(%d)',ii) );
    end
end
hold off

% Restore previous renderer
set(gcf, 'renderer', renderer);



% -------------------------------------------------------------------------
function col = setColor(mode)

% Set patches color based on figure renderer

if strcmp(get(gcf,'renderer'),'zbuffer')
    if strcmp(mode,'auto')
        col=[1.0 0.5 0.5];
    else
        col=[1.0 0.5 1.0];
    end
else
    if strcmp(mode,'auto')
        col=[1.0 0.0 0.0];
    else
        col=[1.0 0.0 1.0];
    end
end
