function EasyNIRS_EnablePlotButtons( handles )
global hmr

set(handles.checkboxPlotHRFRun,'enable','on');
set(handles.checkboxPlotHRFSess,'enable','on');
set(handles.checkboxPlotHRFGrp,'enable','on');

flag=0;
if get(handles.checkboxPlotHRFRun,'value')==1
    flag=1;
elseif get(handles.checkboxPlotHRFSess,'value')==1
    flag=1;
elseif get(handles.checkboxPlotHRFGrp,'value')==1
    flag=1;
end
if flag==1
    set(handles.checkboxDisplayStim,'enable','off');
    set(handles.radiobuttonPlotRaw,'enable','off');
    set(handles.menuViewHRFStdErr,'enable','on');
    set(handles.radiobuttonPlotConc,'enable','on');
    set(handles.radiobuttonPlotOD,'enable','on');
end
