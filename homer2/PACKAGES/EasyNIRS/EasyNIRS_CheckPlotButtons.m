function [i j k] = EasyNIRS_CheckPlotButtons(handles,iBttn)

% Function sets the states of buttons in the Plot Panel.
% First we change only GUI objects - nothing in hmr.
% Once we have the current state of all buttons 
% we set hmr fields. 

global hmr
global HRF_OFF_CONST
global HRF_GRP_CONST
global HRF_SESS_CONST
global HRF_RUN_CONST

if(~exist('iBttn','var'))
    iBttn=0;
end

u = zeros(7,1);
v = zeros(7,1);

% Get current listboxFiles selection
[iFile i j k] = listboxFiles_getCurrSelection(handles);

% Get the current on/off values of plot buttons
u(1) = get(handles.radiobuttonPlotRaw,'value');
u(2) = get(handles.radiobuttonPlotOD,'value');
u(3) = get(handles.radiobuttonPlotConc,'value');
u(4) = get(handles.checkboxPlotHRFGrp,'value');
u(5) = get(handles.checkboxPlotHRFSess,'value');
u(6) = get(handles.checkboxPlotHRFRun,'value');
u(7) = get(handles.checkboxPlotProbe,'value');

%% Determine enable/disable states of all plot buttons

% Raw Data
if(~isempty(hmr.d) & (u(4)==0) & (u(5)==0) & (u(6)==0) & k>0)
   v(1) = 1;
else
   v(1) = 0;
   u(1) = 0;
end


% OD
if k>0 
    if(~isempty(hmr.procResult.dod) & u(4)==0 & u(5)==0 & u(6)==0)
        v(2) = 1;
    elseif(~isempty(hmr.procResult.dodAvg) & (u(4)==0 | u(5)==0 | u(6)==0))
        v(2) = 1;
    else
        v(2) = 0;
        u(2) = 0;
    end
else
    if(~isempty(hmr.group(i).subjs(j).procResult.dodAvg) & (u(4)==0 | u(5)==0 | u(6)==0))
        v(2) = 1;
    else
        v(2) = 0;
        u(2) = 0;
    end
end


% Conc
if k>0
    if(~isempty(hmr.procResult.dc) & u(4)==0 & u(5)==0 & u(6)==0)
        v(3) = 1;
    elseif(~isempty(hmr.procResult.dcAvg) & (u(4)==0 | u(5)==0 | u(6)==0))
        v(3) = 1;
    else
        v(3) = 0;
        u(3) = 0;
    end
else
    if(~isempty(hmr.group(i).subjs(j).procResult.dcAvg) & (u(4)==0 | u(5)==0 | u(6)==0))
        v(3) = 1;
    else
        v(3) = 0;
        u(3) = 0;
    end
end


% show HRF Grp
if(v(2)==1 & ~isempty(hmr.group(i).procResult.dodAvg))
   v(4) = 1;
elseif(v(3)==1 & ~isempty(hmr.group(i).procResult.dcAvg))
   v(4) = 1;
else
   v(4) = 0;
   u(4) = 0;
end

% show HRF Sess
if(v(2)==1 & ~isempty(hmr.group(i).subjs(j).procResult.dodAvg))
   v(5) = 1;
elseif(v(3)==1 & ~isempty(hmr.group(i).subjs(j).procResult.dcAvg))
   v(5) = 1;
else
   v(5) = 0;
   u(5) = 0;
end

% show HRF Run
if(v(2)==1 & ~isempty(hmr.procResult.dodAvg))
   v(6) = 1;
elseif(v(3)==1 & ~isempty(hmr.procResult.dcAvg))
   v(6) = 1;
else
   v(6) = 0;
   u(6) = 0;
end


% Set current enable/disable states of plot buttons
if v(1)==1, enable{1}='on'; else enable{1}='off'; end 
if v(2)==1, enable{2}='on'; else enable{2}='off'; end 
if v(3)==1, enable{3}='on'; else enable{3}='off'; end 
if v(4)==1, enable{4}='on'; else enable{4}='off'; end 
if v(5)==1, enable{5}='on'; else enable{5}='off'; end 
if v(6)==1, enable{6}='on'; else enable{6}='off'; end 

if hmr.listboxFileCurr.iGrp==1
    set(handles.radiobuttonPlotRaw, 'enable',enable{1});
    set(handles.radiobuttonPlotOD,  'enable',enable{2});
    set(handles.radiobuttonPlotConc,'enable',enable{3});
    set(handles.checkboxPlotHRFRun, 'enable',enable{6});
