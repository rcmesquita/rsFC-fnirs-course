function EasyNIRS_stimDataUpdate(stim,what_changed)
global hmr
global COND_TBL_OFFSET;

hmr.userdata = stim.userdata;
hmr.stim.CondNames = stim.CondNames;
hmr.group.conditions.CondNamesAct = stim.CondNamesAct;
hmr.group.conditions.CondRunIdx = stim.CondRunIdx;
hmr.group.conditions.CondTbl = stim.CondTbl;
hmr.s = stim.s;

paramsLst = {};
for ii=1:length(what_changed)
    switch lower(what_changed{ii})
    case {'userdata','userdata_cols'}
        % set(hmr.handles.pushbuttonSave,'visible','on');

        if(strcmp(what_changed{ii},'userdata_cols'))
            EasyNIRS_saveUserDataToGroup();

            % Update associated GUI's
            h = findobj('Tag','EasyNIRS_ProcessOpt');
            if ~isempty(h)
                EasyNIRS_ProcessOpt();
            end
        end

        paramsLst = [paramsLst {'userdata'}];        
    case {'stim'}
        EasyNIRS_DisplayData();
        % EasyNIRS_NIRSsignalProcessEnable('on');

        EasyNIRS_saveUserDataToCurrRun();
        paramsLst = [paramsLst {'s'}];

        popupmenuCondition_SetStrings(hmr.handles, hmr.group.conditions.CondNamesAct, hmr.s, hmr.stim.CondNames);

        % hmr.fileChanged = 1;
        % set(hmr.handles.pushbuttonSave,'visible','on');
    case {'cond'}        
        popupmenuCondition_SetStrings(hmr.handles, hmr.group.conditions.CondNamesAct, hmr.s, hmr.stim.CondNames);
        paramsLst = [paramsLst {'CondNames'}];
    case {'condgroup'}
        if exist('./groupResults.mat','file')
            group = hmr.group;
            save('./groupResults.mat','group');
        end
        for iF=1:size(hmr.group.conditions.CondTbl)
            CondNames = hmr.group.conditions.CondTbl{iF}(COND_TBL_OFFSET+1:end);
            save(hmr.group.conditions.CondTbl{iF}{1},'-mat','-append','CondNames');
        end
        popupmenuCondition_SetStrings(hmr.handles, hmr.group.conditions.CondNamesAct, hmr.s, hmr.stim.CondNames);
    case {'all'}
        if(strcmp(what_changed{ii},'userdata_cols'))
            % Update associated GUI's
            h = findobj('Tag','EasyNIRS_ProcessOpt');
            if ~isempty(h)
                EasyNIRS_ProcessOpt();
            end
        end
        % EasyNIRS_NIRSsignalProcessEnable('on');
        popupmenuCondition_SetStrings(hmr.handles, hmr.group.conditions.CondNamesAct, hmr.s, hmr.stim.CondNames);
        EasyNIRS_saveUserDataToGroup();
        paramsLst = [paramsLst {'s','CondNames','userdata'}];

        % hmr.fileChanged = 1;
        % set(hmr.handles.pushbuttonSave,'visible','on');
    end
end

SaveRunSelect(hmr,paramsLst);

