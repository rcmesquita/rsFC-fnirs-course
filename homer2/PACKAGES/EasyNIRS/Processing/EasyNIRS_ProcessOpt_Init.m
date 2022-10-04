%
% Called by
% EasyNIRS_OpeningFcn
%
%
function procInput=EasyNIRS_ProcessOpt_Init(varargin)
global hmr 

procInput = [];

%%%%% First try to get procInput from the current run's procInput
if length(varargin)==0 && ~isempty(hmr.procInput.procFunc)

    [err iReg procInputReg] = EasyNIRS_ProcessOpt_ErrorCheck(hmr.procInput.procFunc,hmr);
    if ~all(~err)
        i=find(err==1);
        str1 = 'Error in saved procInput functions\n\n';
        for j=1:length(i)
            str2 = sprintf('%s%s',hmr.procInput.procFunc.funcName{i(j)},'\n');
            str1 = strcat(str1,str2);
        end
        str1 = strcat(str1,'\n');
        str1 = strcat(str1,'Will replace these functions with with updated versions...');
        ch = menu( sprintf(str1), 'OK');
        [hmr.procInput err] = fixProcStreamErr(err, hmr.procInput, iReg, procInputReg);
        setGroupProcInput(hmr.procInput,'overwrite');
        procInput = hmr.procInput;

    % If there are NO errors in procInput, then look for empty procInputreturn
    else 
        procInput = hmr.procInput;
        setGroupProcInput(procInput,'init');
    end 
    
    return;
end


%%%%% Otherwise try loading procInput from a config file, but first 
%%%%% figure out the name of the config file
filename = [];
if length(varargin)>0
    arg = varargin{1};
    if isfield(arg,'procFunc')
        procInput = arg;
    else        
        filename = arg;
    end
