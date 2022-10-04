function varargout = procStreamGUI(varargin)
% PROCSTREAMGUI M-file for procStreamGUI.fig
%      PROCSTREAMGUI, by itself, creates a new PROCSTREAMGUI or raises the existing
%      singleton*.
%
%      H = PROCSTREAMGUI returns the handle to a new PROCSTREAMGUI or the handle to
%      the existing singleton*.
%
%      PROCSTREAMGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PROCSTREAMGUI.M with the given input arguments.
%
%      PROCSTREAMGUI('Property','Value',...) creates a new PROCSTREAMGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before procStreamGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to procStreamGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help procStreamGUI

% Last Modified by GUIDE v2.5 08-Aug-2011 16:19:52

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @procStreamGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @procStreamGUI_OutputFcn, ...
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




% -------------------------------------------------------------
function procStreamGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to procStreamGUI (see VARARGIN)

% Choose default command line output for procStreamGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

global procStreamIdx
procStreamIdx = [];

funcStr=procStreamReg();
foos='';
for ii=1:length(funcStr)
    foos = sprintf('%s%s\n',foos,funcStr{ii});
end
procInput = parseProcessOpt( foos );

for iFunc = 1:procInput.procFunc.nFunc
    % parse input parameters
    p = [];
    sargin = '';
    for iP = 1:procInput.procFunc.nFuncParam(iFunc)
        if ~procInput.procFunc.nFuncParamVar(iFunc)
            p{iP} = procInput.procFunc.funcParamVal{iFunc}{iP};
        else
            p{iP}.name = procInput.procFunc.funcParam{iFunc}{iP};
            p{iP}.val = procInput.procFunc.funcParamVal{iFunc}{iP};
        end
        if length(procInput.procFunc.funcArgIn{iFunc})==1 & iP==1
            sargin = sprintf('%sp{%d}',sargin,iP);
        else
            sargin = sprintf('%s,p{%d}',sargin,iP);
        end
    end
    
    % set up output format
    sargout = procInput.procFunc.funcArgOut{iFunc};
    for ii=1:length(procInput.procFunc.funcArgOut{iFunc})
        if sargout(ii)=='#'
            sargout(ii) = ' ';
        end
    end

    % call function
    fcall{iFunc} = sprintf( '%s      = %s%s%s);', sargout, ...
        procInput.procFunc.funcName{iFunc}, ...
        procInput.procFunc.funcArgIn{iFunc}, sargin );
    fcallOut{iFunc} = sprintf( '%s', sargout);
    fcall{iFunc} = sprintf( '%s',  ...
        procInput.procFunc.funcName{iFunc} );
    fcallIn{iFunc} = sprintf( '%s%s)',  ...
        procInput.procFunc.funcArgIn{iFunc}, sargin );
end
set(handles.listboxFunctions,'string',fcall)
set(handles.listboxFuncArgIn,'string',fcallIn)
set(handles.listboxFuncArgOut,'string',fcallOut)

    
    

% -------------------------------------------------------------
function varargout = procStreamGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



% -------------------------------------------------------------
function listboxFunctions_Callback(hObject, eventdata, handles)
ii = get(hObject,'value');
set(handles.listboxFuncArgIn,'value',ii);
set(handles.listboxFuncArgOut,'value',ii);

foos = procStreamHelpLookupByIndex(ii);
set(handles.textHelp,'string',foos);



% -------------------------------------------------------------
function listboxFuncArgOut_Callback(hObject, eventdata, handles)
ii = get(hObject,'value');
set(handles.listboxFuncArgIn,'value',ii);
set(handles.listboxFunctions,'value',ii);

foos = procStreamHelpLookupByIndex(ii);
set(handles.textHelp,'string',foos);




% -------------------------------------------------------------
function listboxFuncArgIn_Callback(hObject, eventdata, handles)
ii = get(hObject,'value');
set(handles.listboxFunctions,'value',ii);
set(handles.listboxFuncArgOut,'value',ii);

foos = procStreamHelpLookupByIndex(ii);
set(handles.textHelp,'string',foos);



% -------------------------------------------------------------
function pushbuttonAddFunc_Callback(hObject, eventdata, handles)
global procStreamIdx

iFunc = get(handles.listboxFunctions,'value');
iPS = get(handles.listboxPSFunc,'value');

