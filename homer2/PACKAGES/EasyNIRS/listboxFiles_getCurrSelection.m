function [iFile iGrp iSubj iRun] = listboxFiles_getCurrSelection(handles)
global hmr

% Check if session/file has multiple runs
iFile = get(handles.listboxFiles,'value');

iGrp = 1;  % group is always current
iSubj = 0;
iRun = 0;
for jj=1:length(hmr.group(1).subjs)
    for kk=1:length(hmr.group(1).subjs(jj).runs)
        if(hmr.group(1).subjs(jj).runs(kk).fileidx == iFile)
            iSubj = jj;
            iRun = kk;
        elseif(hmr.group(1).subjs(jj).fileidx == iFile)
            iSubj = jj;
            iRun = 0;
        end
    end
end
hmr.listboxFileCurr.iFile = iFile;
hmr.listboxFileCurr.iSubj = iSubj;
hmr.listboxFileCurr.iRun  = iRun;
hmr.listboxFileCurr.iGrp  = iGrp;


