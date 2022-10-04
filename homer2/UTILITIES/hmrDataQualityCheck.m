function [chanList detailedInfo]=hmrDataQualityCheck(filenm,modeFlags,dBrange,...
    sdDistRange,snrMax,tRange,poxChan)
% chanList = hmrDataQualityCheck(filenm,modeFlags,dBrange,sdDistRange,snrMax,tRange)
%   OR
% chanList = hmrDataQualityCheck
%   OR
% [chanList,detailedInfo] = hmrDataQualityCheck(filenm,modeFlags,dBrange,sdDistRange,snrMax,tRange)
%   OR
% chanList = hmrDataQualityCheck(filenm,modeFlags,dbRange,sdDistRange,snrMax,tRange,poxChannel) 
%   OR
% [chanList,detailedInfo] = hmrDataQualityCheck(filenm,modeFlags,dbRange,sdDistRange,snrMax,tRange,poxChannel) 
%
% This function will prune away any channels that do not satisfy a number
% of requirements.
%    1. dBrange - the power of the raw data on the channel must be within
%                 a range.
%    2. snrMax - the maximum SNR is below a value.
%    3. sdRange - the distance between source and detector must be within
%                 a range.
%    4. HbMatch - corresponding oxy and deoxy channels are pruned if the
%                corresponding channel is bad.
%    5. cardiacPeak - (optional) a cardiac peak must be present on good channels
%
%INPUTS:
% IF YOU CALL THIS COMMAND WITH NO INPUT ARGUEMENTS, EVERYTHING WILL 
% REVERT TO DEFAULT. THE WHOLE DIRECTORY WILL BE READ.
%
% filenm - either a filename to test
%       default (if empty string): entire directory
% modeFlags - [dBrangeTF snrMaxTF sdRangeTF HbMatchTF cardiacPeakMODE motionTF]
%       default (if empty array): [1 1 1 1 0 0]
%     dBrangeTF = use dB range? (0 or 1)
%     snrMaxTF = use SNR max? (0 or 1)
%     sdRangeTF = use source-detector range? (0 or 1)
%     HbMatchTF = use only pairs of oxy/deoxy that are both good? (0 or 1)
%     cardiacPeakMODE = use only channels with cardiac peak?
%               0 - no
%               1 - if no poxChan is provided, use the removeChannels script,
%                based on sorted FFT method. If poxChan is given, then
%                use the hmrTestNIRSforHR script, based on peak FFT method 
%     motionTF = obtain motion artifact data (must use 1 file, not
%                directory)
% dBrange - the min and max allowable dB value for a raw signal
%       default (if empty array): [80 125]
% sdDistRange - the min and max allowable separation between
%       source and detector. Use 0 and/or inf as needed to unbound one side.
%       default (if empty array): [0 3.5]
% snrMax - the maximum value permitted for snr = std.dev.(d)/mean(d)
%       default (if empty array): 5
% tRange - range of values to examine for artifacts (must set motionTF 1)
% poxChan - the aux channel number for pulseox
%
%OUTPUTS:
% chanList - a set of channels indices that correspond to d from the nirs
%   files which remain after the pruning.
% detailedInfo - if you only test 1 file, this optional output will give
%   you more detail about why channels were pruned
%
% CALLS:
% hmrPruneChannels.m, removeStimuli.m, removeChannels.m, drawProbeGood.m
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~exist('filenm'),        filenm='';      end;
if ~exist('modeFlags'),     modeFlags=[];   end;
if ~exist('dBrange'),       dBrange=[];     end;
if ~exist('sdDistRange'),   sdDistRange=[]; end;
if ~exist('snrMax'),        snrMax=[];      end;
if ~exist('tRange'),        tRange=[];      end;
if ~exist('poxChan'),       poxChan=[];     end;
runFULLdirectory=0;

%% ESTABLISH DEFAULTS
if isempty(filenm),         runFULLdirectory=1;     end;
if isempty(modeFlags),      modeFlags=[1 1 1 1 0 0]; end;
if isempty(dBrange),        dBrange=[80 125];       end;
if isempty(sdDistRange),    sdDistRange=[0 3.5];    end;
if isempty(snrMax),         snrMax=5;               end;
if (modeFlags(1)==0),       dBrange = [-inf inf];   end;
if (modeFlags(2)==0),       snrMax= inf;            end;
if (modeFlags(3)==0),       sdDistRange=[0 inf];    end;

detailedInfo = struct;

%% Compute allchans and min,max,median stats
if runFULLdirectory==1
    d=dir('*.nirs');
    dm = length(d);
else
    dm = 1;
