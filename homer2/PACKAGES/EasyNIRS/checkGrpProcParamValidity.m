function group = checkGrpProcParamValidity(group,grouplevel,i,j)
global HRF_GRP_CONST
global HRF_SESS_CONST
global HRF_RUN_CONST

run = load(group(1).subjs(i).runs(j).filename,'procInput','-mat');
if grouplevel==log2(HRF_GRP_CONST)+1
    if isempty(group(1).procInput.procInputSubj.procInputRun.procParam)
        group(1).procResult = initProcResultStruct('group');
    end
    if data_diff(group(1).procInput.procInputSubj.procInputRun.procParam, ...
                 group(1).subjs(i).procInput.procInputRun.procParam)
        group(1).procResult = initProcResultStruct('group');
    end
    if data_diff(group(1).procInput.procInputSubj.procInputRun.procParam, ...
                 run.procInput.procParam)
        group(1).procResult = initProcResultStruct('group');
        group(1).subjs(i).procResult = initProcResultStruct('subj');
    end
elseif grouplevel==log2(HRF_SESS_CONST)+1
    if  isempty(group(1).subjs(i).procInput.procInputRun.procParam)
        group(1).subjs(i).procResult = initProcResultStruct('subj');
        group(1).procResult = initProcResultStruct('group');
    end
    if data_diff(group(1).subjs(i).procInput.procInputRun.procParam, ...
                 group(1).procInput.procInputSubj.procInputRun.procParam)
        group(1).procResult = initProcResultStruct('group');
    end
    if data_diff(group(1).subjs(i).procInput.procInputRun.procParam, ...
                 run.procInput.procParam)
        group(1).subjs(i).procResult = initProcResultStruct('subj');
    end
elseif grouplevel==log2(HRF_RUN_CONST)+1
    if isempty(group(1).subjs(i).procInput.procInputRun.procParam) || ...
       data_diff(run.procInput.procParam,...
                 group(1).subjs(i).procInput.procInputRun.procParam)
        group(1).subjs(i).procResult = initProcResultStruct('subj');
        group(1).procResult = initProcResultStruct('group');

    end
end
