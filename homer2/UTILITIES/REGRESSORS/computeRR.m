function [rr,dt,indpeak] = computeRR(resp,t,rangeRR,cleanTF)
% INPUTS:
% resp = respiration signal
% t = time
% rangeRR = [minimumRR maximumRR]
% cleanTF = 1 for filtering data
%           0 for omitting the filter step
%             if this option is used, a simpler
%             peak finding algorithm will be used
%             so be sure you mean to use this
% 
% OUTPUTS:
% rr = respiration rate in BPM
% dt = difference in seconds between beats
% indpeak = index of beat peaks
%
% CALLS:
%   reg_peakfinder.m
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Fs = 1./diff(t(1:2));

maxRR = rangeRR(2);
minRR = rangeRR(1);

mf = floor(Fs*60/maxRR);

if cleanTF == 1
    % simple form of low pass filtering...
    resp2 = medfilt1(resp,mf);
    % remove any linear trend
    resp2 = detrend(resp2);
    
    % Now find peaks on the cleaned signal
    [indpeak twfPer] = reg_peakfinder(resp2);
    % if there are repeated peaks, remove them
    f=find(diff(indpeak)==0);
    if ~isempty(f)
        indpeak = indpeak([find(diff(indpeak)>0) length(indpeak)]);
    end
    % Now make any fine adjustments based on the real signal
    for i=1:length(indpeak)
        lowerR = max(1,indpeak(i) - mf);
        upperR = min(length(resp),indpeak(i)+mf);
        [maxS,indS] = max(resp(lowerR:upperR));
        indpeak(i) = lowerR + indS - 1;
    end

else
    %% run a simplified "peak find" which looks for the flat
    % tops of signals (typically from retroicor resp) and
    % picks the midpoint of them - however peaks must not be
    % at the height of the baseline
    d_resp = [0; diff(resp)];
    indpeak =[];
    going_up=0; going_down=0;
    up_summit = 0;
    baseline_amp = median(resp);
    for W=1:length(resp)
        if going_up==0 && d_resp(W)>0
            going_up = 1;
        end
        if going_up==1
            if d_resp(W)==0
                if resp(W)>baseline_amp,    up_summit=W;    end;
                going_up=0;
            elseif d_resp(W)<0
                if resp(W-1)>baseline_amp,  up_summit=W-1;  end;
                going_up=0;
            end
        end
        if going_down==0 && up_summit~=0 && d_resp(W)<0
            going_down=1;
            indpeak = [indpeak floor(mean([up_summit W]))];
            up_summit = 0;
        end
        if going_down==1 && d_resp(W)>=0
            going_down=0;
        end
    end
end


% if there are repeated peaks, remove them
f=find(diff(indpeak)==0);
if ~isempty(f)
    indpeak = indpeak([find(diff(indpeak)>0) length(indpeak)]);
end

% convert to RR
if length(indpeak)>2
    dt = diff(t(indpeak));
    rr_base = 60./dt;
    rr = 0*t;
    newrange = indpeak(2):indpeak(end);
    rr(newrange) = interp1(t(indpeak(2:end)),rr_base,t(newrange),'pchip');
else
    disp('ERROR! Peakfinder failing...');
    dt = [];
    rr = [];
    return
end

% fix endpoints
rr(1:indpeak(2)) = rr(indpeak(2));
rr(indpeak(end):end) = rr(indpeak(end));

% clean out any negative or crazy-high values
f = find(rr<minRR);
if ~isempty(f)
    rr(f) = minRR;
end
f = find(rr>maxRR);
if ~isempty(f)
    rr(f) = maxRR;
end
return