end
err1=1; err2=1;
while ~all(~err1) || ~all(~err2)

    % Load Processing stream file
    if isempty(filename) && isempty(procInput)
        
        % This pause is a workaround for a matlab bug in version 
        % 7.11 for Linux, where uigetfile won't block unless there's
        % a breakpoint. 
        pause(.5);        
        [filename pathname] = uigetfile('*.cfg', 'Load Process Options File' );
        if filename==0            
            ch = menu( sprintf('Loading default config file.'),'Okay');
            filename = './processOpt_default.cfg';
            processOpt(filename);
        else
            filename = [pathname filename];
        end
        
        % Load procInput from config file
        fid = fopen(filename,'r');
        [procInput err1] = parseProcessOpt(fid,hmr);
        fclose(fid);
        
    elseif ~isempty(filename) && isempty(procInput)
        
        % Load procInput from config file
        fid = fopen(filename,'r');
        [procInput err1] = parseProcessOpt(fid,hmr);
        fclose(fid);
        
    else
        
        err1=0;
    
    end
    

    % Check loaded procInput for syntax and semantic errors
    if isempty(procInput.procFunc) && err1==0
        ch = menu('Warning: config file is empty.','Okay');
    elseif err1==1
        ch = menu('Syntax error in config file.','Okay');
    end

    [err2 iReg procInputReg] = EasyNIRS_ProcessOpt_ErrorCheck(procInput.procFunc,hmr);
    if ~all(~err2)
        i=find(err2==1);
        str1 = 'Error in functions\n\n';
        for j=1:length(i)
            str2 = sprintf('%s%s',procInput.procFunc.funcName{i(j)},'\n');
            str1 = strcat(str1,str2);
        end
        str1 = strcat(str1,'\n');
        str1 = strcat(str1,'Do you want to keep current proc stream or load another file?...');
        ch = menu(sprintf(str1), 'Fix and load this config file','Create and use default config','Cancel');
        if ch==1
            [procInput err2] = fixProcStreamErr(err2, procInput, iReg, procInputReg);
            
            % If the proc stream was fixed successfully, ask the user if they want
            % to save it to the file from which it was loaded. 
            if all(~err2)
                k=find(filename=='/' | filename=='\');
                if ~isempty(k) && k(end)<length(filename)
                    filename0 = filename(k(end)+1:end);
                else
                    filename0 = filename;
                end
                str = sprintf('Do you want to update %s with the fixed processing stream?',filename0);
                ch = menu(str, 'Yes','No','Save to another file');
                if ch==1
                    procStreamSave(filename, procInput.procFunc);
                elseif ch==3
                    [filename pathname] = uiputfile('*.cfg', 'Save Processing Options to File' );
                    if filename==0
                        ch = menu( sprintf('Cannot save file to in this directory.'),'Okay');
                    else
                        filename = [pathname filename];
                        procStreamSave(filename, procInput.procFunc);                
                    end                    
                end
            end
        elseif ch==2
            filename = './processOpt_default.cfg';
            processOpt(filename);

            fid = fopen(filename,'r');
            [procInput err1] = parseProcessOpt(fid,hmr);
            fclose(fid);
            break;
        elseif ch==3
            return;
        end
    end
    filename = [];
end

% Check for consistency with procInput.procParam
procInput.changeFlag = 1;
if ~isempty(hmr.procInput.procParam)

    flag = 0;
    [s1 s2 err] = comp_struct(hmr.procInput.procParam,procInput.procParam);
    for ii=1:length(err)
        if(strcmp(err(ii),'Un-matched'))
            flag=1;
            break;
        end
    end

    if flag~=0
        procInput.changeFlag = 2;

        % New proc stream differs from old one.
        if exist('./groupResults.mat','file')
            ch = menu( sprintf('Loading new processing stream! Do you want to save the old groupResults.mat?'),'Yes','No','Cancel' );
            if ch==1
                [filename pathname] = uiputfile('*.*', 'Saving group results.');           
                if filename ~= 0
                    copyfile('groupResults.mat',[pathname filename]);
                end
            elseif ch==3
                return;
            end
        else
            ch = menu( sprintf('Loading new processing stream!'),'OK','Cancel');
            if ch==2
                return;
            end
        end
    else
        procInput.changeFlag = 0;
    end
else
    hmr.procInput = procInput;
end
setGroupProcInput(procInput,'overwrite');
hmr.procInput = procInput;





% ----------------------------------------------------------------------
function setGroupProcInput(procInput,mode)
global hmr

% Initialize processing group with proc parameters
hwait = waitbar(0,'Initializing runs with procInput');
nFiles = hmr.group(1).nFiles;
for ii=1:length(hmr.group)
    procInputGroup = initProcInputStruct('group');
    for jj=1:length(hmr.group(ii).subjs)
        procInputSubj = initProcInputStruct('subj');
        for kk=1:length(hmr.group(ii).subjs(jj).runs)
            hwait = waitbar( hmr.group(ii).subjs(jj).runs(kk).fileidx/nFiles, hwait, ...
                             sprintf('Initializing procInput for file %s, %d of %d',...
                                      hmr.group(ii).subjs(jj).runs(kk).filename,...
                                      hmr.group(ii).subjs(jj).runs(kk).fileidx,...
                                      nFiles) );
            if strcmp(mode,'overwrite')
                [hmr.group(ii).subjs(jj).runs(kk) d] = overwriteProcInputRun(hmr.group(ii).subjs(jj).runs(kk),procInput);
            elseif strcmp(mode,'init')
                [hmr.group(ii).subjs(jj).runs(kk) d] = initProcInputRun(hmr.group(ii).subjs(jj).runs(kk),procInput);
            end
            if hmr.group(ii).subjs(jj).runs(kk).procInput.changeFlag>0
                procInputSubj.changeFlag = d;
            end
        end
        if procInputSubj.changeFlag>0
            procInputGroup.changeFlag = 1;
            hmr.group(ii).subjs(jj).procInput.changeFlag = procInputSubj.changeFlag;
        end
    end
    if procInputGroup.changeFlag>0
        hmr.group(ii).procInput.changeFlag = procInputGroup.changeFlag;
    end
end
close(hwait);




% -------------------------------------------------------------------
function [node d] = initProcInputRun(node,procInput)

if isempty(node.procInput.procParam)
    rundata = load(node.filename,'-mat','procInput');
    if ~isfield(rundata,'procInput')
        node.procInput = copyStructFieldByField(node.procInput,procInput);
    else
        node.procInput = copyStructFieldByField(node.procInput,rundata.procInput);
    end            
    node.procInput.changeFlag = 1;
end
d = node.procInput.changeFlag; 



% ---------------------------------------------------------------------
function [node d] = overwriteProcInputRun(node,procInput)

if ~isempty(node.procInput)
    d = data_diff(node.procInput.procParam, procInput.procParam);
else
    d = 2;
end
node.procInput = copyStructFieldByField(node.procInput,procInput);
node.procInput.changeFlag = d;

