%
% Load NIRS data from one file
%
function LoadCurrNIRSFile( filenm, handles )

global hmr;

hmr = loadRun(hmr,filenm);
SD  = hmr.SD;
t   = hmr.t;
s   = hmr.s;
aux = hmr.aux;

% set wavelength listbox
wlLst = [];
hmr.SD.Lambda = sort(hmr.SD.Lambda);
for ii=1:length(hmr.SD.Lambda)
    wlLst{ii} = num2str(hmr.SD.Lambda(ii));
end

% set Aux listbox
auxLst = [];
for ii=1:size(aux,2)
    if isfield(SD,'auxChannels')
        if length(SD.auxChannels)>=ii
            auxLst{end+1} = SD.auxChannels{ii};
        else
            auxLst{end+1} = sprintf('Aux %d',ii);
        end
    else
        auxLst{end+1} = sprintf('Aux %d',ii);
    end
end
hmr.fileChanged = 0;
setGuiForCurrFile(handles,wlLst,auxLst); 

if isfield(hmr,'procResult')
    if isfield(hmr.procResult,'tIncChAuto')
        set(handles.checkboxShowMotionByChannel,'enable','on')
    else
        set(handles.checkboxShowMotionByChannel,'enable','off')
    end
end



% --------------------------------------------------------------------
function setGuiForCurrFile(handles,wlLst,auxLst)
global hmr

h = findobj('Tag','stimGUI');
if ~isempty(h)
    stimGUI();
end
h = findobj('Tag','ProcessOpt');
if ~isempty(h)
    ProcessOpt();
end
set(handles.listboxPlotWavelength,'string',wlLst)
set(handles.listboxPlotWavelength,'value',1);
EasyNIRS_enableAuxGuiParams(handles,'on',auxLst,1);
EasyNIRS_CheckPlotButtons( handles );
popupmenuCondition_SetStrings(handles, hmr.group.conditions.CondNamesAct, hmr.s, hmr.stim.CondNames);

% set other handle properties
EasyNIRS_NIRSsignalProcessEnable('on');



% --------------------------------------------------------------------
function s=addCond(s)
global hmr

% If there are fewer columns in hmr.s than there are named 
% conditions add in the missing columns of zeros to hmr.s
ncol1 = size(s,2);
ncol2 = length(hmr.stim.CondNames);
ndiff = ncol1-ncol2;
if(ndiff<0)
    s = [s zeros(size(s,1),abs(ndiff))];
end
