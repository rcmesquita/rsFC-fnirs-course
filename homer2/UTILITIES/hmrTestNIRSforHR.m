function [goodHR,goodHRpairs,suspectHR,HR]=hmrTestNIRSforHR(nirs,t,SD,pulseox,drawTF)
% [goodHR,goodHRpairs,suspectHR,HR] = hmrTestNIRSforHR(nirs,t(1:2),SD,pulseox,drawTF)
%
% given the data (nirs = data x channel), the time axis (t = data x 1), the SD data structure for
% channel arrangements (SD), and the pulseox measurement (pulseox = data x 1), I can
% compute which sources and which detectors are "good" based on the HR
% criteria, which simply stated is that optodes that result in at least one
% optical signal that contains the most power in the same frequency range
% as the pulseox are "good".
% If drawTF is included, then ==1 will draw and ==0 will not draw
%
%INPUTS:
%   nirs    - data x channel raw nirs signals
%   t       - time vector in seconds
%   SD      - SD data structure
%   pulseox - vector of pulseox data
%   drawTF  - 1 if you want an image drawn, 0 if not
%
%OUTPUTS:
%   goodHR  - the vector of channels that are "good" by HR criteria (0 or
%               1, where 1 is good)
%   goodHRpairs - same as goodHR, but pairs of corresponding channels must
%                be good (oxy and deoxy)
%   suspectHR- the vector of suspected frequency of HR in each NIRS channel
%   HR      - the HR found from the pulseox
%CALLS:
%   drawProbeGood
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5

% CONSTANTS FOR THIS FUNCTION
% reasonable HR values for health people at rest is 60-100
% add in some unhealthy people, and you can go to maybe 50-120 or so
% Then just add some tolerance around that, and you get these constants
minHR = 40; % the lowest reasonable HR in BPM (actually this is very unreasonable)
maxHR = 160; % the highest reasonable HR in BPM (actually this is very unreasonable)
toleranceHR = 6; % this means that a HR plus or minus this number is essentially the same

if ~exist('drawTF') || isempty(drawTF)
    drawTF=1;
end

% Step 1: Set up some variables
minFr = minHR / 60; 
maxFr = maxHR / 60;
numPairs = size(nirs,2);

fs = 1./(t(2)-t(1)); % the sampling frequency in Hz

% Step 2: take a mega FFT for everything
x = [pulseox nirs];
N = length(pulseox);
Y = fft(x,N);

Pyy = Y.*conj(Y) / N;
f = fs*(0:(N/2)) / N;
Pyy = Pyy(1:(1+floor(N/2)),:);

inds = find(f >= minFr & f <= maxFr);
relevantFFT = Pyy(inds,:);


% Step 3: Determine the HR frequency
[m,i]=max(relevantFFT(:,1));
fHR = f(inds(i));
HR = fHR * 60;
% Step 4: Determine the suspected HR frequency in each source-detector
% pair
suspectHR = zeros(1,numPairs);
for pairCount=1:numPairs
    [m,i]=max(relevantFFT(:,1+pairCount));
    fHR = f(inds(i));
    suspectHR(pairCount) = fHR * 60;
end

% Step 5: Test each pair for a possible close match
% To do that, you need to have a HR within tolerance of the real HR, 
goodHR = (suspectHR < (HR+toleranceHR)) & (suspectHR > (HR-toleranceHR));
numHalfPairs = numPairs/2;
temp = goodHR(1:numHalfPairs) & goodHR((numHalfPairs+1):end);
goodHRpairs = [temp temp];

if drawTF==1
    subplot(2,1,1)
    drawProbeGood(SD,goodHR);
    txt = sprintf('Pulseox HR = %0.0f green is +/- %0.0f',HR,toleranceHR);
    title(['INDIVIDUAL: ' txt]);
    subplot(2,1,2);
    drawProbeGood(SD,goodHRpairs);
    title(['PAIRS: ' txt]);
end

return