function varargout = EasyNIRS(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @EasyNIRS_OpeningFcn, ...
                   'gui_OutputFcn',  @EasyNIRS_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end



% --------------------------------------------------------------------
% Executes just before EasyNIRS is made visible.
% This function has no output args, see OutputFcn.
function EasyNIRS_OpeningFcn(hObject, eventdata, handles, varargin)

global hmr

hmr = initHmr(hObject,varargin);

% Choose default command line output for EasyNIRS
handles.output = hObject;
guidata(hObject, handles);

% Disable and reset all window gui objects
EasyNIRS_EnableDisableGUI(handles,'off');

% Check NIRS data set for errors. If there are no valid 
% nirs files don't attempt to load them. 
files = GetNIRSDataSet(handles);

% Display window name which includes version # and data set path. Do this 
% regardless of whether it's an empty gui because the user pressed cancel.
% We want them to see the gui and version no matter what.
EasyNIRS_version(hObject);

if isempty(files)
    return;
end
hmr.files = files;

% If data set has no errors enable window gui objects
EasyNIRS_EnableDisableGUI(handles,'on');

% grab some handles that are needed
hmr.handles.axesSDG = handles.axesSDG;
hmr.handles.displayAxes = handles.axesPlot;
hmr.handles.pushbuttonSave = handles.pushbuttonSave;
hmr.handles.popupmenuNIRSsignalProcess = handles.popupmenuNIRSsignalProcess;
hmr.handles.pushbuttonNIRSsignalProcessCancel = handles.pushbuttonNIRSsignalProcessCancel;
hmr.handles.popupmenuCondition = handles.popupmenuCondition;
hmr.handles.textCalculateHRF = handles.textCalculateHRF;
hmr.handles.checkboxPlotHRFGrp = handles.checkboxPlotHRFGrp;
hmr.handles.checkboxPlotHRFSess = handles.checkboxPlotHRFSess;
hmr.handles.checkboxPlotHRFRun = handles.checkboxPlotHRFRun;
hmr.handles.listboxPlotWavelength = handles.listboxPlotWavelength;

hmr.flagShowExcluded = get(handles.checkboxShowExcluded,'value');
hmr.flagShowMotionByChannel = get(handles.checkboxShowMotionByChannel,'value');

global HRF_OFF_CONST; HRF_OFF_CONST=0;
global HRF_RUN_CONST;  HRF_RUN_CONST=1;
global HRF_SESS_CONST; HRF_SESS_CONST=2;
global HRF_GRP_CONST;  HRF_GRP_CONST=4;

% Initialize homer plot flags
hmr.plotRaw  = 0;
hmr.plotOD   = 0;
hmr.plotConc = 0;
hmr.plotHRF  = HRF_OFF_CONST;
hmr.plotHRFStdErr = 0;
hmr.plotCondition = 0;
hmr.plotStim = 0;
hmr.plotAux = 0;
hmr.plotRange = [-2 2];
hmr.plottRange = [0 500]; 
hmr.flagPlotRange = 0;
hmr.flagPlottRange = 0;
% Initialize homer plot lists
hmr.plotLst = [];
hmr.plotConcLst = [];

hmr.plotWaterfall = 0;

hmr.color = [ ...
             0.2  0.6  0.1;
             1.0  0.5  0.0;
             1.0  0.0  1.0;
             0.5  0.5  1.0;
             0.0  1.0  1.0;
             1.0  0.0  0.0;
             0.2  0.3  0.1;
             0.8  0.6  0.6;
             0.5  1.0  0.5;
             0.5  1.0  1.0;
             0.0  0.0  0.0;
             0.2  0.2  0.2;
             0.4  0.4  0.4;
             0.6  0.6  0.6;
             0.8  0.8  0.8 ...
            ];

hmr.linestyle = {'-','-.',':'};

% load NIRS files to group
warning('off', 'MATLAB:load:variableNotFound');
LoadNIRS2hmr(files,handles);

% Initialize the processing stream
% and initialize procInput if not in NIRS file
% if in NIRS file then check for consistency
EasyNIRS_ProcessOpt_Init();

% Update associated GUI's
h = findobj('Tag','EasyNIRS_ProcessOpt');
if ~isempty(h)
    EasyNIRS_ProcessOpt();
end

EasyNIRS_CheckPlotButtons( handles );
checkboxCopyOptions_Callback(handles.checkboxCopyOptions, 1, handles);

% set some fields
hmr.plotAux = 0;
set(handles.checkboxPlotAux,'value',hmr.plotAux)
hmr.ZoomEtc = 1;   % zoom
set(handles.radiobuttonZoom,'value',1)
set(handles.checkboxPlotAux,'value',hmr.plotAux)
hmr.stim.LegendHdl = -1;

% display SDG
EasyNIRS_plotAxesSDG();
EasyNIRS_DisplayData();
PlotProbe_Init(hObject);

% Set GUI size relative to screen size
positionGUI(hObject);



% --------------------------------------------------------------------
function varargout = EasyNIRS_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;




% --------------------------------------------------------------------
function pushbuttonPanLeft_Callback(hObject, eventdata, handles)
global hmr

axes(handles.axesPlot)
xrange = xlim();
xm = mean(xrange);
xd = xrange(2)-xrange(1);
if eventdata==1
    if xrange(1)-xd/5 >= 0
        xlim( max(min(xm + [-xd xd]/2 - xd/5,hmr.t(end)),0) );
    else
        xlim( [0 xd] );
    end
elseif eventdata==2
    if xrange(2)+xd/5 <= hmr.t(end)
        xlim( max(min(xm + [-xd xd]/2 + xd/5,hmr.t(end)),0) );
    else
        xlim( hmr.t(end) + [-xd 0] );
    end
end

% redraw stims for legend
hold on 
yrange = ylim();
xrange_new = xlim;
iF = hmr.listboxFileCurr.iFile;
CondColTbl = hmr.group.conditions.CondColTbl;
legend off
kk=1;
hLg = [];
for iS = 1:size(hmr.s,2)
    iCond = find(hmr.group.conditions.CondRunIdx(iF,:)==iS);
    lstS = find(hmr.s(:,iS)~=0);
    if ~isempty(lstS) && ~isempty(iCond)
        hLg(kk) = plot(hmr.t(lstS(1))*[1 1],yrange,'-','visible','off');
        set(hLg(kk),'color',CondColTbl(iCond,:));
        idxLg(kk) = iCond;
        kk=kk+1;
        continue;
    end
end
if ~isempty(hLg)
    hmr.stim.LegendHdl = legend(hLg,hmr.group.conditions.CondNamesAct(idxLg));
end



% --------------------------------------------------------------------
function checkboxDisplayStim_Callback(hObject, eventdata, handles)
global hmr

hmr.plotStim = 1-hmr.plotStim;
EasyNIRS_DisplayData();



% --------------------------------------------------------------------
function listboxFiles_Callback(hObject, eventdata, handles)
global hmr

idx = get(hObject,'value');
if isempty(idx==0)
    return;
end
files = hmr.files;

[iFile iGrp iSubj iRun] = listboxFiles_getCurrSelection(handles);
if iRun>0

    h = findobj('Tag','stimGUI');
    if ~isempty(h)
        stimGUI_reset();
    end
    
    % check if changes were made to current file
    % and ask if user wants them saved in nirs file
    if hmr.fileChanged
        ch = menu( sprintf('Save changes to %s?',hmr.filename), 'Yes', 'No', 'Cancel' );
        if ch==3
            return;
        elseif ch==1
            pushbuttonSave_Callback(handles.pushbuttonSave, eventdata, handles)
        end
    end
    set(handles.pushbuttonSave,'visible','off')
    hwait = waitbar(0,sprintf('Loading %s',files(idx).name) );
    
    procInput_copyOptions = hmr.procInput;
    LoadCurrNIRSFile(files(idx).name, handles);
    if hmr.copyOptions
        if data_diff(procInput_copyOptions.procParam, hmr.procInput.procParam)
            hmr.procInput = procInput_copyOptions;
            hmr.procInput.changeFlag = 1;
            SaveDataToRun(hmr.filename,'procInput',hmr.procInput);
        end
    end
    
    % Update associated GUI's
    h = findobj('Tag','EasyNIRS_ProcessOpt');
    if ~isempty(h)
        EasyNIRS_ProcessOpt();
    end
    
    % display SDG
    axes(handles.axesPlot);
    xlim('auto')
    ylim('auto')
    EasyNIRS_plotAxesSDG();
    EasyNIRS_NIRSsignalProcessUpdate(hmr);
    EasyNIRS_DisplayData();
    checkboxPlotProbe_Callback(handles.checkboxPlotProbe, eventdata, handles);
    close(hwait);
    
else

    checkboxPlotHRFRun_Callback([], [0 0], handles);
    checkboxPlotHRFSess_Callback([], [1], handles);

end



% --------------------------------------------------------------------
function listboxFilesErr_Callback(hObject, eventdata, handles)

% TBD: We may want to try fix files with errors




% --------------------------------------------------------------------
function pushbuttonSignalProcessAdvOpt_Callback(hObject, eventdata, handles)
global hmr

if isempty(hmr.procInput) || isempty(hmr.procInput.procFunc)
    ch = menu( sprintf('Warning: processing options config file is empty or has bad syntax.'),'Okay');
    return;
end

% Update associated GUI's
EasyNIRS_ProcessOpt();



% --------------------------------------------------------------------
% --- Executes when selected object is changed in uipanelPlot.
function uipanelPlot_SelectionChangeFcn(hObject, eventdata, handles)
global hmr

axes(handles.axesPlot);
xlim('auto')
ylim('auto')
EasyNIRS_CheckPlotButtons(handles);
EasyNIRS_DisplayData();



% --------------------------------------------------------------------
% --- Executes on selection change in listboxPlotWavelength.
function listboxPlotWavelength_Callback(hObject, eventdata, handles)
global hmr

val = get(hObject,'value');
if isempty(val)
    set(hObject,'value',1);
end

lst = get(hObject,'value');
foos = get(hObject,'string');
hmr.plotLambdaLst = [];
for ii=1:length(lst)
    for jj=1:length(hmr.SD.Lambda)
        if str2num(foos{lst(ii)})==hmr.SD.Lambda(jj)
            hmr.plotLambdaLst(ii) = jj;
        end
    end
end
EasyNIRS_DisplayData();


% --------------------------------------------------------------------
% --- Executes on selection change in listboxPlotConc.
function listboxPlotConc_Callback(hObject, eventdata, handles)
global hmr

val = get(hObject,'value');
if isempty(val)
    set(hObject,'value',1);
end

hmr.plotConcLst = get(hObject,'value');
EasyNIRS_DisplayData();



% --------------------------------------------------------------------
% --- Executes when selected object is changed in uipanelZoomEtc.
function uipanelZoomEtc_SelectionChangeFcn(hObject, eventdata, handles)
global hmr

if get(handles.radiobuttonZoom,'value')
    hmr.ZoomEtc = 1;   % zoom
    axes(handles.axesPlot)
%    xlim('auto')
%    ylim('auto')
elseif get(handles.radiobuttonPan,'value')
    hmr.ZoomEtc = 4;   % pan
elseif get(handles.radiobuttonTimeExclude,'value')
    hmr.ZoomEtc = 2;   % Time Exclude
elseif get(handles.radiobuttonStim,'value')
    hmr.ZoomEtc = 3;   % Stim
end
EasyNIRS_DisplayData();



% --------------------------------------------------------------------
% --- Executes on mouse press over axes background.
function axesPlot_ButtonDownFcn(hObject, eventdata, handles)
global hmr

if isempty(hmr.t)
    return;
end

% Make sure the user clicked on the axes and not 
% some other object on top of the axes
if ~strcmp(get(hObject,'type'),'axes')
    return;
end

point1 = get(hObject,'CurrentPoint');    % button down detected
finalRect = rbbox;                   % return figure units
point2 = get(hObject,'CurrentPoint');    % button up detected
point1 = point1(1,1:2);                  % extract x and y
point2 = point2(1,1:2);
p1 = min(point1,point2);
p2 = max(point1,point2);
t = hmr.t;
if ~isempty(hmr.tIncMan)
    lst = find(t>=p1(1) & t<=p2(1));
    hmr.tIncMan(lst) = 0;
else
    hmr.tIncMan = logical(ones(length(hmr.t),1));
    lst = find(t>=p1(1) & t<=p2(1));
    hmr.tIncMan(lst) = 0;
end
hmr.fileChanged = 1;
set(handles.pushbuttonSave,'visible','on')
EasyNIRS_NIRSsignalProcessEnable('on');
EasyNIRS_DisplayData();



% --------------------------------------------------------------------
% --- Executes on button press in pushbuttonZoomReset.
function pushbuttonZoomReset_Callback(hObject, eventdata, handles)

axes(handles.axesPlot)
xlim('auto')
ylim('auto')
EasyNIRS_DisplayData();



% --------------------------------------------------------------------
% --- Executes on button press in checkboxShowExcluded.
function checkboxShowExcluded_Callback(hObject, eventdata, handles)
global hmr

hmr.flagShowExcluded = get(handles.checkboxShowExcluded,'value');
EasyNIRS_DisplayData();



% --------------------------------------------------------------------
function saveRun(run)

d = run.d;
strLst = '''d''';
t = run.t;
strLst = [strLst ', ''t'''];
SD = run.SD;
strLst = [strLst ', ''SD'''];
ml = run.SD.MeasList;
strLst = [strLst ', ''ml'''];
s = run.s;
strLst = [strLst ', ''s'''];
if data_diff(run.s,run.s0)
    s0 = run.s0;
    strLst = [strLst ', ''s0'''];
end
aux = run.aux;
strLst = [strLst ', ''aux'''];

tIncMan = run.tIncMan;
strLst = [strLst ', ''tIncMan'''];

userdata = run.userdata;
strLst = [strLst ', ''userdata'''];

procInput = run.procInput;
SaveDataToRun(run.filename,'procInput',procInput)

procResult = run.procResult;
strLst = [strLst ', ''procResult'''];

CondNames = run.stim.CondNames;
strLst = [strLst ', ''CondNames'''];

hwait = waitbar(0,'Saving...');
eval( sprintf('save( [''./'' run.filename], %s, ''-mat'')', strLst) );
close(hwait)



% --------------------------------------------------------------------
% --- Executes on button press in pushbuttonSave.
function pushbuttonSave_Callback(hObject, eventdata, handles)
global hmr

saveRun(hmr);

hmr.fileChanged = 0;
set(hObject,'visible','off')



% --------------------------------------------------------------------
% --- Executes on selection change in popupmenuCondition.
function popupmenuCondition_Callback(hObject, eventdata, handles)
global hmr

hmr.plotCondition = get(hObject,'value');
popupmenuCondition_SetStrings(handles, hmr.group.conditions.CondNamesAct, hmr.s, hmr.stim.CondNames);
EasyNIRS_DisplayData();
checkboxPlotProbe_Callback(handles.checkboxPlotProbe, eventdata, handles);



% --------------------------------------------------------------------
function checkboxPlotHRFRun_Callback(hObject, eventdata, handles)
global hmr

if isempty(hObject)
    hObject = handles.checkboxPlotHRFRun;
end

if ~isempty(eventdata) & ~strcmp(class(eventdata), 'matlab.ui.eventdata.ActionData')
    set(hObject,'value',eventdata(1))
    if length(eventdata)>1
        if eventdata(2)==1
            set(hObject,'enable','on');
        elseif eventdata(2)==0
            set(hObject,'enable','off');
        end
    end
end
[i j k] = EasyNIRS_CheckPlotButtons(handles);

axes(handles.axesPlot);
xlim('auto')
ylim('auto')

% If the current selection is a subject directory and 'we're unclicking 
% show HRF then there's nothing to display 
if get(hObject,'value')==0 && k==0
    cla; return;
end
EasyNIRS_DisplayData();
checkboxPlotProbe_Callback(handles.checkboxPlotProbe, eventdata, handles);



% --------------------------------------------------------------------
function checkboxPlotHRFSess_Callback(hObject, eventdata, handles)
global hmr

if isempty(hObject)
    hObject = handles.checkboxPlotHRFSess;
end

if ~isempty(eventdata) & ~strcmp(class(eventdata), 'matlab.ui.eventdata.ActionData')
    set(hObject,'value',eventdata(1))
    if length(eventdata)>1
        if eventdata(2)==1
            set(hObject,'enable','on');
        elseif eventdata(2)==0
            set(hObject,'enable','off');
        end
    end
end

% switch back to group 1 if needed
if get(hObject,'value')==0 & ...
        get(handles.checkboxPlotHRFGrp,'value')==0 & ...
        iscell(get(handles.popupmenuGroupList,'string'))    
    set(handles.popupmenuGroupList,'value',1);
    popupmenuGroupList_Callback(handles.popupmenuGroupList, [], handles)
end

% First set plot flag for all subjects to zero
[i j k] = EasyNIRS_CheckPlotButtons(handles);

axes(handles.axesPlot);
xlim('auto')
ylim('auto')

% If the current selection is a subject directory and 'we're unclicking 
% show HRF then there's nothing to display 
if get(hObject,'value')==0 && k==0
    cla; return;
end
EasyNIRS_DisplayData();
checkboxPlotProbe_Callback(handles.checkboxPlotProbe, eventdata, handles);



% --------------------------------------------------------------------
function checkboxPlotHRFGrp_Callback(hObject, eventdata, handles)
global hmr

% switch back to group 1 if needed
if get(handles.checkboxPlotHRFSess,'value')==0 & ...
        get(handles.checkboxPlotHRFGrp,'value')==0 & ...
        iscell(get(handles.popupmenuGroupList,'string'))    
    set(handles.popupmenuGroupList,'value',1);
    popupmenuGroupList_Callback(handles.popupmenuGroupList, [], handles)
end

[i j k] = EasyNIRS_CheckPlotButtons(handles);

axes(handles.axesPlot);
xlim('auto')
ylim('auto')

% If the current selection is a subject directory and we're unclicking 
% show HRF then there's nothing to display 
if get(hObject,'value')==0 && k==0
    cla; return;
end
EasyNIRS_DisplayData();
checkboxPlotProbe_Callback(handles.checkboxPlotProbe, eventdata, handles);




% --------------------------------------------------------------------
% --- Executes on button press in checkboxPlotProbe.
function checkboxPlotProbe_Callback(hObject, eventdata, handles)
global hmr

if ~isempty(eventdata) & ~strcmp(class(eventdata), 'matlab.ui.eventdata.ActionData')
    if eventdata==0
        set(hObject,'value',0);
        return;
    end
end

val    = get(hObject,'value');
enable = strcmpi(get(handles.checkboxPlotProbe,'enable'),'on');

if(val==1 & enable==1)
    gui_enable = 1;
else
    gui_enable = 0;
end
hmr.handles.plotProbe = PlotProbe_Session(hmr, gui_enable, handles);



% --------------------------------------------------------------------
function editGrpAvgPassTrange_Callback(hObject, eventdata, handles)
global hmr

trange = str2num( get(hObject,'string') );
if length(trange)==2
    if trange(1)<trange(2)
        hmr.group(1).PassTrange = trange;
        % EasyNIRS_NIRSsignalProcessEnable('on');
        return;
    end
end
set(hObject,'string',num2str(hmr.group(1).PassTrange))



% --------------------------------------------------------------------
function editGrpAvgPassThresh_Callback(hObject, eventdata, handles)

EasyNIRS_NIRSsignalProcessEnable('on');



% --------------------------------------------------------------------
% --- Executes on button press in checkboxGrpAvgPassAllCh.
function checkboxGrpAvgPassAllCh_Callback(hObject, eventdata, handles)



% --------------------------------------------------------------------
% --- Executes on selection change in listboxAux.
function listboxAux_Callback(hObject, eventdata, handles)
global hmr

if get(handles.checkboxPlotAux,'value')==1
    hmr.plotAux = get(hObject,'value');
    EasyNIRS_DisplayData()
end


% --------------------------------------------------------------------
% --- Executes on button press in checkboxPlotAux.
function checkboxPlotAux_Callback(hObject, eventdata, handles)
global hmr

if get(hObject,'value')==1
    hmr.plotAux = get(handles.listboxAux,'value');
else
    hmr.plotAux = 0;
end
EasyNIRS_DisplayData();




% --------------------------------------------------------------------
function menuChangeDirectory_Callback(hObject, eventdata, handles)
global hmr

% save file if needed
if hmr.fileChanged
    ch = menu( sprintf('Save changes to %s?',hmr.filename), 'Yes', 'No', 'Cancel' );
    if ch==3
        return;
    elseif ch==1     
        pushbuttonSave_Callback(handles.pushbuttonSave, eventdata, handles)
    end
end
set(handles.pushbuttonSave,'visible','off')

% Change directory
pathnm = uigetdir( cd, 'Pick the new directory' );
if pathnm==0
    return;
end
cd(pathnm);

hGui=get(get(hObject,'parent'),'parent');
EasyNIRS_DeleteFcn(hGui,[],handles);
checkboxPlotProbe_Callback(handles.checkboxPlotProbe, 0, handles);

% clear axes
axes(handles.axesPlot);
legend off
cla
axes(handles.axesSDG);
cla

zoom off

% restart
clear hmr
EasyNIRS();



% --------------------------------------------------------------------
function EasyNIRS_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to EasyNIRS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);



