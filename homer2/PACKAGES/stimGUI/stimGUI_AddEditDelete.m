function what_changed = stimGUI_AddEditDelete(tPts, iS_lst, auxflag)
% Usage:
%
%     stimGUI_AddEditDelete(tPts,iS_lst,auxflag)
%
% Inputs:
%
%     tPts  - time range selected in stim.t
%     iS_lst - indices in tPts of existing stims

global stim
what_changed={};

if isempty(tPts)
    return;
end


if(~exist('auxflag','var'))
    auxflag = 0;
end

stim0 = stim;
actionLst = {};
nCond = length(stim.CondNamesAct);

% Create menu actions list
for ii=1:nCond
    actionLst{ii} = sprintf('%s',stim.CondNamesAct{ii});
end
actionLst{end+1} = 'New condition';
if ~isempty(iS_lst)
    actionLst{end+1} = 'Toggle active on/off';
    actionLst{end+1}='Delete';
    menuTitleStr = sprintf('Edit/Delete stim mark(s) at t=%0.1f-%0.1f to...',...
                           stim.t(tPts(iS_lst(1))),stim.t(tPts(iS_lst(end))));
else
    menuTitleStr = sprintf('Add stim mark at t=%0.1f...',...
                           stim.t(tPts(1)));
end
actionLst{end+1} = 'Cancel';
nActions = length(actionLst);
ch = menu(menuTitleStr,actionLst);

% Get users responce to menu question

% Cancel
if ch==nActions || ch==0
    return;
end


% New stim
if(isempty(iS_lst))
    
    % Add new stim with new group condition
    if ch==nCond+1
        CondNameNew = inputdlg('','New Condition name');
        if isempty(CondNameNew)
            stim = stim0;
            return;
        end
        while ~isempty(find(strcmp(CondNameNew, stim.CondNamesAct)))
            CondNameNew = inputdlg('Condition already exists. Choose another name.','New Condition name');
            if isempty(CondNameNew)
                stim = stim0;
                return;
            end
        end
        stim.CondNames(end+1) = CondNameNew;
        stim.s(tPts,end+1) = 1;
        
        stim = stimCondGroupAdd(stim);


    % Add new stim to exiting group condition. Condition 
    % might or might not exist in the run. This elseif 
    % takes care of both cases.
    elseif ch<=nCond

        iS = stim.CondRunIdx(stim.iFile,ch);
        if iS==0
            iS = length(stim.CondNames)+1;
            stim.CondRunIdx(stim.iFile,ch) = iS;
            stim.CondNames{iS} = stim.CondNamesAct{ch};
        end
        stim.s(tPts,iS) = 1;

    end

    % Add new stim entry to userdata
    data = {};
    for ii=1:length(tPts)
        t = stim.t(tPts(ii));
        for jj=1:size(stim.userdata.data,1)
            if(stim.userdata.data{jj,1} > t)
                break;
            end
            data(jj,:) = stim.userdata.data(jj,:);
        end
        data(end+1,:) = [{t},repmat({''},1,size(stim.userdata.data,2)-1)];
        stim.userdata.data = [data; stim.userdata.data(jj:end,:)];
    end

% Existing stim
else

    % Delete stim
    if ch==nActions-1 & nActions==nCond+4
        % Delete stim entry from userdata first 
        % because it depends on stim.s
        [lstR,lstC] = find(abs(stim.s)==1);
        lstR = sort(unique(lstR));
        for ii=1:length(iS_lst)
            lst3(ii) = find(lstR == tPts(iS_lst(ii)));
        end
        stim.userdata.data(lst3,:) = [];
        
        % Before deleting stim, find it's condition to be able to 
        % to use it to check whether that condition is empty of stims. 
        % Then if the stim's previous condition is empty query user about 
        % whether it should be deleted
        [lstR,lstC] = find(stim.s(tPts(iS_lst),:)==1);
        lstC = unique(lstC);
        stim.s(tPts(iS_lst),:) = 0;        
        
    % Toggle active/inactive stim
    elseif ch==nActions-2 & nActions==nCond+4
        stim.s(tPts(iS_lst),:) = stim.s(tPts(iS_lst),:) .* -1;

    % Edit stim
    elseif ch<=nCond+1

        % Before moving stim, find it's condition to be able to 
        % to use it to check whether that condition is empty of stims. 
        % Then if the stim's previous condition is empty query user about 
        % whether it should be deleted
        [lstR,lstC] = find(stim.s(tPts(iS_lst),:)~=0);
        lstC = unique(lstC);

        stim.s(tPts(iS_lst),:) = 0;

        % Assign new condition to edited stim
        if ch==nCond+1
            
            CondNameNew = inputdlg('','New Condition name');
            if isempty(CondNameNew)
                stim = stim0;
                return;
            end
            while ~isempty(find(strcmp(CondNameNew,stim.CondNamesAct)))
                CondNameNew = inputdlg('Condition already exists. Choose another name.','New Condition name');
                if isempty(CondNameNew)
                    stim = stim0;
                    return;
                end
            end
            stim.CondNames(end+1) = CondNameNew;
            stim.s(tPts(iS_lst),end+1) = 1;
            
            stim = stimCondGroupAdd(stim);
            
        else
            
            iS = stim.CondRunIdx(stim.iFile,ch);
            if iS==0
                iS = length(stim.CondNames)+1;
                stim.CondRunIdx(stim.iFile,ch) = iS(1);
            end
            stim.CondNames{iS} = stim.CondNamesAct{ch};
            stim.s(tPts(iS_lst),iS) = 1;
            
        end
        
    end
end

[foo1 foo2 err] = comp_struct(stim0.s,stim.s);
if ~isempty(foo1) | ~isempty(foo2) | ~isempty(err)
    what_changed{end+1} = 'stim';
end
[foo1 foo2 err] = comp_struct(stim0.CondNames,stim.CondNames);
if ~isempty(foo1) | ~isempty(foo2) | ~isempty(err)
    what_changed{end+1} = 'cond';
end


