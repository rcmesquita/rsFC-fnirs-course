function EasyNIRS_enableAuxGuiParams(handles,enable,options,val)
global hmr

if isempty(hmr.aux)
    set(handles.checkboxPlotAux,'enable','off');
    set(handles.listboxAux,'enable','off');
    hmr.plotAux=0;
    return;
end

if strcmp(enable,'on') 
    set(handles.checkboxPlotAux,'enable','on');
    set(handles.listboxAux,'enable','on');
elseif strcmp(enable,'off')
    set(handles.checkboxPlotAux,'enable','off');
    set(handles.listboxAux,'enable','off');
end 

if(exist('options','var'))
    set(handles.listboxAux,'string',options);
end
if(exist('val','var'))
    set(handles.listboxAux,'value',val);
end