end
set(handles.checkboxPlotHRFGrp, 'enable',enable{4});
set(handles.checkboxPlotHRFSess,'enable',enable{5});

%% Now set the on/off values 
% Raw Data
if (all(v==0))
    u(1) = 1;
elseif (v(1)==1 & u(2)==0 & u(3)==0 & u(4)==0 & u(5)==0 & u(6)==0)
    u(1) = 1;
else
    u(1) = 0;
end

% OD
if (v(2)==1 & u(1)==0 & u(3)==0)
    u(2) = 1;
else
    u(2) = 0;
end

% Conc
if (v(3)==1 & u(1)==0 & u(2)==0)
    u(3) = 1;
else
    u(3) = 0;
end

% show HRF Grp
if (v(4)==0 | u(1)==1)
    u(4) = 0;
elseif (u(4)==1 & hmr.plotHRF~=HRF_GRP_CONST)
    u(5)=0;
    u(6)=0;
end

% show HRF Sess
if (v(5)==0 | u(1)==1)
    u(5) = 0;
elseif (u(5)==1 & hmr.plotHRF~=HRF_SESS_CONST)
    u(4)=0;
    u(6)=0;
end

% show HRF Run
if (v(6)==0 | u(1)==1)
    u(6) = 0;
elseif (u(6)==1 & hmr.plotHRF~=HRF_RUN_CONST)
    u(4)=0;
    u(5)=0;
end

% Plot Probe
if(u(4)==1 | u(5)==1 | u(6)==1)
   v(7) = 1;
else
   v(7) = 0;
   u(7) = 0;
end

if v(7)==1
    enable{7}='on'; 
else
    enable{7}='off'; 
end
set(handles.checkboxPlotProbe,'enable',enable{7});


% Set current on/off values of plot buttons
set(handles.radiobuttonPlotRaw,'value' ,u(1));
set(handles.radiobuttonPlotOD,'value'  ,u(2));
set(handles.radiobuttonPlotConc,'value',u(3));
set(handles.checkboxPlotHRFGrp,'value' ,u(4));
set(handles.checkboxPlotHRFSess,'value',u(5));
set(handles.checkboxPlotHRFRun,'value' ,u(6));
set(handles.checkboxPlotProbe,'value'  ,u(7));


%% Now set GUI objects based on the on/off values 
%% of the buttons above

% Make either the wavelength listbox or the 
% Hb type listbox visible but not both. 
% Basically if the Raw Data or OD button is 
% checked make the wavelength listbox visible. 
% Otherwise make the Hb type listbox visible
if(u(1)==1 | u(2)==1)
    set(handles.listboxPlotWavelength,'visible','on')
    set(handles.listboxPlotConc,'visible','off')
else
    set(handles.listboxPlotWavelength,'visible','off')
    set(handles.listboxPlotConc,'visible','on')
end

if(u(4)==1 | u(5)==1 | u(6)==1)
    set(handles.checkboxDisplayStim,'enable','off');
else
    set(handles.checkboxDisplayStim,'enable','on');
end

hmr = setHmrPlotFields(hmr,u,handles);




function hmr = setHmrPlotFields(hmr,u,handles)
global HRF_OFF_CONST
global HRF_GRP_CONST
global HRF_SESS_CONST
global HRF_RUN_CONST


%% Finally set the plot fields in hmr
hmr.plotRaw  = u(1);
hmr.plotOD   = u(2);
hmr.plotConc = u(3);
hmr.plotHRF  = HRF_GRP_CONST*u(4) + HRF_SESS_CONST*u(5) + HRF_RUN_CONST*u(6);
checked=get(handles.menuViewHRFStdErr,'checked');
if(strcmp(checked,'off'))
    hmr.plotHRFStdErr = 0;
elseif(strcmp(checked,'on'))
    hmr.plotHRFStdErr = 1;
end
hmr.plotConcLst = get(handles.listboxPlotConc,'value');
hmr.plotCondition = get(handles.popupmenuCondition,'value');
hmr.plotStim = get(handles.checkboxDisplayStim,'value');

lst = get(handles.listboxPlotWavelength,'value');
foos = get(handles.listboxPlotWavelength,'string');
hmr.plotLambdaLst = [];
for ii=1:length(lst)
    for jj=1:length(hmr.SD.Lambda)
        if str2num(foos{lst(ii)})==hmr.SD.Lambda(jj)
            hmr.plotLambdaLst(ii) = jj;
        end
    end
end
