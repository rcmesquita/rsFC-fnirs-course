function EasyNIRS_NIRSsignalProcessEnable(enable)
global hmr

handles = hmr.handles;

%{
if strcmpi(enable,'on')
    set(handles.popupmenuNIRSsignalProcess,'visible','on')
    set(handles.textCalculateHRF,'visible','on');
elseif strcmpi(enable,'off')
    set(handles.popupmenuNIRSsignalProcess,'visible','off')
    set(handles.textCalculateHRF,'visible','off');
end
%}
