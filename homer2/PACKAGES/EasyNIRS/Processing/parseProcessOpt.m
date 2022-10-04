function [procInput err errstr] = parseProcessOpt(fid_or_str,externVars)

procInput = initProcInputStruct('run');
err=0;
errstr='';

C = textscan(fid_or_str,'%s');
if isempty(C{1})
    return;
end

% Parse functions and parameters
% function call, param, param_format, param_value
% funcName{}, funcArgOut{}, funcArgIn{}, nFuncParam(), funcParam{nFunc}{nParam},
% funcParamFormat{nFunc}{nParam}, funcParamVal{nFunc}{nParam}()
procParam = struct([]);
nstr = length(C{1});
nfunc = 0;
flag = 0;
for ii=1:nstr
    if flag==0 || C{1}{ii}(1)=='@'
        if C{1}{ii}=='%'
            flag = 999;
        elseif C{1}{ii}=='@'
            nfunc = nfunc + 1;
            
            k = findstr(C{1}{ii+1},',');
            if ~isempty(k)
                funcName{nfunc} = C{1}{ii+1}(1:k-1);
                funcNameUI{nfunc} = C{1}{ii+1}(k+1:end);
                k = findstr(funcNameUI{nfunc},'_');
                funcNameUI{nfunc}(k)=' ';
            else
                funcName{nfunc} = C{1}{ii+1};
                funcNameUI{nfunc} = funcName{nfunc};
            end
            funcArgOut{nfunc} = C{1}{ii+2};
            funcArgIn{nfunc} = C{1}{ii+3};
            nFuncParam(nfunc) = 0;
            nFuncParamVar(nfunc) = 0;
            funcParam{nfunc} = [];
            funcParamFormat{nfunc} = [];
            funcParamVal{nfunc} = [];
            flag = 3;
        elseif(C{1}{ii} == '*')
            if exist('externVars','var') & ~isempty(externVars)
                % We're about to call the function to find out it's parameter list.
                % Before calling it we need to get the input arguments from the
                % external variables list.
                argIn = parseProcessFuncArgsIn(funcArgIn{nfunc});
                for ii = 1:length(argIn)
                    if ~exist(argIn{ii},'var')
                        eval(sprintf('%s = externVars.%s;',argIn{ii},argIn{ii}));
                    end
                end
                eval(sprintf('%s = %s%s);',funcArgOut{nfunc},funcName{nfunc},funcArgIn{nfunc}));
                nFuncParam(nfunc) = nFuncParam0;
                funcParam{nfunc} = funcParam0;
                funcParamFormat{nfunc} = funcParamFormat0;
                funcParamVal{nfunc} = funcParamVal0;
                for jj=1:nFuncParam(nfunc)
                    eval( sprintf('procParam(1).%s_%s = funcParamVal{nfunc}{jj};',funcName{nfunc},funcParam{nfunc}{jj}) );
                end
            end
            nFuncParamVar(nfunc) = 1;
            flag = 2;
        elseif(C{1}{ii} ~= '*')
            nFuncParam(nfunc) = nFuncParam(nfunc) + 1;
            funcParam{nfunc}{nFuncParam(nfunc)} = C{1}{ii};
            
            for jj = 1:length(C{1}{ii+1})
                if C{1}{ii+1}(jj)=='_'
                    C{1}{ii+1}(jj) = ' ';
                end
            end
            funcParamFormat{nfunc}{nFuncParam(nfunc)} = C{1}{ii+1};
            
            for jj = 1:length(C{1}{ii+2})
                if C{1}{ii+2}(jj)=='_'
                    C{1}{ii+2}(jj) = ' ';
                end
            end
            val = str2num(C{1}{ii+2});
            funcParamVal{nfunc}{nFuncParam(nfunc)} = val;
            if(C{1}{ii} ~= '*')
                eval( sprintf('procParam(1).%s_%s = val;',funcName{nfunc},funcParam{nfunc}{nFuncParam(nfunc)}) );
            end
            nFuncParamVar(nfunc) = 0;
            flag = 2;
        end
    else
        flag = flag - 1;
    end
end
procInput.procParam = procParam;
procInput.procFunc = struct();
procInput.procFunc.nFunc = nfunc;
procInput.procFunc.funcName = funcName;
procInput.procFunc.funcNameUI = funcName;
procInput.procFunc.funcArgOut = funcArgOut;
procInput.procFunc.funcArgIn = funcArgIn;
procInput.procFunc.nFuncParam = nFuncParam;
procInput.procFunc.nFuncParamVar = nFuncParamVar;
procInput.procFunc.funcParam = funcParam;
procInput.procFunc.funcParamFormat = funcParamFormat;
procInput.procFunc.funcParamVal = funcParamVal;

