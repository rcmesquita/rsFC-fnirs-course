function CondNamesPopup = popupmenuCondition_SetStrings(handles, CondNamesAct, s, CondNames)

if ~isempty(handles)
    hObject = handles.popupmenuCondition;
end

CondNamesPopup = CondNamesAct;
for ii=1:length(CondNamesAct)
    k = find(strcmp(CondNamesAct{ii},CondNames));
    if ~isempty(k) && length(find(s(:,k)>=1))>0
        CondNamesPopup{ii} = [' -- ' CondNamesAct{ii}];
    else
        CondNamesPopup{ii} = CondNamesAct{ii};
    end
end

if ~isempty(handles)
    valCurr = get(hObject,'value');
    if valCurr > length(CondNamesPopup)
        set(hObject,'value',1);
    end
    set(hObject,'string',CondNamesPopup);
end

