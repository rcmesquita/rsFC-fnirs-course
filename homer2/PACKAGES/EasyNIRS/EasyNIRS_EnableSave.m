function EasyNIRS_EnableSave(enable)
global hmr

handles = hmr.handles;

if strcmpi(enable,'on')
    set(handles.pushbuttonSave,'visible','on')
elseif strcmpi(enable,'off')
    set(handles.pushbuttonSave,'visible','off')
end
