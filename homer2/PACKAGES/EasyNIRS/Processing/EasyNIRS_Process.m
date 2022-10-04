function [procResult, procInput, err, fcallList] = EasyNIRS_Process(hmr,flagNoRun)

if ~exist('flagNoRun')
    flagNoRun = 0;
end

% Initialize output struct
procResult = initProcResultStruct('run');
[err, procInput] = procStreamHasErrors(hmr);
if err
    return;
end


% loop over functions
paramOut = {};
fcallList = {};
hwait = waitbar(0, 'Processing...' );
for iFunc = 1:procInput.procFunc.nFunc
    
    waitbar( iFunc/procInput.procFunc.nFunc, hwait, sprintf('Processing... %s',procInput.procFunc.funcName{iFunc}) );
    
    % Extract input arguments from hmr
    argIn = parseProcessFuncArgsIn(procInput.procFunc.funcArgIn{iFunc});
    for ii = 1:length(argIn)
        if ~exist(argIn{ii},'var')
            if isfield(hmr,argIn{ii})
                eval(sprintf('%s = hmr.%s;',argIn{ii},argIn{ii}));
            else
                eval(sprintf('%s = [];',argIn{ii}));  % if variable doesn't exist and not in hmr then make it empty DAB 11/8/11
            end
        end
    end

    % parse input parameters
    p = [];
    sargin = '';
    sarginVal = '';
    for iP = 1:procInput.procFunc.nFuncParam(iFunc)
        if ~procInput.procFunc.nFuncParamVar(iFunc)
            p{iP} = procInput.procFunc.funcParamVal{iFunc}{iP};
        else
            p{iP}.name = procInput.procFunc.funcParam{iFunc}{iP};
            p{iP}.val = procInput.procFunc.funcParamVal{iFunc}{iP};
        end
        if length(procInput.procFunc.funcArgIn{iFunc})==1 & iP==1
            sargin = sprintf('%sp{%d}',sargin,iP);
            if isnumeric(p{iP})
                if length(p{iP})==1
                    sarginVal = sprintf('%s%s',sarginVal,num2str(p{iP}));
                else
                    sarginVal = sprintf('%s[%s]',sarginVal,num2str(p{iP}));
                end
            elseif ~isstruct(p{iP})
                sarginVal = sprintf('%s,%s',sarginVal,p{iP});
            else
                sarginVal = sprintf('%s,[XXX]',sarginVal);
            end
        else
            sargin = sprintf('%s,p{%d}',sargin,iP);
            if isnumeric(p{iP})
                if length(p{iP})==1
                    sarginVal = sprintf('%s,%s',sarginVal,num2str(p{iP}));
                else
                    sarginVal = sprintf('%s,[%s]',sarginVal,num2str(p{iP}));
                end
            elseif ~isstruct(p{iP})
                sarginVal = sprintf('%s,%s',sarginVal,p{iP});
            else
                sarginVal = sprintf('%s,[XXX]',sarginVal);
            end
        end
    end
    
    % set up output format
    sargout = procInput.procFunc.funcArgOut{iFunc};
    for ii=1:length(procInput.procFunc.funcArgOut{iFunc})
        if sargout(ii)=='#'
            sargout(ii) = ' ';
        end
    end
    
    % call function
    fcall = sprintf( '%s = %s%s%s);', sargout, ...
        procInput.procFunc.funcName{iFunc}, ...
        procInput.procFunc.funcArgIn{iFunc}, sargin );
    if flagNoRun==0
        try 
            eval( fcall );
        catch ME
	        msg = sprintf('Function %s generated ERROR at line %d: %s', procInput.procFunc.funcName{iFunc}, ME.stack(1).line, ME.message);
            menu(msg,'OK');
            close(hwait);
            assert(logical(0), msg);
        end
    end
    fcallList{end+1} = sprintf( '%s = %s%s%s);', sargout, ...
        procInput.procFunc.funcName{iFunc}, ...
        procInput.procFunc.funcArgIn{iFunc}, sarginVal );
    
    % parse output parameters
    foos = procInput.procFunc.funcArgOut{iFunc};
    % remove '[', ']', and ','
    for ii=1:length(foos)
        if foos(ii)=='[' | foos(ii)==']' | foos(ii)==',' | foos(ii)=='#'
            foos(ii) = ' ';
        end
    end
    % get parameters for Output to hmr.procResult
    lst = strfind(foos,' ');
    lst = [0 lst length(foos)+1];
    param = [];
    for ii=1:length(lst)-1
        foo2 = foos(lst(ii)+1:lst(ii+1)-1);
        lst2 = strmatch( foo2, paramOut, 'exact' );
        idx = strfind(foo2,'foo');
        if isempty(lst2) & (isempty(idx) || idx>1) & ~isempty(foo2)
            paramOut{end+1} = foo2;
        end
    end
    
end

% Return if flagNoRun 
% before results are saved back to hmr
if flagNoRun==1
    close(hwait)
    return;
end

% Copy paramOut to procResult
for ii=1:length(paramOut)
    eval( sprintf('procResult.%s = %s;',paramOut{ii}, paramOut{ii}) );
end

% Set changeFlag to show that procResult is consistent with 
% procInput for this run
procInput.changeFlag = 0;
procInput.SD = hmr.SD;

% Save procResult and the procInput that generated it, to the run's 
% .nirs file
% Get input parameters for saving to .nirs file
strLst = '''procResult'',procResult,';
strLst = [strLst '''procInput'',procInput,'];
strLst = [strLst '''SD'',hmr.SD,'];
strLst = [strLst '''s'',hmr.s,'];
strLst = [strLst '''tIncMan'',hmr.tIncMan,'];
strLst = [strLst '''userdata'',hmr.userdata'];

eval(sprintf('SaveDataToRun(hmr.filename, %s)', strLst) );
close(hwait)



% ------------------------------------------------------------------
function [B procInput]=procStreamHasErrors(hmr)

procInput = hmr.procInput;
B=0;
err = EasyNIRS_ProcessOpt_ErrorCheck(hmr.procInput.procFunc,hmr);
if ~all(~err)
    i=find(err==1);
    str1 = 'Error in procInput\n\n';
    for j=1:length(i)
        str2 = sprintf('%s%s',hmr.procInput.procFunc.funcName{i(j)},'\n');
        str1 = strcat(str1,str2);
    end
    str1 = strcat(str1,'\n');
    str1 = strcat(str1,'Load another processing stream?');
    ch = menu( sprintf(str1), 'Yes','No');
    if ch==1
        procInput=EasyNIRS_ProcessOpt_Init();
    end
    B=1;
end
