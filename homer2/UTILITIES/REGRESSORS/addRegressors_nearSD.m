function [closeSep,srcs,dets,closeInds] = addRegressors_nearSD(SD,d,maxDist)
% [closeSep,srcs,dets,closeInds] = addRegressors_nearSD(SD,d,maxDist)
%
% given a probe, data by channel d and a distance, I return the channels
% that are close separation.
% For instance, if channel 2 and 3 corrispond to source 1 with 
%   detectors 6 and 8, and those pairs are closely separated, you
%   would expect srcs = [1 1], dets = [6 8], closeInds = [2 3]
%
%INPUTS:
% SD = probe geometry datastructure
% d = data x channel signals
% maxDist = max distance below which pairs are called near
%  source detectors
%
%OUTPUTS:
% closeSep = data by channel of close separation channels
% srcs = indices of the sources associated with a channel
% dets = indices of the detectors associated with a channel
% closeInds = indices of the channel number associated with the chosen
%    channels.
%
%CALLS: (none)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% check for valid distances
ml = SD.MeasList;
spos = SD.SrcPos;
dpos = SD.DetPos;
m2 = size(ml,1)/2; % number of channel pairs
sSet = spos(ml(:,1),1:2);
dSet = dpos(ml(:,2),1:2);
dists = sqrt((sSet(:,1)-dSet(:,1)).^2 + (sSet(:,2)-dSet(:,2)).^2);
closeInds = find(dists<maxDist);
closeSep = d(:,closeInds);
srcs = ml(closeInds,1);
dets = ml(closeInds,2);
return