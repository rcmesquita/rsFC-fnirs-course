function varargout = Edit_Probe(varargin)
% EDIT_PROBE MATLAB code for Edit_Probe.fig
%      EDIT_PROBE, by itself, creates a new EDIT_PROBE or raises the existing
%      singleton*.
%
%      H = EDIT_PROBE returns the handle to a new EDIT_PROBE or the handle to
%      the existing singleton*.
%
%      EDIT_PROBE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EDIT_PROBE.M with the given input arguments.
%
%      EDIT_PROBE('Property','Value',...) creates a new EDIT_PROBE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Edit_Probe_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Edit_Probe_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Edit_Probe

% Last Modified by GUIDE v2.5 03-Jul-2017 17:32:58

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @Edit_Probe_OpeningFcn, ...
    'gui_OutputFcn',  @Edit_Probe_OutputFcn, ...
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


% --- Executes just before Edit_Probe is made visible.
function Edit_Probe_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Edit_Probe (see VARARGIN)
global EditProbe;
EditProbe=[];
% Choose default command line output for Edit_Probe
set(handles.figure1,'Name','Manual Correction','NumberTitle','off')
handles.output = hObject;

handles.headsurf=varargin{1,1};
handles.cortexsurf=varargin{1,2};
handles.refpts=varargin{1,3};
handles.probe=varargin{1,4};

% %%%% read cortex surface mesh
GM_nodes=handles.cortexsurf.vertices;
GM_faces=handles.cortexsurf.faces;

% %%%% read head surface mesh
nodes=handles.headsurf.vertices;
faces=handles.headsurf.faces;
normal=handles.headsurf.normals;

% save Colin_HeadModel.mat nodes faces;
if size(handles.refpts,1)<=1
    set(handles.Show_EEG_Electrodes,'Enable','off');
    set(handles.Show_EEG_Labels,'Enable','off');
end

% % %%%% load optode position
Num_Scr=handles.probe.nsrc;
Num_Det=handles.probe.ndet;
Num_Chn=size(handles.probe.mlmp,1);

if Num_Chn>0 %%% check if channels positions are given
    Chspos=[];
    for i=1:Num_Scr
        Chspos= [Chspos; get(handles.probe.handles.hOptodes(i,1),'Position') 1];
    end
    for i=1:Num_Det
        Chspos= [Chspos; get(handles.probe.handles.hOptodes(Num_Scr+i,1),'Position') 2];
    end
    Chspos= [Chspos; handles.probe.mlmp 3*ones(Num_Chn,1)];
else
    Chspos=[];
    for i=1:Num_Scr
        Chspos= [Chspos; get(handles.probe.handles.hOptodes(i,1),'Position') 1];
    end
    for i=1:Num_Det
        Chspos= [Chspos; get(handles.probe.handles.hOptodes(Num_Scr+i,1),'Position') 2];
    end
end

%%%%% change orientation to ALS
Orien_Curr=handles.probe.orientation;
XYZnew=Change_Orentation(Orien_Curr);
handles.Orientation=Orien_Curr;
handles.Orientation_Vector=XYZnew;

%%%% change orientation
L=find(XYZnew<0);
if ~isempty(L)
    nodes(:,L)=-1*nodes(:,L);
    GM_nodes(:,L)=-1*GM_nodes(:,L);
    Chspos(:,L)=-1*Chspos(:,L);
    normal(:,L)=-1*normal(:,L);
end
nodes=nodes(:,abs(XYZnew));
GM_nodes=GM_nodes(:,abs(XYZnew));
Chspos=Chspos(:,[abs(XYZnew) 4]);
normal=normal(:,abs(XYZnew));

%%%% plot head model and optodes
Edit_Optode_Positions

EditProbe.handles=handles;
%%%% show arrows/ NIRS channels
h = findobj(gcf,'Type','text','fontsize',12,'color','k','FontAngle','italic'); % find labels
if get(handles.Show_NIRS_Channels,'value')
    set(h,'Visible','on')
else
    set(h,'Visible','off')
end


% UIWAIT makes Edit_Probe wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Edit_Probe_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
global EditProbe;
Num_Scr=EditProbe.handles.probe.nsrc;
Num_Det=EditProbe.handles.probe.ndet;
Num_Chn=size(EditProbe.handles.probe.mlmp,1);
XYZold=EditProbe.handles.Orientation_Vector;

XYZnew=[];
for i=1:3
    L=find(abs(XYZold)==i);
    if XYZold(L(1))<0
        XYZnew=[XYZnew -1*L(1)];
    else
        XYZnew=[XYZnew L(1)];
    end
end
L=find(XYZnew<0);

Optodes_update=[];
%%% sort sources
for i=1:Num_Scr
    hj = findobj(EditProbe.handles.hj, 'AmbientStrength',.2,'DiffuseStrength',.8,'SpecularStrength',.5,'Tag',['S' num2str(i)]); % find optodes and their tags
    H=get(hj);
    Position=H.UserData;
    if ~isempty(L)
        Position(L)=-1*Position(L);
    end
    Position=Position(abs(XYZnew));
    Optodes_update=[Optodes_update; Position];
