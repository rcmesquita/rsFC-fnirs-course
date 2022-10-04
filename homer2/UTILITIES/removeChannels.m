% function [mlact r] = removeChannels(d,t,SD,fCard,threshCard,fNoise,threshNoise)
%
% This function will remove channels based on cardiac peak and noise floor.
% Either criteria must be met for all wavelengths for a given source detector pair.
%
% INPUTS
% d - intensity data (#time points x #channels)
% t - time vector (#time points x 1)
% SD - the SD structure
% fCard - frequency window containing cardiac peak [fmin fmax].
%         It is important that this window be large but the peak must be
%         the cardiac peak.
% threshCard - A number??? below which he channel is rejected.
% fNoise - frqeuency window for estimating the noise floor.
% threshNoise - ???
%
% OUTPUTS
% mlact - the active measurement list contains a 1 for an active channel
%         and a 0 for a channel that did not pass the criteria. (#Measurements x 1)
% r - ???
%
% DEPENDENCIES
% None
%
% TO DO
% This presently assumes that MeasList is ordered by first wavelength and
% then second. Handle SD.
% generalize to N wavelengths (don't assume N=2)


function [mlact r] = removeChannels(d,t,SD,fCard,threshCard,fNoise,threshNoise)

% frequency window where to look for heartbeat
%fwin = [100/60 250/60];
%fwnoise = [200/60 240/60];
% treshold for r, remove channels with lower r
%rtr = 4.0; % Treshold for heartbeat detection
%rtn = 0.15; % Treshold for noise detection

nCh = 8; %number of channels per wavelength


fs = 1/(t(2)-t(1));

np = 2^(nextpow2(size(d(1:end,:),1))-1);
fftdat = abs(fft(d(1:end,:),np));

f = fs/2 * linspace(0,1,np/2);

fistart = find(f > fCard(1), 1);
fistop = find(f > fCard(2), 1);

fnstart = find(f > fNoise(1), 1);
fnstop = find(f > fNoise(2), 1);

% calculate first score ra
mns = mean(fftdat(fistart:fistop,:));
%[maxs maxidx] = max(fftdat(fistart:fistop,:));
[fftsort fftsidx] = sort(fftdat(fistart:fistop,:),'descend');
%maxs = (mean((fftsort(1:3,:)-ones(3,size(fftsort,2))*diag(mns)))).^0.5;
maxs = mean(fftsort(1:3,:));
stds = std(fftdat(fistart:fistop,:));
ra = (maxs-mns)./stds;

% fix to remove channels with clippling
ra = ra .* (fftsort(1,:)<8);

maxidx = fftsidx(1:3,:) + fistart -1;
stdidx = std(reshape(fftsidx,[],1));
%mnidx = mean(mean(maxidx));
tmp = mean(maxidx);
mnidx = ra(1:nCh)*tmp(1:nCh)'/sum(ra(1:nCh));   % SPECIFIES ONE WAVELENGTH
mnidxdev = mean(abs(fftsidx(1:3,:) + fistart -1 - mnidx));

%maxidx = maxidx + fistart -1;
rb = 0.5 * mnidxdev./stdidx;

mnsn = mean(fftdat(fnstart:fnstop,:));
stdn = std(fftdat(fnstart:fnstop,:));


r = ra-rb;
%ch = find(r < threshCard);
mlact = (mnsn<threshNoise | r >= threshCard);
% mlact(1:nCh) =(r(1:nCh) >= threshCard);
% mlact(nCh+1:2*nCh) = (stdn(nCh+1:2*nCh)<threshNoise | r(nCh+1:2*nCh) >= threshCard2);

% make sure both wavelength of one SD pair are deactivated
% THIS ASSUMES THAT MeasList IS ORDERED BY FIRST THEN SECOND WAVELENGTH
nSD = length(mlact)/2;
mlact(1:nSD) = mlact(1:nSD) & mlact(nSD+1:end);
mlact(nSD+1:end) = mlact(1:nSD) & mlact(nSD+1:end);

fig = figure;

for idx=1:size(fftdat,2)
    subplot(4,4,idx);
    if mlact(idx) == 1
        plot(f(fistart:fistop),fftdat(fistart:fistop,idx),f(maxidx(:,idx)),fftdat(maxidx(:,idx),idx),'o');
    else
        plot(f(fistart:fistop),fftdat(fistart:fistop,idx),'r',f(maxidx(:,idx)),fftdat(maxidx(:,idx),idx),'o');
    end
    set(gca,'XLim',fCard);
    if ~isnan(mnidx)
        line([f(round(mnidx)) f(round(mnidx))],get(gca,'YLim'));
        title(['r=' num2str(r(idx),2) ' mn=' num2str(mnsn(idx),2)]);
    end
%     if idx <= nCh
%         title(['r=' num2str(r(idx),2) ' ra=' num2str(ra(idx),2) ' rb=' num2str(rb(idx),2)]);
%     else
%         title(['r=' num2str(r(idx),2) ' st=' num2str(stdn(idx),2) ' mn=' num2str(mnsn(idx),2)]);
%     end
end

% if isempty(ch)
%     plot(f,fftdat(1:(np/2),:));
% elseif isempty(mlact)
%     plot(f,fftdat(1:(np/2),:),'--');
% else
%     plot(f,fftdat(1:(np/2),mlact),f,fftdat(1:(np/2),ch),'--','LineWidth',2);
% end
% set(gca,'YScale','log');
