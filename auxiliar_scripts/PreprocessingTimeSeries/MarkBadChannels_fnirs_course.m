function[BadChannels] = MarkBadChannels_fnirs_course(d,SD,SNR_threshold)
% Find channels with a low signal-to-noise ratio based on average and
% and amplitude of the signals. This procedure is not good for
% short-channels because they can have a high amplitude withou heart rate.
% This function does not change the orginal data (i.e., d and SD);
% It only returns a list of bad channels that can be used for further
% analysis.
%
% INPUT:
%    d  - Raw light intensity measurements.
%    SD - Structure common in Homer.
%
% OUTPUT:
%   BadChannels - List with low SNR channels

% Threshold for deciding between bad and good channels
SNR_threshold = 8;

% Remove long drifts from the data that can be misleading when computing
% the quality of the channel
Baseline = mean(d);
d = detrend(d)+Baseline;

SD = enPruneChannels(d,SD,ones(size(d,1),1),...
    [-10 10^7],SNR_threshold,[0 100],0);

BadChannels = find(SD.MeasListActAuto==0);


end