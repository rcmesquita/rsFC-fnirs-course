function EasyNIRS_DisplayData_StimCallback()
global hmr

point1 = get(gca,'CurrentPoint');    % button down detected
finalRect = rbbox;                   % return figure units
point2 = get(gca,'CurrentPoint');    % button up detected
point1 = point1(1,1:2);              % extract x and y
point2 = point2(1,1:2);
p1 = min(point1,point2); 
p2 = max(point1,point2); 

lst = find(hmr.t>=p1(1) & hmr.t<=p2(1));
s = sum(abs(hmr.s(lst,:)),2);
[lst2]=find(s==1);

if isempty(lst2)
    menu( 'Drag a box around the stim to edit.','Okay');
    return;
end

yy = ylim();
hold on
hl = [];
for ii=1:length(lst2)
    hl(ii) = plot(hmr.t(lst(lst2(ii)))*ones(2,1),yy,'k-');
end
set(hl,'linewidth',3)
hold off

% Set up query menu
actionList{1} = 'Toggle active on/off';
actionList{2} = 'Cancel';
nch = length(actionList);    
ch = menu('Action for these stim marks?', actionList );

% Got the user's responce now act on it
if ch==nch
    delete(hl);
    return;
end

if ch==1  % toggle active
    hmr.s(lst(lst2),:) = hmr.s(lst(lst2),:) * (-1);
end

delete(hl);

hmr.fileChanged = 1;
set(hmr.handles.pushbuttonSave,'visible','on')
EasyNIRS_NIRSsignalProcessEnable('on')

stimGUI_DisplayData(hmr.s);
EasyNIRS_DisplayData();
