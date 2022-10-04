function EasyNIRS_AxesSDG_buttondown(hObject, eventdata, handles)

global hmr

if isempty(hmr.SD) 
    return;
end

pos = get(hmr.handles.axesSDG,'CurrentPoint');

h = hObject;
while ~strcmpi(get(h,'Type'),'figure')
    h = get(h,'parent');
end

mouseevent = get(h,'selectiontype');

SD = hmr.SD;

%find the closest optode
rmin = ( (pos(1,1)-SD.SrcPos(1,1))^2 + (pos(1,2)-SD.SrcPos(1,2))^2 )^0.5 ;
idxMin = 1;
SrcMin = 1;
for idx=1:SD.nSrcs
    ropt = ( (pos(1,1)-SD.SrcPos(idx,1))^2 + (pos(1,2)-SD.SrcPos(idx,2))^2 )^0.5 ;
    if ropt<rmin
        idxMin = idx;
        rmin = ropt;
    end
end
for idx=1:SD.nDets
    ropt = ( (pos(1,1)-SD.DetPos(idx,1))^2 + (pos(1,2)-SD.DetPos(idx,2))^2 )^0.5 ;
    if ropt<rmin
        idxMin = idx;
        SrcMin = 0;
        rmin = ropt;
    end
end

% copied from cw6_plotLst
idxLambda = 1;  %hmr.displayLambda;
if SrcMin
    lst = find( SD.MeasList(:,1)==idxMin & SD.MeasList(:,4)==idxLambda );
else
    lst = find( SD.MeasList(:,2)==idxMin & SD.MeasList(:,4)==idxLambda );
end

% Remove any channels from lst which are already part of the hmr.plotLst
% to avoid confusion with double counting of channels
k = find(ismember(lst, hmr.plotLst));
lst(k) = [];

if strcmp(mouseevent,'normal')
    % modify the global variables
    hmr.plotLst_SrcMin = SrcMin;
    hmr.plotLst_idxMin = idxMin;
    
    if SrcMin
        hmr.plotLst = lst;
        hmr.plot = [idxMin*ones(length(lst),1) SD.MeasList(lst,2)];
    else
        hmr.plotLst = lst;
        hmr.plot = [SD.MeasList(lst,1) idxMin*ones(length(lst),1)];
    end
elseif strcmp(mouseevent,'extend')
    if SrcMin
        hmr.plotLst(end+[1:length(lst)]) = lst;
        hmr.plot(end+[1:length(lst)],:) = [idxMin*ones(length(lst),1) SD.MeasList(lst,2)];
    else
        hmr.plotLst(end+[1:length(lst)]) = lst;
        hmr.plot(end+[1:length(lst)],:) = [SD.MeasList(lst,1) idxMin*ones(length(lst),1)];
    end
end

EasyNIRS_plotAxesSDG();
EasyNIRS_DisplayData();


