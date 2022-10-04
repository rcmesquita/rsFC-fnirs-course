function listboxFiles_setCurrSelection(handles,iGrp,iSubj,iRun)
global hmr

% Check if session/file has multiple runs
iFile = hmr.group(iGrp).subjs(iSubj).runs(iRun).fileidx;
set(handles.listboxFiles,'value',iFile);
hmr.listboxFileCurr.iFile = iFile;
hmr.listboxFileCurr.iGrp  = iGrp;
hmr.listboxFileCurr.iSubj = iSubj;
hmr.listboxFileCurr.iRun  = iRun;
