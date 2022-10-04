%
% Called by
% EasyNIRS_stimDataUpdate
%
%
function procInput = EasyNIRS_ProcessOpt_Update(run)

procInput = run.procInput;
if(isempty(procInput))
    EasyNIRS_ProcessOpt_Init();
end

% After we read from the file see if processing stream was changed 
% from gui
nFuncParam      = [];
funcParam       = {};
funcParamFormat = {};
funcParamVal    = {};
for iFunc=1:length(procInput.procFunc.funcName)
    if ~procInput.procFunc.nFuncParamVar(iFunc)
        nFuncParam(iFunc)      = procInput.procFunc.nFuncParam(iFunc);
        funcParam{iFunc}       = procInput.procFunc.funcParam{iFunc};
        funcParamFormat{iFunc} = procInput.procFunc.funcParamFormat{iFunc};
        funcParamVal{iFunc}    = procInput.procFunc.funcParamVal{iFunc};
    else
        % Extract input arguments for function with variable length params list 
        % from homer
        argIn = parseProcessFuncArgsIn(procInput.procFunc.funcArgIn{iFunc});
        for ii = 1:length(argIn)
            eval(sprintf('%s = run.%s;',argIn{ii},argIn{ii}));
        end

        p = [];
        sargin = '';
        for iP = 1:procInput.procFunc.nFuncParam(iFunc)
            p{iP}.name = procInput.procFunc.funcParam{iFunc}{iP};
            p{iP}.val = procInput.procFunc.funcParamVal{iFunc}{iP};
            if length(procInput.procFunc.funcArgIn{iFunc})==1 & iP==1
                sargin = sprintf('%sp{%d}',sargin,iP);
            else
                sargin = sprintf('%s,p{%d}',sargin,iP);
            end
        end
        eval(sprintf('%s = %s%s%s);',procInput.procFunc.funcArgOut{iFunc},...
                                     procInput.procFunc.funcName{iFunc},...
                                     procInput.procFunc.funcArgIn{iFunc},sargin));
        nFuncParam(iFunc) = nFuncParam0;
        funcParam{iFunc} = funcParam0;
        funcParamFormat{iFunc} = funcParamFormat0;
        funcParamVal{iFunc} = funcParamVal0;
    end
end
procInput.procFunc.nFuncParam      = nFuncParam; 
procInput.procFunc.funcParam       = funcParam; 
procInput.procFunc.funcParamFormat = funcParamFormat;
procInput.procFunc.funcParamVal    = funcParamVal;

procParam0      = [];
for iFunc=1:length(procInput.procFunc.funcName)
    for iParam=1:procInput.procFunc.nFuncParam(iFunc)
        eval( sprintf('procParam0.%s_%s = procInput.procFunc.funcParamVal{iFunc}{iParam};',...
                  procInput.procFunc.funcName{iFunc},procInput.procFunc.funcParam{iFunc}{iParam}) );
    end
end
procInput.procParam = procParam0;