% --------------------------------------------------------------------
function menuStimGUI_Callback(hObject, eventdata, handles)

stimGUI();


% --------------------------------------------------------------------
function menuResetFile_Callback(hObject, eventdata, handles)
global hmr

ch = menu( 'Reset file to SD, t, d, s, and aux only?','Current File','All Files','Cancel');
if ch==3
    return;
end

if ch==1 % reset current file
    
    i = hmr.listboxFileCurr.iGrp;
    j = hmr.listboxFileCurr.iSubj;
    iRun = hmr.listboxFileCurr.iRun;
    if iRun==0
        iRun = 1:length(hmr.group(i).subjs(j).runs);
    end

    nFiles = length(iRun);
    hwait = waitbar( 0, '' );
    for k=iRun
        iF      = hmr.group(i).subjs(j).runs(k).fileidx;
        files(iF).name = hmr.group(i).subjs(j).runs(k).filename;
        files(iF).isdir = 0;
        
        hwait = waitbar( iF/nFiles, hwait, sprintf('Reseting %s', files(iF).name) );
        load( ['./' files(iF).name], '-mat',...
             'SD', 't', 'd', 's','aux','s0');

        % Aux param name has changed atleast once in cw6. To avoid compatility 
        % problems we allow for two different names. 
        if exist('aux10') & ~exist('aux')
            aux = aux10;
        end
        if exist('s0')
            s = s0;
            clear s0;
        end

        save( ['./' files(iF).name], ...
             '-mat', 'SD', 't', 'd', 's','aux')
        hmr.group(i).subjs(j).runs(k).procInput.changeFlag = 1;    

        listboxFiles_setCurrSelection(handles,i,j,k);
        hmr.group.conditions.CondTbl{iF} = stimCondInitTblEntry(files(iF).name);

    end
    hmr.group(i).subjs(j).procInput.changeFlag = 1;    
    hmr.group(i).subjs(j).procResult = initProcResultStruct('subject');
    hmr.group(i).procInput.changeFlag = 1;
    hmr.group(i).procResult = initProcResultStruct('group');

    % Don't delete groupResults since only one file was reset. Just save it.
    saveGroup();