end
for i=1:dm
    if runFULLdirectory==1
        fn=d(i).name;
    else
        fn = filenm;
    end
    disp(fn);
    X = load(fn,'-mat');
    
    if sum(size(X.SD.MeasList)==size(X.ml))<2
        X.SD.MeasList = X.ml;
    end
    chans = hmrPruneChannels(X.d,X.SD,sdDistRange,0,dBrange,snrMax);
    fprintf('%d ',chans); fprintf('\n');
    if i==1
        allchans = chans;
        minD = min(X.d);
        maxD = max(X.d);
        medianD = median(X.d);
    else
        allchans = intersect(allchans,chans);
        minD = [minD; min(X.d)];
        maxD = [maxD; max(X.d)];
        medianD = [medianD; median(X.d)];
    end
end
if dm>1
   minD = min(minD);
   maxD = max(maxD);
   medianD = mean(medianD);
end
minD = 20*log10(minD);
maxD = 20*log10(maxD);
medianD = 20*log10(medianD);

%% If needed, remove non cardiac artifact containing channels
if modeFlags(5)==1
    if isempty(poxChan)
        % if no pulseox channel is given, use the Bernhard method
        % which uses sorted FFT to pick channels
        [chinv cardiacR] = removeChannels(X.d,X.t);
        detailedInfo.cardiacR=cardiacR;
        goodHRchans = find(chinv);
    else
        % if a pulseox channel is given, use the Daniel method
        % which matches peak FFT values between channels and pulseox
        [goodHR,goodHRpairs,suspectHR,HR] = hmrTestNIRSforHR(X.d,X.t(1:2),X.SD,X.aux(:,poxChan),0);
        goodHRchans = find(goodHR);
    end
    allchans = intersect(allchans,goodHRchans);
    detailedInfo.cardiacGoodChans = goodHRchans;
end

%% additional calculations
sd = size(X.d,2);
sd2 = sd/2;
chansTFeach = zeros(1,size(X.d,2));
chansTFeach(allchans) = 1;
temp = chansTFeach(1:sd2) & chansTFeach((sd2+1):end);
chansTFall = [temp temp];
list690 = getNirsList(X.SD,X.ml,690);
list830 = getNirsList(X.SD,X.ml,830);
try
    gains = X.systemInfo.gain;
catch
    gains = zeros(1,200);
end
m = length(list690);

%% motion artifacts
if modeFlags(6)==1 && exist('s') && runFULLdirectory==0
    if isempty(tRange)
        tRange = [X.t(1) X.t(end)];
    end
    [s p TPAct] = removeStimuli(X.d,X.s,X.t,tRange);
    % s is the new variable s for this run
    % p is the percentage remaining
    % TPAct is a vector of 0,1 with 0=artifact
    detailedInfo.newS = s;
    detailedInfo.percent = p;
    detailedInfo.TPAct = TPAct;
end

%% Require channels to match or not?
if modeFlags(4)==0
    chanList = allchans;
else
    chanList = find(chansTFall);
end

%% Text output
fprintf('Individual good channels:\n');
fprintf('%d ',allchans); fprintf('\n');
fprintf('Sets of good...\n');
fprintf('%d ',find(chansTFall)); fprintf('\n');
fprintf('Halfset...\n');
fprintf('%d ',find(temp)); fprintf('\n');

%% Plots
clf
%Median min max plot
subplot(3,2,1);
hold on
for a=1:m
    plot((a)*[1 1],[minD(list690(a)) maxD(list690(a))],'b');
    plot((a),medianD(list690(a)),['xb']);
    plot((a)*[1 1],[minD(list830(a)) maxD(list830(a))],'r');
    plot((a),medianD(list830(a)),'xr');
end
plot([1 m],dBrange(1)*[1 1],'-k');
xlim([1 m]);
hold off
title('Median,min,max')
xlabel('Detector number');
%Gains plot
subplot(3,2,3);
bar(gains(X.ml(list690,2)));
xlim([1 m]);
title('Gains')
xlabel('Detector #')
%Source-detector plot
subplot(3,2,5);
plot(1:m,X.ml(list690,1),'xr', 1:m,X.ml(list690,2),'ok');
title('Source detector pairs')
xlabel('x=source o=detector');
xlim([1 m])
%Each channel at a time plot
subplot(2,2,2);
drawProbeGood(X.SD,chansTFeach);
title('Looking at 690 and 830 one at a time...')
%Corresponding channel plot
subplot(2,2,4);
drawProbeGood(X.SD,chansTFall);
title('Good if both oxy/deoxy are good...')

return



function thelist = getNirsList(SD,ml,freq)
% will tell you which channels are in that frequency
theInd = find(SD.Lambda == freq);
thelist = find(ml(:,4) == theInd);
return
