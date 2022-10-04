function stim = stimCondGroupAdd(stim)

CondNames    = stim.CondNames;
CondNamesAct = stim.CondNamesAct;
CondRunIdx   = stim.CondRunIdx;

CondNamesNew = {};
for ii=1:length(CondNames)
    if isempty(find(strcmp(CondNames{ii},CondNamesAct)))
        CondNamesNew = CondNames{ii};
        break;
    end
end

% if no new conditions added, then nothing to update; return.
if isempty(CondNamesNew)
    return;
end
    
iFile = stim.iFile;

CondNamesAct{end+1} = CondNamesNew;
CondRunIdx(:,end+1) = zeros(size(CondRunIdx,1),1);
CondRunIdx(iFile,end) = ii;

stim.CondNamesAct = CondNamesAct;
stim.CondRunIdx = CondRunIdx;