else % reset all files
    
    nFiles = hmr.group.nFiles;
    hwait = waitbar( 0, '' );    
    for i = 1:length(hmr.group)
        for j = 1:length(hmr.group(i).subjs)
            for k = 1:length(hmr.group(i).subjs(j).runs)
                iF      = hmr.group(i).subjs(j).runs(k).fileidx;
                files(iF).name = hmr.group(i).subjs(j).runs(k).filename;
                files(iF).isdir = 0;
                
                hwait = waitbar( iF/nFiles, hwait, sprintf('Reseting %s', files(iF).name) );
                load( ['./' files(iF).name], '-mat',...
                     'SD', 't', 'd', 's','aux','s0');

                % Aux param name has changed atleast once in cw6. To avoid compatility 
                % problems we allow for two different names. 
                if exist('aux10') & ~exist('aux')
                    aux = aux10;
                end
                if exist('s0')
                    s = s0;
                    clear s0;
                end
                                
                save( ['./' files(iF).name], ...
                     '-mat', 'SD', 't', 'd', 's','aux')
                hmr.group(i).subjs(j).runs(k).procInput.changeFlag = 1;

                listboxFiles_setCurrSelection(handles,i,j,k);
                hmr.group.conditions.CondTbl{iF} = stimCondInitTblEntry(files(iF).name);

            end
            hmr.group(i).subjs(j).procInput.changeFlag = 1;    
            hmr.group(i).subjs(j).procResult = initProcResultStruct('subject');
        end
        hmr.group(i).procInput.changeFlag = 1;
        hmr.group(i).procResult = initProcResultStruct('group');

    end

    if exist('./groupResults.mat','file')
        delete( './groupResults.mat' );
    end
    
end
close(hwait)

[CondNamesAct CondRunIdx] = stimGUI_MakeConditions(hmr.group.conditions.CondTbl);
hmr.group.conditions.CondNamesAct = CondNamesAct;
hmr.group.conditions.CondRunIdx = CondRunIdx;

LoadCurrNIRSFile(files(iF).name, handles);
hmr.procInput.changeFlag=1;

% load current file and update display
EasyNIRS_CheckPlotButtons( handles );
EasyNIRS_plotAxesSDG();
EasyNIRS_DisplayData();
checkboxPlotProbe_Callback(handles.checkboxPlotProbe, eventdata, handles);
EasyNIRS_NIRSsignalProcessUpdate(hmr);
EasyNIRS_saveUserDataToGroup();



% --------------------------------------------------------------------
function menuPlotPowerSpectrum_Callback(hObject, eventdata, handles)
EasyNIRS_plotPSD()



