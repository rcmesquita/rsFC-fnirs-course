function varargout = EasyNIRS_ProcessOpt(varargin)
% EASYNIRS_PROCESSOPT M-file for EasyNIRS_ProcessOpt.fig
%      EASYNIRS_PROCESSOPT, by itself, creates a new EASYNIRS_PROCESSOPT or raises the existing
%      singleton*.
%
%      H = EASYNIRS_PROCESSOPT returns the handle to a new EASYNIRS_PROCESSOPT or the handle to
%      the existing singleton*.
%
%      EASYNIRS_PROCESSOPT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EASYNIRS_PROCESSOPT.M with the given input arguments.
%
%      EASYNIRS_PROCESSOPT('Property','Value',...) creates a new EASYNIRS_PROCESSOPT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before EasyNIRS_ProcessOpt_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to EasyNIRS_ProcessOpt_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help EasyNIRS_ProcessOpt

% Last Modified by GUIDE v2.5 05-Mar-2012 14:46:55

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @EasyNIRS_ProcessOpt_OpeningFcn, ...
                   'gui_OutputFcn',  @EasyNIRS_ProcessOpt_OutputFcn, ...
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




% ----------------------------------------------------------
function EasyNIRS_ProcessOpt_OpeningFcn(hObject, eventdata, handles, varargin)

% Choose default command line output for EasyNIRS_ProcessOpt
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes EasyNIRS_ProcessOpt wait for user response (see UIRESUME)
% uiwait(handles.EasyNIRS_ProcessOpt);

global hmr

procInput = hmr.procInput;

% Create the UI Controls
if isempty(procInput.procFunc)
    return;
end

if procInput.procFunc.nFunc==0
    menu('Processing stream is empty. Try creating or loading a new processing stream.','OK');
    return;
end

clf
procInput.procFunc = parseProcStreamHelp(procInput.procFunc,hmr);
set(hObject,'units','characters');
nfunc = length(procInput.procFunc.funcName);

% Pre-calculate figure height
funcHeight = 1;
for iFunc = 1:nfunc
    funcHeight(iFunc) = 1+procInput.procFunc.nFuncParam(iFunc)-1;
end
ystep = 1.8;
ysize = 1.5;
ysize_tot = sum(funcHeight)*ystep + nfunc*2 + 5;
xsize_fname = getFuncNameMaxStrLength(procInput.procFunc.funcNameUI,hObject);
xsize_pname = getParamNameMaxStrLength(procInput.procFunc.funcParam,hObject);
xpos_pname = xsize_fname+10;
xpos_pedit = xpos_pname+xsize_pname+10;
xpos_pbttn = xpos_pedit+15;
xsize_tot  = xpos_pbttn+15;

% Set figure size 
set(hObject,'units','characters');
pos = get(hObject,'position');
set(hObject,'position',[pos(1),pos(2)-pos(2)*.98,xsize_tot,ysize_tot]);
set(hObject,'units','pixels');
set(hObject,'color',[1 1 1]);

% Display functions and parameters in figure
ypos = ysize_tot-5;
for iFunc = 1:nfunc
    
    % Draw function name
    xsize = length(procInput.procFunc.funcNameUI{iFunc});
    xsize = xsize+(5-mod(xsize,5));
    h_fname = uicontrol(hObject,'style','text','units','characters','position',[2 ypos xsize ysize],...
                        'string',procInput.procFunc.funcNameUI{iFunc});
    set(h_fname,'backgroundcolor',[1 1 1], 'units','normalized');
    set(h_fname,'horizontalalignment','left');
    set(h_fname,'tooltipstring',procInput.procFunc.funcHelp{iFunc}.genDescr);
    
    % Draw pushbutton to see output results if requested in config file
    if procInput.procFunc.funcArgOut{iFunc}(1)=='#'
        h_bttn=uicontrol(hObject,'style','pushbutton','units','characters','position',[xpos_pbttn ypos 10 ysize],...
            'string','Results');
        eval( sprintf(' fcn = @(hObject,eventdata)EasyNIRS_ProcessOpt(''pushbutton_Callback'',hObject,%d,guidata(hObject));',iFunc) );
        set( h_bttn, 'Callback',fcn, 'units','normalized')
    end
    
    % Draw list of parameters
    for iParam = 1:procInput.procFunc.nFuncParam(iFunc)
        % Draw parameter names
        xsize = length(procInput.procFunc.funcParam{iFunc}{iParam});
        xsize = xsize+(5-mod(xsize,5))+5;
        h_pname=uicontrol(hObject,'style','text','units','characters','position',[xpos_pname ypos xsize ysize],...
                          'string',procInput.procFunc.funcParam{iFunc}{iParam});
        set(h_pname,'backgroundcolor',[1 1 1], 'units','normalized');
        set(h_pname,'horizontalalignment','left');
        set(h_pname,'tooltipstring',procInput.procFunc.funcHelp{iFunc}.paramDescr{iParam});

        % Draw parameter edit boxes
        h_pedit = uicontrol(hObject,'style','edit','units','characters','position',[xpos_pedit ypos 10 1.5]);
        set(h_pedit,'string',sprintf(procInput.procFunc.funcParamFormat{iFunc}{iParam}, ...
            procInput.procFunc.funcParamVal{iFunc}{iParam} ) );
        set(h_pedit,'backgroundcolor',[1 1 1]);
        eval( sprintf(' fcn = @(hObject,eventdata)EasyNIRS_ProcessOpt(''edit_Callback'',hObject,[%d %d],guidata(hObject));',iFunc,iParam) );
        set( h_pedit, 'Callback',fcn, 'units','normalized');

        ypos = ypos - ystep;
    end
    
    % If function has no parameters, skip a step in the y direction
    if procInput.procFunc.nFuncParam(iFunc)==0
        ypos = ypos - ystep;
    end
    
    
    % Draw divider between functions and function parameter lists
    if iFunc<nfunc
        h_linebttn=uicontrol(hObject,'style','pushbutton','units','characters','position',[0 ypos xsize_tot .3],...
                             'enable','off');
        set(h_linebttn, 'units','normalized');
        ypos = ypos - ystep;
    end
    
