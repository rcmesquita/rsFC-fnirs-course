function   plotProbeGUI_sdgToggleLines(hObject, eventdata, handles)
%This function is called when the user clicks on one of the meausrement
%lines in the SDG window
global hmr;

SD = hmr.SD;

idx = eventdata;

%change measListAct
h2=get(handles.axesSDG,'children');  %The list of all the lines currently displayed

    lst=find(SD.MeasList(:,1)==hmr.plot(idx,1) &...
        SD.MeasList(:,2)==hmr.plot(idx,2));
    
    %Switch the linestyles 
    if strcmp(get(h2(idx),'linestyle'), '-')
        set(h2(idx),'linestyle','--')
        SD.MeasListAct(lst)=0;
    else
        set(h2(idx),'linestyle','-')
        SD.MeasListAct(lst)=1;
    end

    hmr.SD = SD;


%Update the displays
plotProbeGUI_plotAxesSDG(handles)
plotProbeGUI_DisplayData()
