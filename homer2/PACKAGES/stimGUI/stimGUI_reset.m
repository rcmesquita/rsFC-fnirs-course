function stimGUI_reset()
global stim

if isfield(stim,'what_changed') && ~isempty(stim.what_changed)
    ch = menu('Do you want to save changes to stimGUI?','Yes','No');
    if ch==1
        stimGUI_Save_Callback(stim.handles.pushbuttonSave);
    end
end
if( isfield(stim,'LegendHdl') && ishandle(stim.LegendHdl))
    delete(stim.LegendHdl);
end
stim = [];
