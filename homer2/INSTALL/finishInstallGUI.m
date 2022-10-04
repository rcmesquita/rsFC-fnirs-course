function varargout = finishInstallGUI(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @finishInstallGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @finishInstallGUI_OutputFcn, ...
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



% ---------------------------------------------------------------------------
function msgFailure()
global stats

handles = stats.handles;

stats.err = stats.err+1;

msgFail{1}    = sprintf('Homer2 failed to install properly. Error code %d', stats.err);
msgFail{2}    = 'Contact jdubb@nmr.mgh.harvard.edu for help with installtion.';

hGui         = handles.this;
hMsgFinished = handles.msgFinished;
hMsgMoreInfo = handles.msgMoreInfo;

set(hGui, 'name','Installation Error:');
set(hMsgFinished,'string', msgFail{1});
set(hMsgMoreInfo,'string', msgFail{2});

fd = fopen([stats.dirnameApp, '.finished'], 'w');
fprintf(fd, '%d', stats.err);
fclose(fd);



% ---------------------------------------------------------------------------
function msgSuccess()
global stats

handles = stats.handles;

msgSuccess{1} = 'Installation Completed Successfully!';
if ispc()
    msgSuccess{2} = 'To run: Click on Homer2_UI or AtlasViewerGUI icon on your Desktop to launch one of these applications';
elseif islinux()
    msgSuccess{2} = 'To run: Click on Homer2_UI.sh or AtlasViewerGUI.sh icon on your Desktop to launch one of these applications';
elseif ismac()
    msgSuccess{2} = 'To run: Click on Homer2_UI.command or AtlasViewerGUI.command icon on your Desktop to launch one of these applications';
end

hGui         = handles.this;
hMsgFinished = handles.msgFinished;
hMsgMoreInfo = handles.msgMoreInfo;

set(handles.this, 'name','SUCCESS:');
set(handles.msgFinished,'string', msgSuccess{1}, 'fontsize',14);
set(handles.msgMoreInfo,'string', msgSuccess{2}, 'fontsize',14);

fd = fopen([stats.dirnameApp, '.finished'], 'w');
fprintf(fd, '%d', stats.err);
fclose(fd);


% ---------------------------------------------------------------------------
function finishInstallGUI_OpeningFcn(hObject, eventdata, handles, varargin)
global stats

handles.output = hObject;
guidata(hObject, handles);

stats.err = 0;
stats.handles.this = hObject;
stats.handles.msgFinished = handles.textFinished;
stats.handles.msgMoreInfo = handles.textMoreInfo;
stats.dirnameApp = getAppDir();
stats.pushbuttonOKPress = false;

if ispc()
    [~, outputStr] = system('echo %userprofile%');
    k = find(outputStr~=10 & outputStr~=13);
    dirnameUser           = outputStr(k);
    dirnameDesktop        = [dirnameUser, '/desktop'];
    AtlasViewerGUIExe         = [stats.dirnameApp, '/AtlasViewerGUI.exe'];
    AtlasViewerGUIExeLnk      = [dirnameDesktop, '/AtlasViewerGUI.exe.lnk'];
    AtlasViewerGUIExeLnkCmd   = sprintf('"%s" silent userargs', AtlasViewerGUIExeLnk);
    AtlasViewerGUIExeCmd      = sprintf('"%s"AtlasViewerGUI.exe silent userargs', stats.dirnameApp);
end

% Error checks
if stats.dirnameApp==0
    msgFailure();
    return;
end

if isempty(stats.dirnameApp)
    msgFailure();
    return;
end

files = dir([stats.dirnameApp, '/*']);
if isempty(files)
    msgFailure();
    return;
end

if ispc()
    if ~exist(AtlasViewerGUIExe, 'file')
        msgFailure();
        return;
    end
    
    if ~exist(AtlasViewerGUIExeLnk, 'file')
        msgFailure();
        return;
    end
end

% This part needs support for silent ode in AtlasViewerGUI and Homer2_UI
% We comment it out for now.
if 0 
    % Try running AtlasViewerGUI exe from application folder
    if system(AtlasViewerGUIExeCmd) > 0
        msgFailure();
        return;
    end
    
    % Try running AtlasViewerGUI.exe shortcut on desktop
    if system(AtlasViewerGUIExeLnkCmd) > 0
        msgFailure();
        return;
    end
end

msgSuccess();



% ---------------------------------------------------------------------------
function varargout = finishInstallGUI_OutputFcn(hObject, eventdata, handles) 
global stats

varargout{1} = stats.err;


% ---------------------------------------------------------------------------
function pushbuttonOK_Callback(hObject, eventdata, handles)
global stats

stats.pushbuttonOKPress = true;

delete(stats.handles.this);
