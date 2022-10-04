function [CondNames CondRunIdx]=stimGUI_MakeConditions(CondTbl)
global COND_TBL_OFFSET

% Generate the first output paramaters - CondNames
CondNames={};
nFiles = size(CondTbl,1);
for iF=1:nFiles
    for iC=COND_TBL_OFFSET+1:length(CondTbl{iF})
        CondNames{end+1} = CondTbl{iF}{iC};
    end
end
CondNames = unique(CondNames);


% Generate the second output parameter - CondRunIdx using the 1st
CondRunIdx = zeros(nFiles,length(CondNames));
for iC=1:length(CondNames)
    for iF=1:nFiles
        k = find(strcmp(CondNames{iC},CondTbl{iF}));
        if length(k)==0
            CondRunIdx(iF,iC) = 0;
        else
            CondRunIdx(iF,iC) = k(1)-COND_TBL_OFFSET;
        end
    end
end

% TO DO: Get rid of all unused conditions at the group level

