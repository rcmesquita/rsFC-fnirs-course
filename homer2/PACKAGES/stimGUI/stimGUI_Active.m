function status = stimGUI_Active()
global stim

status = 0;
if(~isempty(stim))
    if(isfield(stim,'handles') & ...
       isfield(stim.handles,'axes1') & ...
       ishandle(stim.handles.axes1))

         status = 1;
         
    end
end