% --------------------------------------------------------------------
function menuCopyCurrentPlot_Callback(hObject, eventdata, handles)
[hf plotname]=EasyNIRS_plotCurrentFig();
if strcmp(get(handles.menuAutosavePlotFigsToFile,'checked'),'on')
    filename = [plotname '.jpg'];
    print(hf,'-djpeg99',filename);
end


% --------------------------------------------------------------------
function menuViewHRFStdErr_Callback(hObject, eventdata, handles)
global hmr;
checked=get(hObject,'checked');
if(strcmp(checked,'off'))
    set(hObject,'checked','on');
    hmr.plotHRFStdErr = 1;
elseif(strcmp(checked,'on'))
    set(hObject,'checked','off');
    hmr.plotHRFStdErr = 0;
end
EasyNIRS_DisplayData();


% --------------------------------------------------------------------
function EasyNIRS_DeleteFcn(hObject, eventdata, handles)
global hmr;

if ~isfield(hmr,'handles')
    return;
end

if isfield(hmr.handles,'proccessOpt') & ishandle(hmr.handles.proccessOpt)
    close(hmr.handles.proccessOpt);
end
if isfield(hmr.handles,'stimGUI') & ishandle(hmr.handles.stimGUI)
    close(hmr.handles.stimGUI);
end
if isfield(hmr.handles,'plotProbe') & ishandle(hmr.handles.plotProbe)
    close(hmr.handles.plotProbe);
end
hmr = []; 
clear hmr;



% --------------------------------------------------------------------
function procResult = make_tHRFDataCommon(procResult, tHRF_common, name, type)

if size(tHRF_common,2)<size(tHRF_common,1)
    tHRF_common = tHRF_common';
end
tHRF = procResult.tHRF;
n = length(tHRF_common);
m = length(tHRF);
d = n-m;
if d<0

    disp(sprintf('WARNING: tHRF for %s %s is larger than the common tHRF.',type, name));
    if ~isempty(procResult.dodAvg)
        procResult.dodAvg(n+1:m,:,:)=[];
        if strcmp(type,'run')
            procResult.dodSum2(n+1:m,:,:)=[];
        end
    end
    if ~isempty(procResult.dcAvg) 
        procResult.dcAvg(n+1:m,:,:,:)=[];
        if strcmp(type,'run')
            procResult.dcSum2(n+1:m,:,:,:)=[];
        end
    end

elseif d>0

    disp(sprintf('WARNING: tHRF for %s %s is smaller than the common tHRF.',type, name));
    if ~isempty(procResult.dodAvg)
        procResult.dodAvg(m:n,:,:)=zeros(d,size(procResult.dodAvg,2),size(procResult.dodAvg,3));
        if strcmp(type,'run')
            procResult.dodSum2(m:n,:,:)=zeros(d,size(procResult.dodSum2,2),size(procResult.dodSum2,3));
        end
    end
    if ~isempty(procResult.dcAvg) 
        procResult.dcAvg(m:n,:,:,:)=zeros(d,size(procResult.dcAvg,2),size(procResult.dcAvg,3),size(procResult.dcAvg,4));
        if strcmp(type,'run')
            procResult.dcSum2(m:m+d,:,:,:)=zeros(d,size(procResult.dcSum2,2),size(procResult.dcSum2,3),size(procResult.dcSum2,4));
        end
    end

end
procResult.tHRF = tHRF_common;



% --------------------------------------------------------------------
function [procResult procInput err] = runNIRSsignalProcess(iGrp,iSubj,iRun,handles)
global hmr

procResult = initProcResultStruct('run');
procInput = [];
err = 0;

if iRun==0
    return;
end

% load data from selected file, only if it isn't already loaded
procInput_copyOptions = hmr.procInput;
[iFile i j k] = listboxFiles_getCurrSelection(handles);
if ~all([iGrp,iSubj,iRun]==[i j k])
    listboxFiles_setCurrSelection(handles,iGrp,iSubj,iRun);
    LoadCurrNIRSFile(hmr.group(iGrp).subjs(iSubj).runs(iRun).filename,handles);
end

if hmr.copyOptions
    if procInput_copyOptions.changeFlag>0
        hmr.group(iGrp).subjs(iSubj).procInput.changeFlag=1;
        hmr.group(iGrp).procInput.changeFlag=1;
    end
    hmr.procInput = procInput_copyOptions;
end

[procResult procInput err] = EasyNIRS_Process(hmr);
hmr.procResult = procResult;
hmr.procInput = procInput;

assert(~get(handles.pushbuttonNIRSsignalProcessCancel,'userdata'),...
       'Processing Cancelled');
       



% --------------------------------------------------------------------
function [procResult err] = sessNIRSsignalProcess(iGrp,iSubj,handles)
global hmr

procResult = initProcResultStruct('subj');
err = 0;

% Calculate all files in a session
nTrials_tot = zeros(1,length(hmr.group.conditions.CondNamesAct));
runs = hmr.group(iGrp).subjs(iSubj).runs;
nFiles = length(runs);
procResult_runs = cell(nFiles,1);
for iRun = 1:nFiles
    [procResult_runs{iRun} procInput_runs{iRun} err] = runNIRSsignalProcess(iGrp,iSubj,iRun,handles);
    if err
        return;
    end

    % Find smallest tHRF among the runs. We should make this the common one.
    if iRun==1
        tHRF_common = procResult_runs{iRun}.tHRF;
    elseif length(procResult_runs{iRun}.tHRF) < length(tHRF_common)
        tHRF_common = procResult_runs{iRun}.tHRF;    
    end
end