end

%%% sort Detectors
for i=1:Num_Det
    hj = findobj(EditProbe.handles.hj, 'AmbientStrength',.2,'DiffuseStrength',.8,'SpecularStrength',.5,'Tag',['D' num2str(i)]); % find optodes and their tags
    H=get(hj);
    Position=H.UserData;
    if ~isempty(L)
        Position(L)=-1*Position(L);
    end
    Position=Position(abs(XYZnew));
    Optodes_update=[Optodes_update; Position];
end

%%% sort Channels
Channels=[];
for i=1:Num_Chn
    hj = findobj(EditProbe.handles.hj, 'AmbientStrength',.2,'DiffuseStrength',.8,'SpecularStrength',.5,'Tag',['Ch' num2str(i)]); % find optodes and their tags
    H=get(hj);
    Position=H.UserData;
    if ~isempty(L)
        Position(L)=-1*Position(L);
    end
    Position=Position(abs(XYZnew));
    Channels=[Channels; Position];
end

varargout{1} = Optodes_update;
varargout{2} = Channels;
% The figure can be deleted now
%cla
% delete(handles.figure1);
h=get(hObject);
for i=1:length(h.Children)
    h1=get(h.Children(i));
    if strcmp(h1.Type,'axes')
       h1.Children=[]; 
    end
end
delete(hObject);


% --- Executes on button press in Show_Optode_Labels.
function Show_Optode_Labels_Callback(hObject, eventdata, handles)
% hObject    handle to Show_Optode_Labels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
h = findobj(gcf,'Type','text','fontsize',12,'color','k','FontAngle','normal'); % find labels
if get(handles.Show_Optode_Labels,'value')
    set(h,'Visible','on')
else
    set(h,'Visible','off')
end

% --- Executes on button press in Show_Optode_Labels.
function Show_NIRS_Channel_Labels_Callback(hObject, eventdata, handles)
% hObject    handle to Show_Optode_Labels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
h = findobj(gcf,'Type','text','fontsize',12,'color','k','FontAngle','italic'); % find labels
h1 = findobj(gcf,'Facecolor','c'); % find channels
if get(handles.Show_NIRS_Channels,'value')
    set(h,'Visible','on')
    set(h1,'Visible','on')
else
    set(h,'Visible','off')
    set(h1,'Visible','off')
end


% --- Executes on button press in Show_EEG_Electrodes.
function Show_EEG_Electrodes_Callback(hObject, eventdata, handles)
% hObject    handle to Show_EEG_Electrodes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Show_EEG_Electrodes
h = findobj(gcf,'Facecolor','g'); % find its label
if get(handles.Show_EEG_Electrodes,'value')
    set(h,'Visible','on')
else
    set(h,'Visible','off')
end


% --- Executes on button press in Show_EEG_Labels.
function Show_EEG_Labels_Callback(hObject, eventdata, handles)
% hObject    handle to Show_EEG_Labels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Show_EEG_Labels
h = findobj(gcf,'Type','text','fontsize',8,'color','k'); % find its label
if get(handles.Show_EEG_Labels,'value')
    set(h,'Visible','on')
else
    set(h,'Visible','off')
end
h = findobj(gcf,'Type','text','fontsize',12,'color','k','FontAngle','italic'); % find labels
if get(handles.Show_NIRS_Channels,'value')
    set(h,'Visible','on')
else
    set(h,'Visible','off')
end


% --- Executes on button press in Show_Arrows.
function Show_Arrows_Callback(hObject, eventdata, handles)
% hObject    handle to Show_Arrows (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Show_Arrows
h = findobj(gcf,'Tag','Arrow'); % find its label
if get(handles.Show_Arrows,'value')
    set(h,'Visible','on')
else
    set(h,'Visible','off')
end


% --- Executes on button press in Show_Cortex.
function Show_Cortex_Callback(hObject, eventdata, handles)
% hObject    handle to Show_Cortex (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hgm = findobj(gcf,'Tag','gm'); % find its label
hsk = findobj(gcf,'Tag','nd'); % find its label
if get(handles.Show_Cortex,'value')
    set(hgm,'FaceAlpha',0.5)
    set(hsk,'FaceAlpha',0.7)
else
    set(hgm,'FaceAlpha',0)
    set(hsk,'FaceAlpha',1)
end

% Hint: get(hObject,'Value') returns toggle state of Show_Cortex


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
if isequal(get(hObject, 'waitstatus'), 'waiting')
    % The GUI is still in UIWAIT, us UIRESUME
    uiresume(hObject);
else
    % The GUI is no longer waiting, just close it
%    cla
    delete(hObject);
end

% --- Executes when user attempts to close figure1.
function Close_Callback(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
% The GUI is still in UIWAIT, us UIRESUME
% uiresume(hObject);
% % The GUI is no longer waiting, just close it
% delete(hObject);
handles.output = get(hObject,'String');

% Update handles structure
guidata(hObject, handles);

% Use UIRESUME instead of delete because the OutputFcn needs
% to get the updated handles structure.
uiresume(handles.figure1);
