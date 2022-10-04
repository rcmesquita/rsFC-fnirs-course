function q = isContributingHRF(iCh, iCond, nTrials, plotHRF, groupidx)
global hmr
global HRF_GRP_CONST
global HRF_SESS_CONST

q=1;
if iCond==0 || iCond>size(nTrials,2)
    q=0;
    return;
end

procResult_run = hmr.procResult;
iF = groupidx(1);
i = groupidx(2);
j = groupidx(3);
k = groupidx(4);
SD = hmr.procInput.SD;
iS_run = hmr.group(i).conditions.CondRunIdx(iF,iCond);

if plotHRF==HRF_GRP_CONST
    if ~isempty(hmr.group(i).procResult.grpAvgPass) & hmr.group(i).procResult.grpAvgPass(iCh,iCond,j)==0
        q=0;
    end
    
    % Check run contribution to group avg
    if 1
        
        if iS_run==0 || iS_run>size(procResult_run.nTrials,2) || procResult_run.nTrials(iS_run)==0
            q=0;
        end
        
    % Check subj contribution to group avg
    else
        
        if hmr.group(i).subjs(j).procResult.nTrials(iCh,iCond)==0
            q=0;
        end
        
    end
       
    if ~SD.MeasListAct(iCh)
        q=0;
    end
    
elseif plotHRF==HRF_SESS_CONST
    
    if iS_run==0 || iS_run>size(procResult_run.nTrials,2) || procResult_run.nTrials(iS_run)==0
        q=0;
    end
    
    if ~SD.MeasListAct(iCh)
        q=0;
    end
    
end

