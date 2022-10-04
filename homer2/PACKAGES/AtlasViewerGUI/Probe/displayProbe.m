function probe = displayProbe(probe, headsurf, hAxes)

if isempty(probe)
    return;
end
if probe.isempty(probe)
    return;
end
if ~exist('hAxes','var')
    hAxes = probe.handles.axes;
end

if ishandles(probe.handles.hSrcpos)
    delete(probe.handles.hSrcpos);
end 
if ishandles(probe.handles.hDetpos)
    delete(probe.handles.hDetpos);
end 
if ishandles(probe.handles.hOptodes)
    delete(probe.handles.hOptodes);
end

viewOrigin(hAxes);

probe = viewProbe(probe, 'registered');
probe = setProbeDisplay(probe, headsurf);
hold off;

