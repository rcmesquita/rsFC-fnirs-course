function EasyNIRS_CopyOptions()
global hmr

h = findobj('Tag','EasyNIRS_ProcessOpt');
if ~isempty(h)
    EasyNIRS_ProcessOpt();
end
EasyNIRS_NIRSsignalProcessUpdate(hmr);

