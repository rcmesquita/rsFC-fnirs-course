function [beatStart,beatStop] = pruneBeats(posBeats,po)
% keep positive beats that have neg beats after them. If not, keep only
% first one.
checkTimes = find(diff([0 posBeats])>0);
beatStart = [];
beatStop = [];
nowDone = 0;
for i=1:length(checkTimes)
    if i==1
        bStart = checkTimes(1);
    else
        ind = find(checkTimes>beatStop(i-1),1);
        if ~isempty(ind)
            bStart = checkTimes(ind);
        else
            break;
        end
    end
    ind = find(po(bStart:end)<0,1);
    if isempty(ind)
        break
    end
    beatStart(i) = bStart;
    beatStop(i) = bStart+ind-1;
end
return