n = length(procStreamIdx);
if n>0
    procStreamIdxTmp(1:iPS) = procStreamIdx(1:iPS);
    procStreamIdxTmp(iPS+1) = iFunc;
    procStreamIdxTmp((iPS+2):(n+1)) = procStreamIdx((iPS+1):n);
    iPS2 = iPS+1;
else
    procStreamIdxTmp(1) = iFunc;
    iPS2 = 1;
end
procStreamIdx = procStreamIdxTmp;

updateProcStreamList(handles,iPS2);




% -------------------------------------------------------------
function pushbuttonDeleteFunc_Callback(hObject, eventdata, handles)
global procStreamIdx

n = length(procStreamIdx);
if n<1
    return
end

iPS = get(handles.listboxPSFunc,'value');

if n>1
    procStreamIdxTmp = procStreamIdx;
    procStreamIdxTmp(iPS) = [];
    iPS2 = max(iPS-1,1);
else
    procStreamIdxTmp = [];
    iPS2 = 1;
end
procStreamIdx = procStreamIdxTmp;

updateProcStreamList(handles,iPS2);




% -------------------------------------------------------------
function pushbuttonMoveUp_Callback(hObject, eventdata, handles)
global procStreamIdx

iPS = get(handles.listboxPSFunc,'value');

if iPS == 1
    return
end

FArgOut = get(handles.listboxFuncArgOut,'string');
FArgIn = get(handles.listboxFuncArgIn,'string');
FFunc = get(handles.listboxFunctions,'string');

procStreamIdxTmp = procStreamIdx;
procStreamIdxTmp([iPS-1 iPS]) = procStreamIdx([iPS iPS-1]);
iPS2 = max(iPS-1,1);
procStreamIdx = procStreamIdxTmp;

updateProcStreamList(handles,iPS2);


% -------------------------------------------------------------
function pushbuttonMoveDown_Callback(hObject, eventdata, handles)
global procStreamIdx

iPS = get(handles.listboxPSFunc,'value');
n = length(procStreamIdx);

if iPS == n
    return
end

procStreamIdxTmp = procStreamIdx;
procStreamIdxTmp([iPS iPS+1]) = procStreamIdx([iPS+1 iPS]);
iPS2 = iPS+1;
procStreamIdx = procStreamIdxTmp;

updateProcStreamList(handles,iPS2);



% -------------------------------------------------------------
function updateProcStreamList(handles,idx)
global procStreamIdx

n = length(procStreamIdx);
FArgOut = get(handles.listboxFuncArgOut,'string');
FArgIn = get(handles.listboxFuncArgIn,'string');
FFunc = get(handles.listboxFunctions,'string');


foos = [];
for ii = 1:n
    foos{ii} = FArgOut{procStreamIdx(ii)};
end
set(handles.listboxPSArgOut,'string',foos)
set(handles.listboxPSArgOut,'value',idx)

foos = [];
for ii = 1:n
    foos{ii} = FArgIn{procStreamIdx(ii)};
end
set(handles.listboxPSArgIn,'string',foos)
set(handles.listboxPSArgIn,'value',idx)

foos = [];
for ii = 1:n
    foos{ii} = FFunc{procStreamIdx(ii)};
end
set(handles.listboxPSFunc,'string',foos)
set(handles.listboxPSFunc,'value',idx)




% -------------------------------------------------------------
function listboxPSFunc_Callback(hObject, eventdata, handles)
ii = get(hObject,'value');
set(handles.listboxPSArgIn,'value',ii);
set(handles.listboxPSArgOut,'value',ii);

FFunc = get(handles.listboxPSFunc,'string');
foos = procStreamHelpLookupByName(FFunc{ii});
set(handles.textHelp,'string',foos);




% -------------------------------------------------------------
function listboxPSArgOut_Callback(hObject, eventdata, handles)
ii = get(hObject,'value');
set(handles.listboxPSArgIn,'value',ii);
set(handles.listboxPSFunc,'value',ii);

foos = procStreamHelpLookupByIndex(ii);
set(handles.textHelp,'string',foos);



% -------------------------------------------------------------
function listboxPSArgIn_Callback(hObject, eventdata, handles)
ii = get(hObject,'value');
set(handles.listboxPSFunc,'value',ii);
set(handles.listboxPSArgOut,'value',ii);

