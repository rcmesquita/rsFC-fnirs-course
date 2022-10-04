function varargout = stimGUI(varargin)
% STIMGUI M-file for stimGUI.fig
%      STIMGUI, by itself, creates a new STIMGUI or raises the existing
%      singleton*.
%
%      H = STIMGUI returns the handle to a new STIMGUI or the handle to
%      the existing singleton*.
%
%      STIMGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in STIMGUI.M with the given input arguments.
%
%      STIMGUI('Property','Value',...) creates a new STIMGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before stimGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to stimGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help stimGUI

% Last Modified by GUIDE v2.5 15-Feb-2013 22:18:19

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @stimGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @stimGUI_OutputFcn, ...
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
% End initialization code - DO NOT EDIT


%---------------------------------------------------------------------------
% --- Executes just before stimGUI is made visible.
function stimGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to stimGUI (see VARARGIN)

% Choose default command line output for stimGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes stimGUI wait for user response (see UIRESUME)
% uiwait(handles.stimGUI);

% if length(varargin)==1  % check if vald filename
%     if ~exist(varargin{1},'file')
%         menu(sprintf('%s does not exist',varargin{1}),'Okay');
%         
%     else
%         loadNIRS( handles, varargin{1} );
%     end
% end
global hmr
global stim

stimGUI_reset();

if ~isempty(hmr)
    stim.filename = hmr.filename;
    
    stim.SD = hmr.SD;
    stim.aux = hmr.aux;
    stim.t = hmr.t;
    if isfield(hmr,'s')
        stim.s = hmr.s;
    else
        stim.s = zeros(length(stim.t),1);
    end
    SD = stim.SD;
    stim.iFile = hmr.listboxFileCurr.iFile;
    
    % set Aux listbox
    if(isempty(stim.aux))
        set(handles.pushbuttonApply,'enable','off');
        set(handles.editTmin,'enable','off');
        set(handles.editThreshold,'enable','off');
        set(handles.listboxAux,'string','');
        set(handles.listboxAux,'enable','off');
        set(handles.textTmin,'enable','off');
        set(handles.textThreshold,'enable','off');
        stim.iAux = 0;
    else
        foos = [];
        if ~isfield(stim.SD,'auxChannels')
            stim.SD.auxChannels = {};
        end
        m=length(stim.SD.auxChannels);
        n=size(stim.aux,2);
        d = m-n;
        if d>0
            stim.SD.auxChannels(n+1:end) = [];
        elseif d<0
            for ii=m+1:n
                stim.SD.auxChannels{ii} = ['Aux ',num2str(ii)];
            end
        end
        
        set(handles.listboxAux,'string',stim.SD.auxChannels);
        set(handles.listboxAux,'value',1);
        stim.iAux = 1;
    end
        
    stim.what_changed = {};
    stim.userdata = hmr.userdata;
    stim.CondNames = hmr.stim.CondNames;
    stim.CondNamesAct = hmr.group.conditions.CondNamesAct;
    stim.CondRunIdx = hmr.group.conditions.CondRunIdx;
    stim.CondTbl = hmr.group.conditions.CondTbl;
    stim.CondColTbl = hmr.group.conditions.CondColTbl;
    stim.CondColTbl(:,4) = 1;
    stim.LegendHdl = -1;
    stim.linewidthReg = 2;
    stim.linewidthHighl = 4;
    stim.handles.axes1 = handles.axes1;
    stim.handles.radiobuttonZoom = handles.radiobuttonZoom;
    stim.handles.radiobuttonStim = handles.radiobuttonStim;
    stim.handles.tableUserData = handles.tableUserData;
    stim.handles.pushbuttonSave = handles.pushbuttonSave;
    stim.handles.stimGUI = hObject;
    
    set(handles.textFileName, 'string',sprintf('CURRENT FILE:  %s', hmr.filename));
    set(handles.textFileName, 'fontsize',9);
    stimGUI_DisplayData(  );
    EasyNIRS_stimDataUpdate(stim,{'userdata'});

else    % Rather than closing gui, just disable all controls and allow users to load valid .nirs file

    menu( 'ERROR: stimGUI was not called with the proper structure defined','Okay');
    stim.flagHMR = 0;

end
hmr.handles.stimGUI=hObject;



%---------------------------------------------------------------------------
% --- Outputs from this function are returned to the command line.
function varargout = stimGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;




