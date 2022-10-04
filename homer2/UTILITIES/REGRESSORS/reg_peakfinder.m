function [indpeak twfPer] = reg_peakfinder(twf)
% [indpeak twfPer] = reg_peakfinder(twf)
%
% Finds local peaks in a near-periodic waveform. This fails if the
% peaks are closer than 1/2 period. twfPer is the period of twf in
% samples. If the 1st or last peak are less than 90% of the mean of
% the rest of the peaks, they are exluded.
%
% $Id: reg_peakfinder.m,v 1.1 2009-03-02 22:50:49 daniel Exp $

indpeak = [];

if(nargin ~= 1)
  fprintf('indpeak = peakfinder(twf)\n');
  return;
end

Ntp = length(twf);

% Get major period of waveform
TR = 1;
nn = 0:round(Ntp/2);
freqmax = (1/TR)/2;         % Nyquist
deltafreq = freqmax/(Ntp/2); % Measured from 0 to Nyquist
fftaxis = deltafreq*nn;

nfft = Ntp/2 + 1;
nnfft = 1:nfft;
twffft = abs(fft(twf-mean(twf)));
[tmp k] = max(twffft);
twfFreq = fftaxis(k);
twfPer = 1/twfFreq;
twfPerSamp      = round(twfPer);
twfHalfPerSamp  = round(twfPerSamp/2);
twfQuartPerSamp = round(twfPerSamp/4);

% Assume global peak is a local peak
[tmp k0] = max(twf);

% Look ahead, starting at global peak
indpeak = k0;
kprev = k0;
while(1)
  % Find next max by searhing over time starting at 1/2
  % period beyond the previous max and ending one period
  % later. This fails if the peaks are closer than 1/2
  % period.
  kstart = kprev + twfHalfPerSamp;
  k = kstart + [0:twfPerSamp-1];
  indok = find(k < Ntp);
  if(length(indok) < twfQuartPerSamp) break; end
  k = k(indok);
  [tmp mmax] = max(twf(k));
  kmax = kstart + mmax - 1;
  indpeak = [indpeak kmax];
  kprev = kmax;
end

% Look behind (reverse and look ahead)
twfrev = flipud(twf(:));
[tmp k0rev] = max(twfrev);
indpeakrev = []; % dont include k0rev here
kprev = k0rev;
while(1)
  kstart = kprev + twfHalfPerSamp;
  k = kstart + [0:twfPerSamp-1];
  indok = find(k < Ntp);
  if(length(indok) < twfQuartPerSamp) break; end
  k = k(indok);
  [tmp mmax] = max(twfrev(k));
  kmax = kstart + mmax - 1;
  indpeakrev = [indpeakrev kmax];
  kprev = kmax;
end

% Convert reversed indices to forard indices
indpeakrevfor = Ntp - indpeakrev + 1;
indpeak = sort([indpeak indpeakrevfor]);

% Decide whether to eliminate the first and/or last peak
peakfirst = twf(indpeak(1));
peaklast  = twf(indpeak(end));
peakmean = mean(twf(indpeak(2:end-1)));
if(peakfirst < .9*peakmean)  indpeak = indpeak(2:end); end
if(peaklast < .9*peakmean)   indpeak = indpeak(1:end-1); end

return;
