function[dc_pca] = Perform_pca_regression_fnirs_course...
    (dc,SD,nSV,BadChannels)

% Perform PCA regression to remove systemic physiology
%
% INPUT:
%   dc - Hemoglobin concentration changes.
%   SD - standard fNIRS SD structure.
%   nSV - Number of components to be removed.
%   BadChannels - List of channels with low SNR.


% List of Short Channels
SSlist = [8 29 52 66 75 92 112 125];

% Exclude channels from Correlation Matrix
exclude_channels = unique([SSlist,BadChannels']);

% Create MeasListAct
SD.MeasListAct = ones(size(dc,2),1);

% Remove from MeasListAct the entries for the short channels and bad
% channels
SD.MeasListAct(exclude_channels) = 0;

% Perform PCA considering the whole time-series
tInc = ones(size(dc,1),1);

% Perform PCA
% Permute dc to match dimension requirements from enPCAFilter
dc = permute(dc,[1 3 2]);

[dc_pca, svs, nSV] = enPCAFilter(dc, SD, tInc, nSV);

% Permute dc back to original
dc_pca = permute(dc_pca,[1 3 2]);

end

