function EasyNIRS_NIRSsignalProcessUpdate(hmr)

group = hmr.group;
filename = hmr.filename;
handles = hmr.handles;
copyOptions = hmr.copyOptions;

HRFGuiTxt0{1} = {'Run','Session','Group'};
HRFGuiTxt0{2} = {'show Run HRF','show Sess HRF','show Grp HRF'};
HRFGuiTxt=HRFGuiTxt0;
bf=0;
ii=1;
%for ii=1:length(group)
    for jj=1:length(group(ii).subjs)
        for kk=1:length(group(ii).subjs(jj).runs)
            if strcmp(filename,group(ii).subjs(jj).runs(kk).filename)
                if group(ii).subjs(jj).runs(kk).procInput.changeFlag>0
                    HRFGuiTxt = editHRFGuiTxt_OptionsChanged(HRFGuiTxt,1);
                end
                if group(ii).subjs(jj).procInput.changeFlag>0
                    HRFGuiTxt = editHRFGuiTxt_OptionsChanged(HRFGuiTxt,2);
                end
                if group(ii).procInput.changeFlag>0
                    HRFGuiTxt = editHRFGuiTxt_OptionsChanged(HRFGuiTxt,3);
                end
                bf=1; break;
            end
        end
        if bf==1
            break;
        end
    end
%    if bf==1
%        break;
%    end
%end

set(handles.popupmenuNIRSsignalProcess,'string',HRFGuiTxt{1});
v{1} = get(handles.checkboxPlotHRFRun,'enable');
v{2} = get(handles.checkboxPlotHRFSess,'enable');
v{3} = get(handles.checkboxPlotHRFGrp,'enable');
if strcmp(v{1},'off')
    HRFGuiTxt{2}{1} = HRFGuiTxt0{2}{1};
end
if strcmp(v{2},'off')
    HRFGuiTxt{2}{2} = HRFGuiTxt0{2}{2};
end
if strcmp(v{3},'off')
    HRFGuiTxt{2}{3} = HRFGuiTxt0{2}{3};
end
set(handles.checkboxPlotHRFRun,'string',HRFGuiTxt{2}{1});
set(handles.checkboxPlotHRFSess,'string',HRFGuiTxt{2}{2});
set(handles.checkboxPlotHRFGrp,'string',HRFGuiTxt{2}{3});



% -------------------------------------------------------------------
function HRFGuiTxt = editHRFGuiTxt_OptionsChanged(HRFGuiTxt,iOpt0)

for iPar=1:2
    for iOpt=iOpt0:3
        if isempty(findstr(HRFGuiTxt{iPar}{iOpt},' **'))
            HRFGuiTxt{iPar}{iOpt} = strcat(HRFGuiTxt{iPar}{iOpt},' **');
        end
    end
end