%---------------------------------------------------------------------------
function loadNIRS( handles, filenm )
global stim

load(filenm,'-mat')

if ~exist('aux')
    if exist('aux10')
        aux = aux10;
    else
        menu( 'There is no Aux data','okay');
        return;
    end
end

stim.s = s;
stim.SD = SD;
stim.aux = aux;
stim.t = t;

% set Aux listbox
foos = [];
for ii=1:size(aux,2)
    if isfield(SD,'auxChannels')
        foos{end+1} = SD.auxChannels{ii};
    else
        foos{end+1} = sprintf('Aux %d',ii);
    end
end
set(handles.listboxAux,'string',foos);
set(handles.listboxAux,'value',1);
stim.iAux = 1;

stimGUI_DisplayData();



%---------------------------------------------------------------------------
% --- Executes on selection change in listboxAux.
function listboxAux_Callback(hObject, eventdata, handles)
global stim

stim.iAux = get(hObject,'value');
stimGUI_DisplayData(  );


%---------------------------------------------------------------------------
% --- Executes on button press in pushbuttonApply.
function pushbuttonApply_Callback(hObject, eventdata, handles)
global stim

thresh = str2num(get(handles.editThreshold,'string'));
tmin = str2num(get(handles.editTmin,'string'));

so = stim.aux(:,stim.iAux);
t = stim.t;

lst = find(so>thresh);
if isempty(lst)
    return;
end
lst2 = find(diff(t(lst))>tmin);
lst3 = [lst(1); lst(lst2+1)];
lst4 = 1:length(lst3);

stim.what_changed=[stim.what_changed stimGUI_AddEditDelete(lst3,lst4,1)];
if ~isempty(stim.what_changed)
    set(stim.handles.pushbuttonSave,'enable','on');
end
stimGUI_DisplayData();



%---------------------------------------------------------------------------
% --- Executes on button press in radiobuttonZoom.
function radiobuttonZoom_Callback(hObject, eventdata, handles)
stimGUI_DisplayData();


%---------------------------------------------------------------------------
% --- Executes on button press in radiobuttonStim.
function radiobuttonStim_Callback(hObject, eventdata, handles)
stimGUI_DisplayData();


%---------------------------------------------------------------------------
% --- Executes when entered data in editable cell(s) in tableUserData.
function tableUserData_CellEditCallback(hObject, eventdata, handles)
global stim

if(~isempty(eventdata.Indices))
    r=eventdata.Indices(1);
    c=eventdata.Indices(2);
    for ii=1:length(stim.Lines)
        if ii==r
            set(stim.Lines(ii).handle,'color',stim.Lines(ii).color,'linewidth',stim.linewidthHighl);
        else
            set(stim.Lines(ii).handle,'color',stim.Lines(ii).color,'linewidth',stim.linewidthReg);
        end
    end
    stim.userdata.data(:,2:end) = get(hObject,'data');
    stim.userdata.data(:,1) = get(hObject,'userdata');
    set(stim.handles.pushbuttonSave,'enable','on');
    stim.what_changed{end+1} = 'userdata';
    stimGUI_DisplayData(r);
end



%---------------------------------------------------------------------------
function tableUserData_CellSelectionCallback(hObject, eventdata, handles)
global stim

if(~isempty(eventdata.Indices))
    r=eventdata.Indices(1);
    c=eventdata.Indices(2);
    for ii=1:length(stim.Lines)
        if ii==r
            set(stim.Lines(ii).handle,'color',stim.Lines(ii).color,'linewidth',stim.linewidthHighl);
        else
            set(stim.Lines(ii).handle,'color',stim.Lines(ii).color,'linewidth',stim.linewidthReg);
        end
    end
end


%---------------------------------------------------------------------------
function stimGUI_ButtonDownFcn(hObject, eventdata, handles)
global stim

for ii=1:length(stim.Lines)
    set(stim.Lines(ii).handle,'color',stim.Lines(ii).color,'linewidth',stim.linewidthReg);
end


%---------------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function tableUserData_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tableUserData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global stim

hcm = uicontextmenu();
set(hObject,'uicontextmenu',hcm);
hcm_AddDelColumns = uimenu('parent',hcm,'handlevisibility','callback',...
                           'label','Add Columns','callback',@tableUserDataMenu_AddCol_Callback);
