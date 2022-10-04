function [verstr, vernum] = EasyNIRS_version(hObject)

if ~exist('hObject','var')
    hObject = -1;
end
[verstr, vernum] = version2string();
title = sprintf('Homer2_UI  (%s) - %s', verstr, pwd);
if ishandle(hObject)
    set(hObject,'name', title);
end
