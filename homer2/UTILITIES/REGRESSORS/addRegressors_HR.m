function [simpleHR,peakBeats,cardEnv,cvt] = addRegressors_HR(t,card,cardFlag,HRrange)
% [simpleHR,peakBeats] = addRegressors_HR(t,card[,cardFlag[,HRrange]])
%   or
% [simpleHR,peakBeats,cardEnv] = addRegressors_HR(t,card[,cardFlag[,maxHR]])
%   or
% [simpleHR,peakBeats,cardEnv,CVT] = addRegressors_HR(t,card[,cardFlag[,maxHR]])
%
% Given cardiac data, we get heart rate as a
% function of time. It also will output the indices of when
% heatbeats occured.
%
%INPUTS
% t = time in seconds
% card = the cardiac signal (from pulseox or other)
% cardFlag = (optional) the type of cardiac signal to process
%     options are:
%     'pulseox' - pulse oximeter data
%     'TTL' - TTL from pulseox (no waveforms), 
%   ** If cardFlag is not provided, 'pulseox' is assumed.
% HRrange = (optional) the slowest and fastest the heartrate can be
%   ** if not provided, [40 150] is the value
%
%OUTPUTS:
% simpleHR = the heartrate at each time point (interpolated)
% peakBeats = the indices of heart beat peaks
% [cardEnv] = data by 2 channel matrix of the cardiac envelope
%        computed based on peaks and troughs of the pulseox
%        signal if optionally included as an output when called
%      **NOTE: pulseox mode required.
% [CVT] = cardiac volume per time, similar to RVT (Birn et al 2006)
%        this is only calculated if included as an output when called
%      **NOTE: pulseox mode required
%
%
%
% In the future, we can add 'EKG' as an option.
%
%CALLS: getSpikes, pruneBeats, NORMALIZEfilter,
%    findpeaks, computeRVT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Fs = 1./diff(t(1:2));

if ~exist('cardFlag'),  cardFlag = [];          end;
if isempty(cardFlag),   cardFlag = 'pulseox';   end;
if ~exist('HRrange'),   HRrange = [];           end;
if isempty(HRrange),    HRrange = [40 150];     end;
    
cvt=[];
switch cardFlag
    case 'pulseox'
        pox = card;
        % Filter using an IIR butterworth filter to get the HR frequency band
        % make sure to avoid phase delay by using forward and reverse filtering
        band=[40 130]/60; % measured in Hz
        [b,a] = butter(8,band / (Fs/2)); % design a filter w/ 8 coefs, needs normalized band
        po = filtfilt(b,a,pox);
        po = NORMALIZEfilter(t,po,3);
        % Compute beat times
        [simpleHR,peakBeats] = genHR(t,po,pox,HRrange);
        if nargout>=3 && strcmp(cardFlag,'pulseox')==1
            % also compute cardiac envelope
            [cardEnv1,cardEnv2] = addCardEnv(pox,peakBeats,t);
            cardEnv = [cardEnv1 cardEnv2];
        end
        if nargout>=4 && strcmp(cardFlag,'pulseox')==1
            % also compute CVT (similar to RVT, Birn et al 2006)
            if length(peakBeats)>2
                dt = diff(t(peakBeats));
                cvt = computeRVT(peakBeats,dt,t,pox);
            end
        end
    case 'TTL'
        cardEnv = [];  % cardEnv has no meaning in TTL mode
        pox = card;
        % skip filtering
        threshp = pox > (mean(pox) + std(pox));
        posBeats = getSpikes(threshp);
        [peakBeats,beatStop] = pruneBeats(posBeats,detrend(pox));
        % skip findpeaks
        dt = 60./diff(t(peakBeats)');
        dt(find(dt>HRrange(2))) = HRrange(2);
        dt(find(dt<HRrange(1))) = HRrange(1);
        simpleHR = interp1(t(peakBeats(2:end)),dt,t,'pchip');
    otherwise
        disp('ERROR. Unknown cardFlag.');
        simpleHR = [];
        peakBeats = [];
end

return


function [hr,peakBeats] = genHR(t,po,pox,HRrange)
%simple threshold method - generate HR signal
threshp = po > (mean(po) + std(po));
posBeats = getSpikes(threshp);
[beatStart,beatStop] = pruneBeats(posBeats,po);
peakBeats = findpeaks(beatStart,beatStop,pox);
dt = 60./diff(t(peakBeats)');
dt(find(dt>HRrange(2))) = HRrange(2);
dt(find(dt<HRrange(1))) = HRrange(1);
hr = interp1(t(peakBeats(2:end)),dt,t,'pchip');
return


function [cardEnv1,cardEnv2] = addCardEnv(pox,peakBeats,t)
% given the pulseox signal and times of peak beats, return
% a signal that represents the interpolated envelope between
% the low and high peaks
lowBeats = [];
maxB = length(peakBeats);
for beat=1:(maxB-1)
   [m,i]=min(pox(peakBeats(beat):peakBeats(beat+1)));
   lowBeats(beat) = i+peakBeats(beat)-1;
end
[m,i]= min(pox(peakBeats(maxB):end));
lowBeats(maxB) = i+peakBeats(maxB)-1;
cardEnv1 = interp1(t(peakBeats),pox(peakBeats),t,'pchip');
cardEnv2 = interp1(t(lowBeats),pox(lowBeats),t,'pchip');
return;