FFunc = get(handles.listboxPSFunc,'string');
foos = procStreamHelpLookupByName(FFunc{ii});
set(handles.textHelp,'string',foos);



% -------------------------------------------------------------
function pushbuttonSave_Callback(hObject, eventdata, handles)
global procStreamIdx
global hmr

% Build func database of registered functions
funcStr=procStreamReg();
foos='';
for ii=1:length(funcStr)
    foos = sprintf('%s%s\n',foos,funcStr{ii});
end
procInputReg = parseProcessOpt( foos, hmr );
procFuncReg = procInputReg.procFunc;
procFunc.funcName =        procFuncReg.funcName(procStreamIdx);
procFunc.funcNameUI =      procFuncReg.funcName(procStreamIdx);
procFunc.funcArgOut =      procFuncReg.funcArgOut(procStreamIdx);
procFunc.funcArgIn =       procFuncReg.funcArgIn(procStreamIdx);
procFunc.nFuncParam =      procFuncReg.nFuncParam(procStreamIdx);
procFunc.nFuncParamVar =   procFuncReg.nFuncParamVar(procStreamIdx);
procFunc.funcParam =       procFuncReg.funcParam(procStreamIdx);
procFunc.funcParamFormat = procFuncReg.funcParamFormat(procStreamIdx);
procFunc.funcParamVal =    procFuncReg.funcParamVal(procStreamIdx);
procFunc.nFunc =           length(procFunc.funcName);

ch = menu('Save to current processing stream or config file?','Current processing stream','Config file');
if ch==1
    procParam=[];
    for iFunc = 1:procFunc.nFunc
        for iParam=1:length(procFunc.funcParam{iFunc})
                eval( sprintf('procParam(1).%s_%s = procFunc.funcParamVal{iFunc}{iParam};',...
                              procFunc.funcName{iFunc}, procFunc.funcParam{iFunc}{iParam}) );
        end
    end
    procInput.procFunc = procFunc;
    procInput.procParam = procParam;
    EasyNIRS_ProcessOpt_Init(procInput);
    EasyNIRS_CopyOptions();
else
    [filenm,pathnm] = uiputfile( '*.cfg','Save Config File');
    if filenm==0
        return
    end
    procStreamSave([pathnm filenm],procFunc);
end





% -------------------------------------------------------------
function pushbuttonHelp_Callback(hObject, eventdata, handles)
iFunc = get(handles.listboxFunctions,'value');
FFunc = get(handles.listboxFunctions,'string');

foos = procStreamHelpLookupByIndex(iFunc);
set(handles.textHelp,'string',foos);



% -------------------------------------------------------------
function pushbuttonLoad_Callback(hObject, eventdata, handles)
global procStreamIdx

ch = menu('Load current processing stream or config file?','Current processing stream','Config file','Cancel');
if ch==3
    return
end
if ch==1
    global hmr
    procInput = hmr.procInput;
else
    [filename,pathname] = uigetfile( '*.cfg', 'Process Options Config File');
    if filename == 0
        return;
    end

    % load cfg file
    fid = fopen([pathname filename],'r');
    [procInput err] = parseProcessOpt(fid);
    fclose(fid);
end

% Search for procFun functions in procStreamReg
[err procStreamIdx procInputReg] = EasyNIRS_ProcessOpt_ErrorCheck(procInput.procFunc,{});
if ~all(~err)
    i=find(err==1);
    str1 = 'Error in saved procInput functions\n\n';
    for j=1:length(i)
        str2 = sprintf('%s%s',procInput.procFunc.funcName{i(j)},'\n');
        str1 = strcat(str1,str2);
    end
    str1 = strcat(str1,'\n');
    str1 = strcat(str1,'Will remove or replace these functions with with updated versions...');
    ch = menu( sprintf(str1), 'OK');
    procInput = fixProcStreamErr(err, procInput, procStreamIdx, procInputReg);
end
updateProcStreamList(handles,1);




% -------------------------------------------------
function funcHelp = procStreamHelpLookupByIndex(iFunc);

funcHelp = '';

procStreamRegStr.call = procStreamReg();
procStreamRegStr.help = procStreamRegHelp();

