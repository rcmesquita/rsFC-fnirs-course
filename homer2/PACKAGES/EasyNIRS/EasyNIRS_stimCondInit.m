function CondTbl = EasyNIRS_stimCondInit(files,CondTbl)

nFiles = length(files);
if ~exist('CondTbl','var')
    
    CondTbl = cell(nFiles,1);
    for iF=1:nFiles
        if files(iF).isdir 
            continue;
        end
        CondTbl{iF} = stimCondInitTblEntry(files(iF).name);
    end
    
else

    for iF=1:nFiles
        if files(iF).isdir 
            continue;
        end
        for iTbl=1:length(CondTbl)
            if ~isempty(CondTbl{iTbl}) && strcmp(CondTbl{iTbl}{1},files(iF).name)
                CondTbl{iTbl} = stimCondInitTblEntry(files(iF).name);
            end
        end        
    end
    
end
