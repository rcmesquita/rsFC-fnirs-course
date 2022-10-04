function obj = drawPlotProbeDuplicate(obj,hParent,hFig)

if ~isempty(obj.h)
    return;
end

obj.h = uicontrol('parent',hParent,'style','pushbutton','tag','pushbuttonPlotProbeDuplicate',...
                  'units','normalized','position',obj.pos,...
                  'string','Duplicate Plot',...
                  'callback',@pushbuttonPlotProbeDuplicate_Callback);