procInputReg     = parseProcessOpt(procStreamRegStr.call{iFunc});
procFunc.funcName{1}        = procInputReg.procFunc.funcName{1};
procFunc.funcArgOut{1}      = procInputReg.procFunc.funcArgOut{1};
procFunc.funcArgIn{1}       = procInputReg.procFunc.funcArgIn{1};
procFunc.nFuncParam(1)      = procInputReg.procFunc.nFuncParam(1);
procFunc.nFuncParamVar(1)   = procInputReg.procFunc.nFuncParamVar(1);
procFunc.funcParam{1}       = procInputReg.procFunc.funcParam{1};
procFunc.funcParamFormat{1} = procInputReg.procFunc.funcParamFormat{1};
procFunc.funcParamVal{1}    = procInputReg.procFunc.funcParamVal{1};
procFunc.funcHelpStrArr{1}  = procStreamRegStr.help{iFunc};
procFunc.nFunc = 1;

procFunc.funcHelp{1} = parseFuncHelp(procFunc,1);

funcHelp = sprintf('%s%s\n',funcHelp, procFunc.funcHelp{1}.usage);
funcHelp = sprintf('%s%s\n',funcHelp, procFunc.funcHelp{1}.funcNameUI);
funcHelp = sprintf('%s%s\n',funcHelp, 'DESCRIPTION:');
funcHelp = sprintf('%s%s\n',funcHelp, procFunc.funcHelp{1}.genDescr);
funcHelp = sprintf('%s%s\n',funcHelp, 'INPUT:');
funcHelp = sprintf('%s%s',funcHelp, procFunc.funcHelp{1}.argInDescr);
for iParam=1:length(procFunc.funcHelp{1}.paramDescr)
    funcHelp = sprintf('%s%s',funcHelp, procFunc.funcHelp{1}.paramDescr{iParam});
end
funcHelp = sprintf('%s\n',funcHelp);
funcHelp = sprintf('%s%s\n',funcHelp, 'OUPUT:');
funcHelp = sprintf('%s%s\n',funcHelp, procFunc.funcHelp{1}.argOutDescr);





% -------------------------------------------------
function funcHelp = procStreamHelpLookupByName(funcName);

funcHelp = '';

procStreamRegStr.call = procStreamReg();
procStreamRegStr.help = procStreamRegHelp();
match=0;
for ii=1:length(procStreamRegStr.call)
    procInputReg = parseProcessOpt(procStreamRegStr.call{ii});
    procFuncReg.funcName{ii}        = procInputReg.procFunc.funcName{1};
    procFuncReg.funcArgOut{ii}      = procInputReg.procFunc.funcArgOut{1};
    procFuncReg.funcArgIn{ii}       = procInputReg.procFunc.funcArgIn{1};
    procFuncReg.nFuncParam(ii)      = procInputReg.procFunc.nFuncParam(1);
    procFuncReg.nFuncParamVar(ii)   = procInputReg.procFunc.nFuncParamVar(1);
    procFuncReg.funcParam{ii}       = procInputReg.procFunc.funcParam{1};
    procFuncReg.funcParamFormat{ii} = procInputReg.procFunc.funcParamFormat{1};
    procFuncReg.funcParamVal{ii}    = procInputReg.procFunc.funcParamVal{1};
    procFuncReg.funcHelpStrArr{ii}  = procStreamRegStr.help{ii};
    
    if strcmp(funcName, procFuncReg.funcName{ii})
        match=1;
        break;
    end
end

if ~match
    return;
end

funcHelpS = parseFuncHelp(procFuncReg,ii);

funcHelp = sprintf('%s%s\n',funcHelp, funcHelpS.usage);
funcHelp = sprintf('%s%s\n',funcHelp, funcHelpS.funcNameUI);
funcHelp = sprintf('%s%s\n',funcHelp, 'DESCRIPTION:');
funcHelp = sprintf('%s%s\n',funcHelp, funcHelpS.genDescr);
funcHelp = sprintf('%s%s\n',funcHelp, 'INPUT:');
funcHelp = sprintf('%s%s',funcHelp, funcHelpS.argInDescr);
for iParam=1:length(funcHelpS.paramDescr)
    funcHelp = sprintf('%s%s',funcHelp, funcHelpS.paramDescr{iParam});
end
funcHelp = sprintf('%s\n',funcHelp);
funcHelp = sprintf('%s%s\n',funcHelp, 'OUPUT:');
funcHelp = sprintf('%s%s\n',funcHelp, funcHelpS.argOutDescr);
