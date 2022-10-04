function peakTimes = findpeaks(checkTimes,checkTimeEnds,orig)
% given checkTimes and ends, we find the indices when orig is max
peakTimes = [];
for beat=1:length(checkTimes)
	beatStart = checkTimes(beat);
	beatEnd = checkTimeEnds(beat);
	snip = orig(beatStart:beatEnd);
	[m,i] = max(snip);
	peakTimes(beat) = i + beatStart - 1;
end
return