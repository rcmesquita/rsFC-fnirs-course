
% --- Executes on button press in pushbuttonSave.
function stimGUI_Save_Callback(hObject, eventdata, handles)
global stim

set(hObject,'enable','off');
EasyNIRS_stimDataUpdate(stim,stim.what_changed);
stim.what_changed = {};
