function LoadNIRS2hmr(files,handles)
global hmr

group = loadGroup(files);

bf=0;
ii=1;

for jj=1:length(group(ii).subjs)
    for kk=1:length(group(ii).subjs(jj).runs)
        procInput = group(ii).subjs(jj).runs(kk).procInput;
        if ~isempty(procInput.procParam)
            bf=1;
            break;
        end
    end
    if bf==1
        break;
    end
end


hmr.group = group;
listboxFiles_setCurrSelection(handles,ii,jj,kk);
LoadCurrNIRSFile(hmr.group(ii).subjs(jj).runs(kk).filename, handles);
