function varargout = plotProbeGUI(varargin)
% PLOTPROBEGUI M-file for plotProbeGUI.fig
%      PLOTPROBEGUI, by itself, creates a new PLOTPROBEGUI or raises the existing
%      singleton*.
%
%      H = PLOTPROBEGUI returns the handle to a new PLOTPROBEGUI or the handle to
%      the existing singleton*.
%
%      PLOTPROBEGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PLOTPROBEGUI.M with the given input arguments.
%
%      PLOTPROBEGUI('Property','Value',...) creates a new PLOTPROBEGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before plotProbeGUI_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to plotProbeGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help plotProbeGUI

% Last Modified by GUIDE v2.5 15-Dec-2008 15:06:14

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @plotProbeGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @plotProbeGUI_OutputFcn, ...
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


% --- Executes just before plotProbeGUI is made visible.
function plotProbeGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to plotProbeGUI (see VARARGIN)
global hmr

% Choose default command line output for plotProbeGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% Process varargin
y = varargin{1};
t = varargin{2};
SD = varargin{3};
if length(varargin)>=4
    s = varargin{4};
else
    s = [];
end
if length(varargin)>=5
    yModel = varargin{5};
else
    yModel = [];
end


% calculate dimensions of SDG axes
distances=[];
lst=find(SD.MeasList(:,1)>0);
ml=SD.MeasList(lst,:);
lst=find(ml(:,4)==1);

for idx=1:length(lst)
    SrcPos=SD.SrcPos(ml(lst(idx),1),:);
    DetPos=SD.DetPos(ml(lst(idx),2),:);

    dist=norm(SrcPos-DetPos);
    distances=[distances; dist];
end

meanSD=mean(distances);

SD.xmin = min( [SD.SrcPos(:,1); SD.DetPos(:,1)] -1/2*meanSD);
SD.xmax = max( [SD.SrcPos(:,1); SD.DetPos(:,1)] +1/2*meanSD);
SD.ymin = min( [SD.SrcPos(:,2); SD.DetPos(:,2)] -1/2*meanSD);
SD.ymax = max( [SD.SrcPos(:,2); SD.DetPos(:,2)] +1/2*meanSD);

SD.nSrcs = size(SD.SrcPos,1);
SD.nDets = size(SD.DetPos,1);

if ~isfield(SD,'MeasListAct')
    SD.MeasListAct = ones(size(SD.MeasList,1),1);
end

% initialize other variables
hmr.plot = [];
hmr.plotLst = [];
hmr.plotLst_SrcMin = [];
hmr.plotLst_idxMin = [];
hmr.plotHbX(1) = get(handles.checkboxDisplayHbO,'value');
hmr.plotHbX(2) = get(handles.checkboxDisplayHbR,'value');

hmr.color = [0 0 1; 
                0 1 0; 
                1 0 0; 
                1 .5 0; 
                1 0 1; 
                0 1 1;
                0.5 0.5 1;
                0.5 1 0.5;
                1 0.5 0.5;
                1 0.5 1;
                0.5 1 1;
                0 0 0; 
                0.2 0.2 0.2; 
                0.4 0.4 0.4; 
                0.6 0.6 0.6;
                0.8 0.8 0.8];

% load global hmr variable
hmr.y = y;
hmr.t = t;
hmr.SD = SD;
hmr.yModel = yModel;
hmr.s = s;
hmr.axesSDG = handles.axesSDG;
hmr.displayAxes = handles.axesPlot;

hmr.plotStim = get(handles.checkboxDisplayStim,'value');

hmr.plotModel = get(handles.checkboxDisplayModel,'value');
hmr.displayModel = str2num(get(handles.textModel,'string'));
if ndims(y)==3
    hmr.nModels = size(yModel,4);
end


% display SDG
plotProbeGUI_plotAxesSDG( handles );




% --- Outputs from this function are returned to the command line.
function varargout = plotProbeGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbuttonZoomIn.
function pushbuttonZoomIn_Callback(hObject, eventdata, handles)
global hmr

axes(handles.axesPlot);
if eventdata==1
    xrange = xlim();
    xm = mean(xrange);
    xd = xrange(2)-xrange(1);
    xlim( xm + [-xd xd]/4 );
elseif eventdata==2
    xrange = xlim();
    xm = mean(xrange);
    xd = xrange(2)-xrange(1);
    xlim( max(min(xm + [-xd xd]*1.5,hmr.t(end)),0) );
elseif eventdata==3
    xlim( [0 hmr.t(end)] );
end


% --- Executes on button press in pushbuttonPanLeft.
function pushbuttonPanLeft_Callback(hObject, eventdata, handles)
global hmr

axes(handles.axesPlot)
if eventdata==1
    xrange = xlim();
    xm = mean(xrange);
    xd = xrange(2)-xrange(1);
    if xrange(1)-xd/5 >= 0
        xlim( max(min(xm + [-xd xd]/2 - xd/5,hmr.t(end)),0) );
    else
        xlim( [0 xd] );
    end
elseif eventdata==2
    xrange = xlim();
    xm = mean(xrange);
    xd = xrange(2)-xrange(1);
    if xrange(2)+xd/5 <= hmr.t(end)
        xlim( max(min(xm + [-xd xd]/2 + xd/5,hmr.t(end)),0) );
    else
        xlim( hmr.t(end) + [-xd 0] );
    end
end


% --- Executes on button press in checkboxDisplayHbO.
function checkboxDisplayHbO_Callback(hObject, eventdata, handles)
global hmr

hmr.plotHbX(1) = 1-hmr.plotHbX(1);
plotProbeGUI_DisplayData();

% --- Executes on button press in checkboxDisplayHbR.
function checkboxDisplayHbR_Callback(hObject, eventdata, handles)
global hmr

hmr.plotHbX(2) = 1-hmr.plotHbX(2);
plotProbeGUI_DisplayData()


% --- Executes on button press in checkboxDisplayModel.
function checkboxDisplayModel_Callback(hObject, eventdata, handles)
global hmr

hmr.plotModel = 1-hmr.plotModel;
plotProbeGUI_DisplayData();

% --- Executes on button press in checkboxDisplayStim.
function checkboxDisplayStim_Callback(hObject, eventdata, handles)
global hmr

hmr.plotStim = 1-hmr.plotStim;
plotProbeGUI_DisplayData()



% --- Executes on button press in pushbuttonModelDec.
function pushbuttonModel_Callback(hObject, eventdata, handles)
global hmr

if eventdata==1
    hmr.displayModel = max(hmr.displayModel - 1,1);
else
    hmr.displayModel = min(hmr.displayModel + 1,hmr.nModels);
end
set(handles.textModel,'string',num2str(hmr.displayModel));

plotProbeGUI_DisplayData()



