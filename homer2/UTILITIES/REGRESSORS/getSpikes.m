function spikes = getSpikes(x)
% when is x increasing? (x is assumed to be a logical 0 or 1)
d = [0 diff(x)'];
spikes = d>0;
return