hcm_AddDelColumns = uimenu('parent',hcm,'handlevisibility','callback',...
                           'label','Delete Columns','callback',@tableUserDataMenu_DeleteCol_Callback);
hcm_NameColumns = uimenu('parent',hcm,'handlevisibility','callback','label','Name Columns',...
                         'label','Name Columns','callback',@tableUserDataMenu_NameCol_Callback);



%---------------------------------------------------------------------------
function tableUserDataMenu_AddCol_Callback(hObject, eventdata, handles)
global stim

data=stim.userdata.data;
Dt=data(:,1);
D=data(:,2:end);
nrows=size(D,1);
ncols=size(D,2);

n=inputdlg({'number of columns to add:'},'Add Column');
if(isempty(n))
    return;
end
if(isempty(n{1}))
    return;
end
n=str2num(n{1});
if(~isscalar(n) || n<1)
    return;
end

cnames=stim.userdata.cnames;
cnames=reshape(cnames,1,length(cnames));
for i=1:n
    cnames=[cnames, num2str(ncols+i)];
end
D2=repmat({''},nrows,n);
D=[D D2];

% Recalculate size of A and update 
nrows_new=size(D,1);
ncols_new=size(D,2);
cwidth=repmat({100},1,ncols_new);
ceditable=logical(ones(1,ncols_new));

tableUserData_Update(stim.handles,[Dt D],cnames,cwidth,ceditable);
set(stim.handles.pushbuttonSave,'enable','on');
stim.what_changed{end+1} = 'userdata_cols';



%---------------------------------------------------------------------------
function tableUserDataMenu_DeleteCol_Callback(hObject, eventdata, handles)
global stim

data=stim.userdata.data;
Dt=data(:,1);
D=data(:,2:end);
nrows=size(D,1);
ncols=size(D,2);

n=inputdlg({'column number:'},'Delete Column');
if(isempty(n))
    return;
end
if(isempty(n{1}))
    return;
end
n=str2num(n{1});
if(~isempty(find(n<1 | n>ncols)))
    return;
end

cnames=stim.userdata.cnames;
cnames=reshape(cnames,1,length(cnames));
cnames(n)=[];
D(:,n)=[];

% Recalculate size of A and update 
ncols_new=size(D,2);
cwidth=repmat({100},1,ncols_new);
ceditable=logical(ones(1,ncols_new));

tableUserData_Update(stim.handles,[Dt D],cnames,cwidth,ceditable);
set(stim.handles.pushbuttonSave,'enable','on');
stim.what_changed{end+1} = 'userdata_cols';


%---------------------------------------------------------------------------
function tableUserDataMenu_NameCol_Callback(hObject, eventdata, handles)
global stim

data=stim.userdata.data;
D=data(:,2:end);
nrows=size(D,1);
ncols=size(D,2);

d=inputdlg({'column number:','column name'},'Name Column');
if(isempty(d))
    return;
end
if(length(d)<2)
    return;
end
if(isempty(d{1}) | isempty(d{2}))
    return;
end
n=str2num(d{1});
if(isempty(n) | n(1)>ncols | n(1)<1)
    return;
end
name=d{2};

% Assign new name to selected column
cnames=stim.userdata.cnames;
cnames(n)={name};

% Update stim and stimGUI table
tableUserData_Update(stim.handles,[],cnames,[],[],'cnames');
set(stim.handles.pushbuttonSave,'enable','on');
stim.what_changed{end+1} = 'userdata_cols';



%---------------------------------------------------------------------------
function stimMarksEdit_Callback(hObject, eventdata, handles)
global stim

data = str2num(get(hObject,'string'));
if(isempty(data))
    return;
end

% First get the time points 
lst=[];
for ii=1:length(data)
    lst(ii) = binaraysearchnearest(stim.t,data(ii));
end
s = sum(abs(stim.s(lst,:)),2);
lst2 = find(s>=1);

stim.what_changed = [stim.what_changed stimGUI_AddEditDelete(lst,lst2)];

% Update stim data in EasyNIRS gui 
if ~isempty(stim.what_changed)
    set(stim.handles.pushbuttonSave,'enable','on');
end
stimGUI_DisplayData();



%---------------------------------------------------------------------------
function stimMarksEdit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'string','');



%---------------------------------------------------------------------------
function stimGUI_DeleteFcn(hObject, eventdata, handles)
global stim
stim=[]; 
clear stim;