% Calculate subject OD
grp1=[];
for iRun = 1:nFiles
    % Set common tHRF: make sure size of tHRF, dcAvg and dodAvg is same for 
    % all runs. Use smallest tHRF as the common one.
    procResult_runs{iRun} = make_tHRFDataCommon(procResult_runs{iRun}, tHRF_common,...
                                                runs(iRun).filename,'run');
    dodAvg    = procResult_runs{iRun}.dodAvg;
    dodAvgStd = procResult_runs{iRun}.dodAvgStd;
    dodSum2   = procResult_runs{iRun}.dodSum2;
    tHRF      = procResult_runs{iRun}.tHRF;
    nTrials   = procResult_runs{iRun}.nTrials;
    if ~isempty(procResult_runs{iRun}.SD)
        SD = procResult_runs{iRun}.SD;
    else
        SD = procInput_runs{iRun}.SD;
    end
    fileidx  = runs(iRun).fileidx;

    if isempty(dodAvg)
        break;
    end

    % grab tHRF to make common for group average
    if iRun==1
        grp1 = zeros(size(dodAvg,1),size(dodAvg,2),length(hmr.group.conditions.CondNamesAct));
        grp1Sum2 = zeros(size(dodAvg,1),size(dodAvg,2),length(hmr.group.conditions.CondNamesAct));
        nTrials_tot = zeros(size(dodAvg,2),length(hmr.group.conditions.CondNamesAct));
    end
    
    lstChInc = find(SD.MeasListAct==1);
    for iC = 1:length(hmr.group.conditions.CondNamesAct)
        iS = hmr.group.conditions.CondRunIdx(fileidx,iC);
        if(iS==0)
            nT = 0;
        else
            nT = nTrials(iS);
        end

        if nT>0
            if iRun==1
                grp1(:,lstChInc,iC) = dodAvg(:,lstChInc,iS) * nT;
                grp1Sum2(:,lstChInc,iC) = dodSum2(:,lstChInc,iS);
                nTrials_tot(lstChInc,iC) = nT;
            else
                for iCh=1:length(lstChInc) %size(dodAvg,2)
                    grp1(:,lstChInc(iCh),iC) = grp1(:,lstChInc(iCh),iC) + interp1(tHRF,dodAvg(:,lstChInc(iCh),iS),tHRF') * nT;
                    grp1Sum2(:,lstChInc(iCh),iC) = grp1Sum2(:,lstChInc(iCh),iC) + interp1(tHRF,dodSum2(:,lstChInc(iCh),iS),tHRF');
                    nTrials_tot(lstChInc(iCh),iC) = nTrials_tot(lstChInc(iCh),iC) + nT;
                end
            end
        end
    end
end
dodAvg    = [];
dodAvgStd = [];
if ~isempty(grp1)
    for iC = 1:size(grp1,3)
        for iCh = 1:size(grp1,2)
            dodAvg(:,iCh,iC) = grp1(:,iCh,iC) / (nTrials_tot(iCh,iC)+eps);
            
            % We want to distinguish between no trials and 1 trial:
            % If there are no trials, we have no HRF data and no std which
            % the first case will calculate as opposed to one trial (2nd case)
            % where we have all zeros.
            if(nTrials_tot(iCh,iC)~=1)
                dodAvgStd(:,iCh,iC) = ( (1/(nTrials_tot(iCh,iC)-1))*grp1Sum2(:,iCh,iC) - (nTrials_tot(iCh,iC)/(nTrials_tot(iCh,iC)-1))*(grp1(:,iCh,iC) / nTrials_tot(iCh,iC)).^2).^0.5 ;
            else
                dodAvgStd(:,iCh,iC) = zeros(size(grp1Sum2(:,iCh,iC)));
            end
        end
    end
end

% Calculate subject Conc
grp1=[];
for iRun = 1:nFiles
    % Set common tHRF: make sure size of tHRF, dcAvg and dodAvg is same for 
    % all runs. Use smallest tHRF as the common one.
    procResult_runs{iRun} = make_tHRFDataCommon(procResult_runs{iRun}, tHRF_common,...
                                                runs(iRun).filename,'run');
    dcAvg    = procResult_runs{iRun}.dcAvg;
    dcAvgStd = procResult_runs{iRun}.dcAvgStd;
    dcSum2   = procResult_runs{iRun}.dcSum2;
    tHRF     = procResult_runs{iRun}.tHRF;
    nTrials  = procResult_runs{iRun}.nTrials;
    if ~isempty(procResult_runs{iRun}.SD)
        SD = procResult_runs{iRun}.SD;
    else
        SD = procInput_runs{iRun}.SD;
    end
    fileidx  = runs(iRun).fileidx;
    
    if isempty(dcAvg)
        break;
    end

    % grab tHRF to make common for group average
    if iRun==1
        grp1 = zeros(size(dcAvg,1),size(dcAvg,2),size(dcAvg,3),length(hmr.group.conditions.CondNamesAct));
        grp1Sum2 = zeros(size(dcAvg,1),size(dcAvg,2),size(dcAvg,3),length(hmr.group.conditions.CondNamesAct));
        nTrials_tot = zeros(size(dcAvg,3),length(hmr.group.conditions.CondNamesAct));
    end

    lst1 = find(SD.MeasList(:,4)==1);
    lstChInc = find(SD.MeasListAct(lst1)==1);
    for iC = 1:length(hmr.group.conditions.CondNamesAct)
        iS = hmr.group.conditions.CondRunIdx(fileidx,iC);
        if(iS==0)
            nT = 0;
        else
            nT = nTrials(iS);
        end

        if nT>0
            if iRun==1
                grp1(:,:,lstChInc,iC) = dcAvg(:,:,lstChInc,iS) * nT;
                grp1Sum2(:,:,lstChInc,iC) = dcSum2(:,:,lstChInc,iS);
                nTrials_tot(lstChInc,iC) = nT;
            else                
                for iCh=1:length(lstChInc) %size(dcAvg,3)
                    for iHb=1:3
                        grp1(:,iHb,lstChInc(iCh),iC) = grp1(:,iHb,lstChInc(iCh),iC) + interp1(tHRF,dcAvg(:,iHb,lstChInc(iCh),iS),tHRF') * nT;
                        grp1Sum2(:,iHb,lstChInc(iCh),iC) = grp1Sum2(:,iHb,lstChInc(iCh),iC) + interp1(tHRF,dcSum2(:,iHb,lstChInc(iCh),iS),tHRF');
                    end
                    nTrials_tot(lstChInc(iCh),iC) = nTrials_tot(lstChInc(iCh),iC) + nT;
                end
            end
        end
    end   
end
dcAvg    = [];
dcAvgStd = [];
if ~isempty(grp1)
    for iC = 1:size(grp1,4)
        for iCh = 1:size(grp1,3)
            dcAvg(:,:,iCh,iC) = grp1(:,:,iCh,iC) / nTrials_tot(iCh,iC);
            
            % We want to distinguish between no trials and 1 trial:
            % If there are no trials, we have no HRF data and no std which
            % the first case will calculate as opposed to one trial (2nd case)
            % where we have all zeros.
            if(nTrials_tot(iCh,iC)~=1)
                dcAvgStd(:,:,iCh,iC) = ( (1/(nTrials_tot(iCh,iC)-1))*grp1Sum2(:,:,iCh,iC) - (nTrials_tot(iCh,iC)/(nTrials_tot(iCh,iC)-1))*(grp1(:,:,iCh,iC) / nTrials_tot(iCh,iC)).^2).^0.5 ;
            else
                dcAvgStd(:,:,iCh,iC) = zeros(size(grp1Sum2(:,:,iCh,iC)));
            end
        end
    end
end

hmr.group(iGrp).subjs(iSubj).procResult.dodAvg = dodAvg;
hmr.group(iGrp).subjs(iSubj).procResult.dodAvgStd = dodAvgStd;
hmr.group(iGrp).subjs(iSubj).procResult.dcAvg = dcAvg;
hmr.group(iGrp).subjs(iSubj).procResult.dcAvgStd = dcAvgStd;
hmr.group(iGrp).subjs(iSubj).procResult.tHRF = tHRF_common;
hmr.group(iGrp).subjs(iSubj).procResult.nTrials = nTrials_tot;
procResult = hmr.group(iGrp).subjs(iSubj).procResult;

% Set this subjects procInputs to show that it is consistent with 
% this subject's procResult  
hmr.group(iGrp).subjs(iSubj).procInput.changeFlag = 0;
hmr.group(iGrp).subjs(iSubj).procInput.procInputRun = hmr.procInput;



% --------------------------------------------------------------------
function [procResult err] = groupNIRSsignalProcess(iGrp,handles)
global hmr

procResult = initProcResultStruct('group');
err = 0;

% check criteria for inclusion in group average
tRange  = str2num( get(handles.editGrpAvgPassTrange,'string') );
chkFlag = get(handles.checkboxGrpAvgPassAllCh,'value');
subjs = hmr.group(iGrp).subjs;
nSubj = length(subjs);
procResult_subjs = cell(nSubj,1);
for iSubj = 1:nSubj
    [procResult_subjs{iSubj} err] = sessNIRSsignalProcess(iGrp,iSubj,handles);
    if err
        return;
    end

    % Find smallest tHRF among the subjects.  We should make this the common one.
    if iSubj==1
        tHRF_common = procResult_subjs{iSubj}.tHRF;
    elseif length(procResult_subjs{iSubj}.tHRF) < length(tHRF_common)
        tHRF_common = procResult_subjs{iSubj}.tHRF;    
    end
end
subjCh = [];
nStim = 0;
thresh  = str2num( get(handles.editGrpAvgPassThresh,'string') ) * 1e-6;
nTrials = [];

% Calculate group Conc
grp1=[];
grpAvgPassDc = [];
for iSubj = 1:nSubj
    % Set common tHRF: Make sure size of tHRF, dcAvg and dodAvg is same 
    % for all subjects. Use first subject's tHRF as the common one.
    procResult_subjs{iSubj} = make_tHRFDataCommon(procResult_subjs{iSubj},tHRF_common, ...
                                            subjs(iSubj).name,'subject');
    dcAvg    = procResult_subjs{iSubj}.dcAvg;
    dcAvgStd = procResult_subjs{iSubj}.dcAvgStd;
    tHRF     = procResult_subjs{iSubj}.tHRF;
    nTrials  = procResult_subjs{iSubj}.nTrials;

    if isempty(dcAvg)
        continue;
    end

    if iSubj==1
        lstT = find(tHRF>=tRange(1) & tHRF<=tRange(2));
        grp1 = zeros(size(dcAvg,1),size(dcAvg,2),size(dcAvg,3),length(hmr.group.conditions.CondNamesAct));
    end
    
    if isempty(subjCh)
        subjCh = zeros(size(dcAvg,3),length(hmr.group.conditions.CondNamesAct));
        grpAvgPassDc = zeros(size(dcAvg,3),length(hmr.group.conditions.CondNamesAct),nSubj);
    end
    for iS = 1:length(hmr.group.conditions.CondNamesAct)
        % Calculate which channels to include and exclude from the group HRF avg,
        % based on the subjects' standard error and store result in lstPass 
        % also need to consider if channel was manually or
        % automatically included
        lstPass = find((squeeze(mean(dcAvgStd(lstT,1,:,iS),1))./sqrt(nTrials(:,iS)+eps)) <= thresh &...
                       (squeeze(mean(dcAvgStd(lstT,2,:,iS),1))./sqrt(nTrials(:,iS)+eps)) <= thresh &...
                       nTrials(:,iS)>0 );
        
        if chkFlag==0 | length(lstPass)==size(dcAvg,3)
            if iSubj==1 | iS>nStim
                for iPass=1:length(lstPass)
                    for iHb=1:3
                        grp1(:,iHb,lstPass(iPass),iS) = interp1(tHRF,dcAvg(:,iHb,lstPass(iPass),iS),tHRF');
                    end
                end
                subjCh(size(dcAvg,3),iS)=0;
                nStim = iS;
            else
                for iPass=1:length(lstPass)
                    for iHb=1:3
                        grp1(:,iHb,lstPass(iPass),iS) = grp1(:,iHb,lstPass(iPass),iS) + interp1(tHRF,dcAvg(:,iHb,lstPass(iPass),iS),tHRF');
                    end
                end
            end
            subjCh(lstPass,iS) = subjCh(lstPass,iS) + 1;
        end
        grpAvgPassDc(lstPass,iS,iSubj) = 1;
    end
end
dcAvg = [];
if ~isempty(grp1)
    for iS = 1:size(grp1,4)
        for iCh = 1:size(grp1,3)
            dcAvg(:,1,iCh,iS) = grp1(:,1,iCh,iS) / subjCh(iCh,iS);
            dcAvg(:,2,iCh,iS) = grp1(:,2,iCh,iS) / subjCh(iCh,iS);
            dcAvg(:,3,iCh,iS) = grp1(:,3,iCh,iS) / subjCh(iCh,iS);
        end
    end
end

% Calculate group OD
grpAvgPassDod = [];
subjCh = [];
nStim = 0;
thresh  = str2num( get(handles.editGrpAvgPassThresh,'string') );
grp1=[];
for iSubj = 1:nSubj
    % Set common tHRF: Make sure size of tHRF, dcAvg and dodAvg is same 
    % for all subjects. Use first subject's tHRF as the common one.
    procResult_subjs{iSubj} = make_tHRFDataCommon(procResult_subjs{iSubj},tHRF_common, ...
                                            subjs(iSubj).name,'subject');
    dodAvg    = procResult_subjs{iSubj}.dodAvg;
    dodAvgStd = procResult_subjs{iSubj}.dodAvgStd;
    tHRF      = procResult_subjs{iSubj}.tHRF;
    nTrials   = procResult_subjs{iSubj}.nTrials;

    if isempty(dodAvg)
        continue;
    end

    if iSubj==1
        lstT  = find(tHRF>=tRange(1) & tHRF<=tRange(2));
        grp1 = zeros(size(dodAvg,1),size(dodAvg,2),length(hmr.group.conditions.CondNamesAct));
    end
    
    if isempty(subjCh)
        subjCh = zeros(size(dodAvg,2),length(hmr.group.conditions.CondNamesAct));
        grpAvgPassDod = zeros(size(dodAvg,2),length(hmr.group.conditions.CondNamesAct),nSubj);
    end
    for iS = 1:length(hmr.group.conditions.CondNamesAct)
        for iWl = 1:2
            % Calculate which channels to include and exclude from the group HRF avg,
            % based on the subjects' standard error and store result in lstPass 
            lstWl = find(hmr.SD.MeasList(:,4)==iWl);
            lstPass = find(((squeeze(mean(dodAvgStd(lstT,lstWl,iS),1))./sqrt(nTrials(lstWl,iS)'+eps)) <= thresh) &...
                            nTrials(lstWl,iS)'>0);                        
            lstPass = lstWl(lstPass);

            if chkFlag==0 | length(lstPass)==size(dodAvg,3)
                if iSubj==1 | iS>nStim
                    for iPass=1:length(lstPass)
                        grp1(:,lstPass(iPass),iS) = interp1(tHRF,dodAvg(:,lstPass(iPass),iS),tHRF');
                    end
                    subjCh(size(dodAvg,2),iS)=0;
                    nStim = iS;
                else
                    for iPass=1:length(lstPass)
                        grp1(:,lstPass(iPass),iS) = grp1(:,lstPass(iPass),iS) + interp1(tHRF,dodAvg(:,lstPass(iPass),iS),tHRF');
                    end
                end
                subjCh(lstPass,iS) = subjCh(lstPass,iS) + 1;
            end
            grpAvgPassDod(lstPass,iS,iSubj) = 1;
        end
    end
end
dodAvg = [];
if ~isempty(grp1)
    for iS = 1:size(grp1,3)
        for iCh = 1:size(grp1,2)
            dodAvg(:,iCh,iS) = grp1(:,iCh,iS) / subjCh(iCh,iS);
            dodAvg(:,iCh,iS) = grp1(:,iCh,iS) / subjCh(iCh,iS);
            dodAvg(:,iCh,iS) = grp1(:,iCh,iS) / subjCh(iCh,iS);
        end
    end
end

hmr.group(iGrp).procResult.dodAvg = dodAvg;
hmr.group(iGrp).procResult.dcAvg = dcAvg;
hmr.group(iGrp).procResult.tHRF = tHRF_common;
hmr.group(iGrp).procResult.nTrials = nTrials;
if ~isempty(grpAvgPassDc)
    hmr.group(iGrp).procResult.grpAvgPass = grpAvgPassDc;
else
    nCh=size(dodAvg,2)/2;
    hmr.group(iGrp).procResult.grpAvgPass = grpAvgPassDod(1:nCh,:,:);
end
procResult = hmr.group(iGrp).procResult;

% Set this group's procInputs to show that it is consistent with 
% this group's procResult  
hmr.group(iGrp).procInput.changeFlag = 0;
hmr.group(iGrp).procInput.procInputSubj.procInputRun = hmr.procInput;



% --------------------------------------------------------------------
% --- Executes on selection change in popupmenuNIRSsignalProcess.
function popupmenuNIRSsignalProcess_Callback(hObject, eventdata, handles)
global hmr
global HRF_OFF_CONST
global HRF_RUN_CONST
global HRF_SESS_CONST
global HRF_GRP_CONST

if isempty(hmr.procInput) | isempty(hmr.procInput.procFunc)
    ch = menu( sprintf('Warning: processing options config file is empty or has bad syntax.'),'Okay');
    return;
end

val = get(hObject,'value');

[iFile iGrp iSubj iRun] = listboxFiles_getCurrSelection(handles);
if iSubj==0
    warning( 'This should not happen!' );
    return;
end

try

    set(handles.pushbuttonNIRSsignalProcessCancel,'visible','on')
    if(val==log2(HRF_RUN_CONST)+1)
        runNIRSsignalProcess(iGrp,iSubj,iRun,handles);
    elseif(val==log2(HRF_SESS_CONST)+1)
        sessNIRSsignalProcess(iGrp,iSubj,handles);
    elseif(val==log2(HRF_GRP_CONST)+1)
        groupNIRSsignalProcess(iGrp,handles);
    end

    % We want to execute the catch block even if there are no user 
    % interrupts during processing. Hence assert(0) at end of 
    % processing
    assert(logical(0),'End Processing');

catch ME

    if strcmp(ME.message,'Processing Cancelled') || ...
       strcmp(ME.message,'End Processing')

        % Current file has changed, get indices for the current file.
        [iFile iGrp iSubj iRun] = listboxFiles_getCurrSelection(handles);   
        if iRun==0
            return;
        end
        set(handles.pushbuttonNIRSsignalProcessCancel,'userdata',0);
        hmr.group(iGrp) = checkGrpProcParamValidity(hmr.group(iGrp),val,iSubj,iRun);
        EasyNIRS_CheckPlotButtons(handles);
        EasyNIRS_NIRSsignalProcessUpdate(hmr);
        EasyNIRS_DisplayData();
        EasyNIRS_plotAxesSDG();
        checkboxPlotProbe_Callback(handles.checkboxPlotProbe, eventdata, handles);
        set(handles.pushbuttonNIRSsignalProcessCancel,'visible','off')        
        set(hmr.handles.pushbuttonSave,'visible','off');
        hmr.fileChanged=0;
        saveGroup();        

    else

        rethrow(ME);

    end
end

if isfield(hmr.procResult,'tIncChAuto')
    set(handles.checkboxShowMotionByChannel,'enable','on');
else
    set(handles.checkboxShowMotionByChannel,'enable','off');
end


% --------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function popupmenuNIRSsignalProcess_CreateFcn(hObject, eventdata, handles)

set(hObject,'string',{'Run','Session','Group'});
set(hObject,'value',1);



% --------------------------------------------------------------------
function checkboxCopyOptions_Callback(hObject, eventdata, handles) 
global hmr

% The addition of the class(eventdata) condition is for Matlab 2014b compatibility
if ~isempty(eventdata) & ~strcmp(class(eventdata), 'matlab.ui.eventdata.ActionData')
    set(hObject,'value',eventdata);
end

hmr.copyOptions = get(hObject,'value');

if isempty(hmr.procInput)
    return;
end

h = findobj('Tag','EasyNIRS_ProcessOpt');
if ~isempty(h)
    EasyNIRS_ProcessOpt();
end
EasyNIRS_NIRSsignalProcessUpdate(hmr);



% --------------------------------------------------------------------
function menuExportHRF_Callback(hObject, eventdata, handles)
global hmr

%{
[filename pathname] = uiputfile('*.txt', 'Export HRF File Name:' );
if filename==0
    return
end
%}

iSubjCurr = hmr.listboxFileCurr.iSubj;
nSubj = length(hmr.group.subjs);
opt1 = menu('Export currently selected subject or all subjects?','Current','All');
opt2 = menu('What format?','Conditions displayed horizontally','Conditions displayed vertically');

% Race condition: give menu chance to
% disappear before we start exporting
pause(.1);

if opt2==1
    if opt1==1
        hwait = waitbar(0, sprintf('Exporting HRF for subject %s. This may take a few seconds...',...
                                   hmr.group.subjs(iSubjCurr).name));
        ExportHRF(hmr.group.subjs(iSubjCurr),hmr.group.conditions.CondNamesAct,[],3);
        close(hwait);
    elseif opt1==2
        hwait = waitbar(0, 'Exporting HRF for all subject. This may take a few minutes...');
        for iSubj=1:nSubj
            hwait = waitbar(iSubj/nSubj, hwait, sprintf('Exporting data to %s_HRF.txt', ...
                            hmr.group.subjs(iSubj).name) );
            ExportHRF(hmr.group.subjs(iSubj),hmr.group.conditions.CondNamesAct,[],3);
        end
        close(hwait);
    end
elseif opt2==2
    if opt1==1
       hwait = waitbar(0, sprintf('Exporting HRF for subject %s. This may take a few seconds...',...
                                  hmr.group.subjs(iSubjCurr).name));
       ExportHRF(hmr.group.subjs(iSubjCurr),hmr.group.conditions.CondNamesAct,[],7);
       close(hwait);
    elseif opt1==2
       hwait = waitbar(0, 'Exporting HRF for all subject. This may take a few minutes...');     
       for iSubj=1:nSubj
           hwait = waitbar(iSubj/nSubj, hwait, sprintf('Exporting data to %s_HRF.txt', ...
                           hmr.group.subjs(iSubj).name) );
           ExportHRF(hmr.group.subjs(iSubj),hmr.group.conditions.CondNamesAct,[],7);
       end
       close(hwait);
    end
end



% --------------------------------------------------------------------
function menuExportMeanResults_Callback(hObject, eventdata, handles)

global hmr

[filename pathname] = uiputfile('*.txt', 'Export Mean Responce File Name:' );
if filename==0
    return
end

tMinMax=inputdlg({'tMin','tMax'},'Time HRF sub-range');
if(isempty(tMinMax))
    return;
end
if(isempty(tMinMax{1}) | isempty(tMinMax{2}))
    return;
end
tMin=str2num(tMinMax{1});
tMax=str2num(tMinMax{2});
if(isempty(tMin) | ~isnumeric(tMin) | isempty(tMax) | ~isnumeric(tMax))
    return;
end
if(~isempty(hmr.group(1).procResult) & isfield(hmr.group(1).procResult,'grpAvgPass'))
    dcAvgMeanAll = ExportHRFMean(hmr.group,tMin,tMax,hmr.group.conditions.CondNamesAct,[pathname filename]);
    for ii=1:length(dcAvgMeanAll)
        if isempty(dcAvgMeanAll)
            return;
        end
    end                                 
end



% --------------------------------------------------------------------
function menuLoadProcessOpt_Callback(hObject, eventdata, handles)
global hmr

[filename pathname] = uigetfile('*.cfg', 'Load Process Options File' );
if filename==0
    return
end

% Init group procInput before loading
EasyNIRS_ProcessOpt_Init([pathname filename]);

% Update associated GUI's
h = findobj('Tag','EasyNIRS_ProcessOpt');
if ~isempty(h)
    EasyNIRS_ProcessOpt();
end
EasyNIRS_NIRSsignalProcessUpdate(hmr);



% --------------------------------------------------------------------
function menuExportProcessOpt_Callback(hObject, eventdata, handles)

[filename, pathname] = uiputfile('*.cfg', 'File Name to export to:' );
if filename==0
    return
end
wd = cd();
cd(pathname);
EasyNIRS_ProcessOptExport(filename);
cd(wd);


% ---------------------------------------------------------------------
function saveGroup()
global hmr;

hwait = waitbar(0,'Saving group results...');
group = hmr.group(1);
filenm = 'groupResults.mat';
save( ['./' filenm],'group');
close(hwait);

% Has to be an atomic operation because procInput stream has to apply to the 
% whole group and if a new one is loaded, it is only in RAM until we actually 
% calculate the HRF or do an explicit save. If HRF processing was halted only 
% the procInput the finished runs will get saved to the .nirs files. If the 
% processing stream was changed that will leave the unfinished runs with the 
% previous processing stream. Therefore we save the procInput to every run 
% for which HRF wasn't calculated.
hwait = waitbar(0,'Saving new proc stream to unprocessed runs...');
nFiles = group(1).nFiles;
ii=1;
%for ii=1:length(group)
    for jj=1:length(group(ii).subjs)
        for kk=1:length(group(ii).subjs(jj).runs)
            hwait = waitbar(hmr.group(ii).subjs(jj).runs(kk).fileidx/nFiles, hwait, ...
                        sprintf('Saving new proc. stream to file %s, %d of %d',...
                                hmr.group(ii).subjs(jj).runs(kk).filename,...
                                hmr.group(ii).subjs(jj).runs(kk).fileidx,...
                                nFiles) );            
            if hmr.group(ii).subjs(jj).runs(kk).procInput.changeFlag==2
                hmr.group(ii).subjs(jj).runs(kk).procInput.changeFlag=1;
                procInput = hmr.group(ii).subjs(jj).runs(kk).procInput;
                save(hmr.group(ii).subjs(jj).runs(kk).filename,'procInput','-mat','-append');
            end
        end
    end
%end
close(hwait);



% ---------------------------------------------------------------------
function s = initHmr(hFig,GUIarg)

% Set the figure renderer. Some renderers aren't compatible 
% with certain OSs or graphics cards. Homer2_UI uses the figure renderer 
% when displaying patches. Allow user to set the renderer that is best 
% for the host system. 
% 
if length(GUIarg)>0
    if strcmp(lower(GUIarg{1}),'zbuffer') || ...
       strcmp(lower(GUIarg{1}),'painters') || ...
       strcmp(lower(GUIarg{1}),'opengl')

        set(hFig,'renderer',GUIarg{1});
        set(hFig,'renderermode','manual');

    elseif strcmp(lower(GUIarg{1}),'rendererauto')

        if isunix()
            set(hObject,'renderer','painters');
        elseif ispc()
            set(hFig,'renderer','painters');
        else
            set(hFig,'renderer','zbuffer');
        end
        set(hFig,'renderermode','manual');

    end
end

s = struct(...
           'SD',[], ...
           't',[], ...
           'd',[], ...
           's',[], ...
           'aux',[], ...
           'tIncMan',[], ...
           'fileChanged',0, ...
           'userdata',[], ...
           'procInput',initProcInputStruct('run'), ...
           'procResult',initProcResultStruct('run'), ...
           'copyOptions',0, ...
           'stim',[], ...
           'group',[], ...
           'displayAxes',0, ...
           'ZoomEtc',1 ...
          );

if exist(getAppDir(),'dir')
    addpath(getAppDir(),'-end')
end


      
% ---------------------------------------------------------------------
function EasyNIRS_EnableDisableGUI(handles,val)

set(handles.radiobuttonPlotRaw, 'enable',val);
set(handles.radiobuttonPlotOD,  'enable',val);
set(handles.radiobuttonPlotConc,'enable',val);
set(handles.radiobuttonTimeExclude,'enable',val);
set(handles.radiobuttonStim,'enable',val);
set(handles.checkboxPlotHRFGrp, 'enable',val);
set(handles.checkboxPlotHRFSess,'enable',val);
set(handles.checkboxPlotHRFRun, 'enable',val);
set(handles.pushbuttonSave, 'enable',val);
set(handles.popupmenuNIRSsignalProcess,'enable',val);
set(handles.popupmenuCondition,'enable',val);
set(handles.checkboxCopyOptions,'enable',val);
set(handles.radiobuttonZoom,'enable',val);
set(handles.checkboxPlotAux,'enable',val);
set(handles.checkboxPlotProbe,'enable',val);
set(handles.checkboxShowExcluded,'enable',val);
set(handles.checkboxDisplayStim,'enable',val);
set(handles.pushbuttonSignalProcessAdvOpt,'enable',val);
set(handles.pushbuttonZoomReset,'enable',val);
set(handles.checkboxDisplayStim,'enable',val);
set(handles.pushbuttonPanRight,'enable',val);
set(handles.pushbuttonPanLeft,'enable',val);
set(handles.listboxPlotWavelength,'enable',val);
set(handles.uipanelGrpAvg,'visible',val);
set(handles.menuViewHRFStdErr,'enable',val);
set(handles.menuPlotPowerSpectrum,'enable',val);
set(handles.menuCopyCurrentPlot,'enable',val);
set(handles.menuProcStreamGUI,'enable',val);
set(handles.menuStimGUI,'enable',val);
set(handles.menuAutosavePlotFigsToFile,'enable',val);
set(handles.menuExportProcessOpt,'enable',val);
set(handles.menuLoadProcessOpt,'enable',val);
set(handles.menuExportMeanResults,'enable',val);
set(handles.menuResetFile,'enable',val);
if strcmp(val,'off')
    set(handles.listboxFiles,'string',{});
    set(handles.listboxFilesErr,'string',{});
end
set(handles.popupmenuGroupList,'enable',val);
set(handles.popupmenuGroupList,'value',1);
set(handles.popupmenuGroupList,'string','current Group');
set(handles.editWaterfall,'enable',val)
set(handles.radiobuttonPan,'enable',val);
set(handles.checkboxShowMotionByChannel,'enable',val);


% ---------------------------------------------------------------------
function pushbuttonNIRSsignalProcessCancel_Callback(hObject, eventdata, handles)

ch = menu('Halt HRF processing?','Yes','No');
if ch==1 
    set(hObject,'userdata',1);
end


% --------------------------------------------------------------------
function menuAutosavePlotFigsToFile_Callback(hObject, eventdata, handles)
checked=get(hObject,'checked');
if(strcmp(checked,'off'))
    set(hObject,'checked','on');
elseif(strcmp(checked,'on'))
    set(hObject,'checked','off');
end



% --------------------------------------------------------------------
function menuProcStreamGUI_Callback(hObject, eventdata, handles)
global hmr

procStreamGUI(hmr.s,hmr.t,hmr.userdata);



% --------------------------------------------------------------------
function menuExit_Callback(hObject, eventdata, handles)

hGui=get(get(hObject,'parent'),'parent');
EasyNIRS_DeleteFcn(hGui,eventdata,handles);
close(hGui);


% --------------------------------------------------------------------
function menuLoadGroupResults_Callback(hObject, eventdata, handles)
global hmr

[filenm,pathnm] = uigetfile( 'Load Group Results', 'groupResults*.mat');
if filenm==0
    return;
end

load( [pathnm filenm] );

nGrps = length(hmr.group);
hmr.group(end+1) = group;

grpStr = get(handles.popupmenuGroupList,'string');
if ~iscell(grpStr)
    foo = grpStr;
    clear grpStr;
    grpStr{1} = foo;
end
grpStr{end+1} = filenm;
set(handles.popupmenuGroupList,'string',grpStr);
set(handles.popupmenuGroupList,'value',nGrps+1);

hmr.listboxFileCurr.iGrp = nGrps+1;

set(handles.pushbuttonSignalProcessAdvOpt,'enable','off');
set(handles.popupmenuNIRSsignalProcess,'enable','off');
set(handles.radiobuttonPlotRaw,'enable','off');
set(handles.radiobuttonPlotOD,'enable','off');
set(handles.checkboxPlotHRFRun,'enable','off');

if get(handles.checkboxPlotHRFGrp,'value')==0
    set(handles.checkboxPlotHRFGrp,'value',1);
    set(handles.checkboxPlotHRFSess,'value',0);
    set(handles.checkboxPlotHRFRun,'value',0);
end    
    
EasyNIRS_DisplayData();
checkboxPlotProbe_Callback(handles.checkboxPlotProbe, eventdata, handles);





% --------------------------------------------------------------------
function popupmenuGroupList_Callback(hObject, eventdata, handles)
global hmr

iGrp = get(hObject,'value');
hmr.listboxFileCurr.iGrp = iGrp;

if iGrp==1
    set(handles.pushbuttonSignalProcessAdvOpt,'enable','on');
    set(handles.popupmenuNIRSsignalProcess,'enable','on');
    set(handles.radiobuttonPlotRaw,'enable','on');
    set(handles.radiobuttonPlotOD,'enable','on');
    set(handles.checkboxPlotHRFRun,'enable','on');
else
    set(handles.pushbuttonSignalProcessAdvOpt,'enable','off');
    set(handles.popupmenuNIRSsignalProcess,'enable','off');
    set(handles.radiobuttonPlotRaw,'enable','off');
    set(handles.radiobuttonPlotOD,'enable','off');
    set(handles.checkboxPlotHRFRun,'enable','off');
end

EasyNIRS_DisplayData();
checkboxPlotProbe_Callback(handles.checkboxPlotProbe, eventdata, handles);


% --------------------------------------------------------------------
function menuRemoveGroupResults_Callback(hObject, eventdata, handles)
global hmr

iGrp = hmr.listboxFileCurr.iGrp;
if iGrp == 1
    return;
end

nGrp = length(hmr.group);

for ii=iGrp:(nGrp-1)
    hmr.group(ii) = hmr.group(ii+1);
end
hmr.group(end) = [];

grpStr = get(handles.popupmenuGroupList,'string');
for ii=1:(iGrp-1)
    grpStr2{ii} = grpStr{ii};
end
for ii=iGrp:(nGrp-1)
    grpStr2{ii} = grpStr{ii+1};
end

set(handles.popupmenuGroupList,'value',1);
hmr.listboxFileCurr.iGrp = 1;

if length(grpStr2)==1
    set(handles.popupmenuGroupList,'string',grpStr2{1});
else
    set(handles.popupmenuGroupList,'string',grpStr2);
end

EasyNIRS_DisplayData();
checkboxPlotProbe_Callback(handles.checkboxPlotProbe, eventdata, handles);


% --------------------------------------------------------------------
function checkboxShowMotionByChannel_Callback(hObject, eventdata, handles)
global hmr

hmr.flagShowMotionByChannel = get(handles.checkboxShowMotionByChannel,'value');
EasyNIRS_DisplayData();


% --------------------------------------------------------------------
function menuExportProcessScript_Callback(hObject, eventdata, handles)
global hmr

[filenm,pathnm] = uiputfile( '*.m', 'Export Processing Script to:' );
if filenm==0
    return;
end

hmr0 = hmr;


[procResult procInput err fcallList] = EasyNIRS_Process(hmr0,1);

wd = cd;
cd(pathnm)
fid = fopen(filenm,'w');
for ii=1:length(fcallList)
    fprintf(fid,'%s\n\n',fcallList{ii});
end
fclose(fid);
cd(wd)



% --------------------------------------------------------------------
function editWaterfall_Callback(hObject, eventdata, handles)
global hmr

foo = str2num(get(hObject,'string'));
if isempty(foo)
    foo = 0;
    set(hObject,'string','0');
end

hmr.plotWaterfall = foo;
EasyNIRS_DisplayData();



% --------------------------------------------------------------------
function checkboxPlotRange_Callback(hObject, eventdata, handles)
global hmr
hmr.flagPlotRange = get(hObject,'value');
EasyNIRS_DisplayData();


% --------------------------------------------------------------------
function editPlotRange_Callback(hObject, eventdata, handles)
global hmr
foo = str2num(get(hObject,'string'));
if length(foo)~=2
    set(hObject,'string',sprintf('%.1f %.1f',hmr.plotRange(1),hmr.plotRange(2)));
else
    hmr.plotRange = foo;
    EasyNIRS_DisplayData();
end

% --- Executes on button press in checkbox16.
function checkbox16_Callback(hObject, eventdata, handles)
global hmr
hmr.flagPlottRange = get(hObject,'value');
EasyNIRS_DisplayData();




function edit10_Callback(hObject, eventdata, handles)
global hmr
foo = str2num(get(hObject,'string'));
if length(foo)~=2
    set(hObject,'string',sprintf('%d %d',hmr.plottRange(1),hmr.plottRange(2)));
else
    hmr.plottRange = foo;
    EasyNIRS_DisplayData();
end



% --------------------------------------------------------------------
function menuSaveGroupResults_Callback(hObject, eventdata, handles)
global hmr

[filenm, pathnm] = uiputfile( '*.mat','Save Group Results');
if filenm==0
    return;
end
hwait = waitbar(0,'Saving group results...');
group = hmr.group(1);
save( [pathnm filenm],'group');
close(hwait);


% --------------------------------------------------------------------
function menuDownsampleNIRSfile_Callback(hObject, eventdata, handles)
% hObject    handle to menuDownsampleNIRSfile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hmrNirsFileDownsample();


% --------------------------------------------------------------------
function menuSegmentNIRSFile_Callback(hObject, eventdata, handles)
% hObject    handle to menuSegmentNIRSFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hmrNirsFileSegment();


% --- Executes during object creation, after setting all properties.
function edit10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