end

hmr.handles.proccessOpt=hObject;

procParam0 = [];
for iFunc=1:length(procInput.procFunc.funcName)
    for iParam=1:procInput.procFunc.nFuncParam(iFunc)
        eval( sprintf('procParam0.%s_%s = procInput.procFunc.funcParamVal{iFunc}{iParam};',...
                  procInput.procFunc.funcName{iFunc},procInput.procFunc.funcParam{iFunc}{iParam}) );
    end
end
procInput.procParam = procParam0;

hmr.procInput = procInput;

% Make sure the options GUI fits on screen
set(hObject,'units','normalized');
h = ysize_tot/100;
k = 1-h;
positionGUI(hObject, 0.10, 0.12, 0.38, k*h+h);


% ----------------------------------------------------------
function varargout = EasyNIRS_ProcessOpt_OutputFcn(hObject, eventdata, handles) 

% Get default command line output from handles structure
varargout{1} = handles.output;




% ----------------------------------------------------------
function edit_Callback(hObject, eventdata, handles) 
global hmr
global HRF_OFF_CONST
global HRF_GRP_CONST
global HRF_SESS_CONST
global HRF_RUN_CONST

procInput = hmr.procInput;

% funcName{nFunc}, funcArgOut{nFunc}, funcArgIn{nFunc}, nFuncParam(nFunc), funcParam{nFunc}{nParam},
% funcParamFormat{nFunc}{nParam}, funcParamVal{nFunc}{nParam}()

f=eventdata(1);
p=eventdata(2);

val = str2num( get(hObject,'string') ); % need to check if it is valid @@@

procInput.procFunc.funcParamVal{f}{p} = val;
eval( sprintf('procInput.procParam.%s_%s = val;',procInput.procFunc.funcName{f},procInput.procFunc.funcParam{f}{p}) );
set( hObject, 'string', sprintf(procInput.procFunc.funcParamFormat{f}{p}, val ) );

% Update procInput 
if data_diff(hmr.procInput.procParam,procInput.procParam)
    procInput.changeFlag=1;
end
hmr.procInput = procInput;
SaveDataToRun(hmr.filename,'procInput',procInput);
% set(hmr.handles.pushbuttonSave,'visible','on');

EasyNIRS_NIRSsignalProcessUpdate(hmr)


% ----------------------------------------------------------
function pushbutton_Callback(hObject, eventdata, handles) 
global hmr

procInput = hmr.procInput;

% parse output parameters
foos = procInput.procFunc.funcArgOut{eventdata};
% remove '[', ']', and ','
for ii=1:length(foos)
    if foos(ii)=='[' | foos(ii)==']' | foos(ii)==',' | foos(ii)=='#'
        foos(ii) = ' ';
    end
end

% get parameters for Output to hmr.procResult
sargin = '';
lst = strfind(foos,' ');
lst = [0 lst length(foos)+1];
flag = 1;
for ii=1:length(lst)-1
    foo2 = foos(lst(ii)+1:lst(ii+1)-1);
    idx = strfind(foo2,'foo');
    if (isempty(idx) || idx>1) && ~isempty(foo2)
        sargin = sprintf( '%s, hmr.procResult.%s',sargin,foo2);
%        sargin = sprintf( '%s, %s',sargin,foo2);
%        eval( sprintf('%s = hmr.procResult.%s;', foo2,foo2) );
    elseif idx==1
        sargin = sprintf( '%s, []',sargin);
    end
end

eval( sprintf( '%s_result( %s );', procInput.procFunc.funcName{eventdata}, sargin(2:end) ) );

hmr.procInput = procInput;




% -----------------------------------------------------------------
function maxnamelen = getFuncNameMaxStrLength(funcName,hFig)

maxnamelen=0;
for iFunc =1:length(funcName)
    if length(funcName{iFunc}) > maxnamelen
        maxnamelen = length(funcName{iFunc});
    end
end




% -----------------------------------------------------------------
function maxnamelen = getParamNameMaxStrLength(funcParam,hFig)

maxnamelen=0;
for iFunc=1:length(funcParam)
    for iParam=1:length(funcParam{iFunc})
        if length(funcParam{iFunc}{iParam})>maxnamelen
            maxnamelen = length(funcParam{iFunc}{iParam});
        end
    end
end




% --------------------------------------------------------------------
function menuExit_Callback(hObject, eventdata, handles)

hGui=get(get(hObject,'parent'),'parent');
close(hGui);