%--------------------------------------------------------------------------
function menuItemOpen_Callback(hObject, eventdata, handles)


%--------------------------------------------------------------------------
function menuItemExit_Callback(hObject, eventdata, handles)
global stim 

delete(stim.handles.stimGUI);
stimGUI_DeleteFcn([], eventdata, handles);



%--------------------------------------------------------------------------
function pushbuttonRenameCondition_Callback(hObject, eventdata, handles)
global stim
global COND_TBL_OFFSET;

nCond = length(stim.CondNamesAct);
if get(handles.radiobuttonConditionRun,'value')==1

    % List current run's conditions
    actionLst1 = [stim.CondNames {'Cancel'}];
    ch1 = menu('Which current run''s condition do you want to rename?',actionLst1);
    if(ch1==length(actionLst1)) || ch1==0
        return;
    end
    iCrun_orig_group = find(strncmp(stim.CondNames{ch1}, stim.CondNamesAct, ...
                            length(stim.CondNames{ch1})));

    % 
    % Don't include in the list of destination conditions (i.e., the 
    % conditions to which to rename) any of the current run's conditions 
    % Renaming to a current run's condition merely means moving all the 
    % stims from condition A to condition B in the current run.
    % This isn't technically renaming a run's condition but moving stims 
    % among conditions, something that can be done via the axes or the stim
    % edit box. Therefore we only offer destination conditions which 
    % don't exist in the run.
    %
    k=[]; jj=1;
    for ii=1:length(stim.CondNamesAct)
        if sum(strncmp(stim.CondNamesAct{ii}, stim.CondNames, ...
                       length(stim.CondNamesAct{ii})))==0
            k(jj)=ii;
            jj=jj+1;
        end
    end
      

    % Display group (destination) conditions to which run can be renamed
    actionLst2 = [stim.CondNamesAct(k) {'New Condition','Cancel'}];
    ch2 = menu('Name you want to assign to condition?',actionLst2);
    if(ch2==length(actionLst2)) || ch2==0
        return;
    end

    % Set the selected run condition to the new (from the run's perspective) 
    % condition name. 
    if ch2<length(actionLst2)-1
        
        iC_new = k(ch2);
        CondNameNew = stim.CondNamesAct(k(ch2));
        
    elseif ch2==length(actionLst2)-1
        
        CondNameNew = inputdlg('New Condition Name','New Condition Name');
        if isempty(CondNameNew) || isempty(CondNameNew{1})
            return;
        end
        iC_new = nCond+1;
        stim.CondNamesAct{iC_new} = CondNameNew{1};
        
    end
    
    stim.CondNames{ch1} = CondNameNew{1};
    stim.CondTbl{stim.iFile}{ch1+COND_TBL_OFFSET} = CondNameNew{1};
    
    % Modify CondRunIdx for iFile and the source and destination conditions
    stim.CondRunIdx(stim.iFile,iCrun_orig_group) = 0;   % src condition 
    stim.CondRunIdx(stim.iFile,iC_new) = ch1;           % dst condition 
    
    set(stim.handles.pushbuttonSave,'enable','on');
    stim.what_changed = [stim.what_changed {'cond','stim'}];
    stimGUI_DisplayData();
    
elseif get(handles.radiobuttonConditionGroup,'value')==1

    actionLst = [stim.CondNamesAct {'Cancel'}];
    ch = menu('Which group condition do you want to rename?',actionLst);
    if(ch==length(actionLst)) || ch==0
        return;
    end
    
    CondNameNew = stim.CondNamesAct{1};
    while sum(strcmp(CondNameNew, stim.CondNamesAct))>0
        CondNameNew = inputdlg('New Condition Name','New Condition Name');
        if isempty(CondNameNew) || isempty(CondNameNew{1})
            return;
        end
    end
    
    stim.CondNamesAct{ch} = CondNameNew{1};
    for iF=1:size(stim.CondTbl,1)
        iS = stim.CondRunIdx(iF,ch);
        if iS==0
            continue;
        end
        
        stim.CondTbl{iF}{iS+COND_TBL_OFFSET} = CondNameNew{1};
        if iF==stim.iFile
            stim.CondNames{iS} = CondNameNew{1};
        end
    end
    
    set(stim.handles.pushbuttonSave,'enable','on');
    stim.what_changed{end+1} = 'condgroup';
    stimGUI_DisplayData();
    
end
