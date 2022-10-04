function stimGUI_DisplayData_StimCallback( )
global stim

point1 = get(gca,'CurrentPoint');    % button down detected
finalRect = rbbox;                   % return figure units
point2 = get(gca,'CurrentPoint');    % button up detected
point1 = point1(1,1:2);              % extract x and y
point2 = point2(1,1:2);
p1 = min(point1,point2); 
p2 = max(point1,point2); 

if ~all(p1==p2)
    lst = find(stim.t>=p1(1) & stim.t<=p2(1));
else
    t1 = (stim.t(end)-stim.t(1))/length(stim.t);
    lst = min(find(abs(stim.t-p1(1))<t1));
end
s = sum(abs(stim.s(lst,:)),2);
lst2 = find(s>=1);

if isempty(lst2) & ~(p1(1)==p2(1))
    menu( 'Drag a box around the stim to edit.','Okay');
    return;
end

stim.what_changed = [stim.what_changed stimGUI_AddEditDelete(lst,lst2)];
if isempty(stim.what_changed)
    return;
end

set(stim.handles.pushbuttonSave,'enable','on');
%EasyNIRS_stimDataUpdate(stim,what_changed);
stimGUI_DisplayData();

