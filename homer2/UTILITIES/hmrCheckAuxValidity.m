function hmrCheckAuxValidity(fname,poxChan,respChan,bpChan,ttlChan)
%hmrCheckAuxValidity(fname,poxChan,respChan,bpChan,ttlChan);
%
% This function will plot out basic info about each of these types of aux
% channels so that one can quickly assess the channels for validity. The
% function will also output to the screen a quick summary about heart rate
% respiratory rate and TTL signals.
%
%INPUTS:
% fname = file name of .nirs file. If empty, entire directory will be run.
% poxChan = aux channel number of the pulseox (empty if not used)
% respChan = aux channel number of the respiration channel (empty if not
%   used)
% bpChan = aux channel number of the BP channel (empty if not used)
% ttlChan = aux channel number of any TTL signal (empty if not used)
%
%OUTPUTS:
%  n/a
%
%CALLS:
%  addRegressors_HR.m,addRegressors_RR.m,getTTLtimes.m,addRegressors_retroicor.m
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~exist('fname','var')
    help hmrCheckAuxValidity
    return
end
if isempty(fname)
    d = dir('*.nirs');
    for xx=1:length(d)
        fname = d(xx).name;
        figure
        disp(['Fig ' num2str(xx) ': Now opening ' fname '...']);
        hmrCheckAuxValidity(fname,poxChan,respChan,bpChan,ttlChan);
    end
    return
end
%% Read in nirs file
X = load(fname,'-mat');
t = X.t;
aux = X.aux;
Fs = 1./diff(t(1:2));

maxRows = (~isempty(poxChan))*2 + (~isempty(bpChan)) + (~isempty(respChan))*2 + (~isempty(ttlChan));
plotCounter = 1;
%% PULSEOX
if ~isempty(poxChan)
    card = aux(:,poxChan);
    [simpleHR,peakBeats,cardEnv] = addRegressors_HR(t,card);
    subplot(maxRows,2,plotCounter)
    plot(t,card,t(peakBeats),card(peakBeats),'*',t,cardEnv(:,1),':',t,cardEnv(:,2),':');
    title('Pulseox (volts vs secs)');
    subplot(maxRows,2,plotCounter+1);
    plot(t,simpleHR,'b');
    ylim([0 150])
    title('HR (volts vs secs)');
    fprintf('Heartrate:'); 
    showRange(simpleHR,50,130);
    % retroicor
        [X,phik] = addRegressors_retroicor(t,card,'card');
    [hr2,dummy,indpeak2] = computeRR(phik,t,[50 130],0);
    subplot(maxRows,2,plotCounter+2)
    plot(t,phik,'r',t(indpeak2),phik(indpeak2),'k*');
    title('RETROICOR Phi (radians vs secs)');
    if ~isempty(hr2)
        subplot(maxRows,2,plotCounter+1)
        hold on
        plot(t,hr2,'r')
        hold off
        Title('HR raw - blue , HR retroicor - red');
    end
    subplot(maxRows,2,plotCounter+3)
        doFFT('FFT of CARDIAC (pwr vs Hz)',card,Fs)
        
    plotCounter = plotCounter + 4;
end
if ~isempty(respChan)
    resp = aux(:,respChan);
    [rr,indpeak] = addRegressors_RR(t,resp);
    subplot(maxRows,2,plotCounter);
    plot(t,resp)
    title('Respiration (volts vs. secs)')
    if isempty(rr)
        fprintf('NO RESPIRATION RATE FOUND.\n');
    else
        hold on
        plot(t(indpeak),resp(indpeak),'r*');
        hold off
        fprintf('Respiration rate:');
        showRange(rr,12,25);
        subplot(maxRows,2,plotCounter+1);
        plot(t,rr,'b');
        title('RR (volts vs secs)');
    end
    [X,phik] = addRegressors_retroicor(t,resp,'resp');
    [rr2,dummy,indpeak2] = computeRR(phik,t,[0 45],0);
    subplot(maxRows,2,plotCounter+2)
    plot(t,phik,'r',t(indpeak2),phik(indpeak2),'k*');
    title('RETROICOR Phi - (radians vs secs)');
    if ~isempty(rr)
        subplot(maxRows,2,plotCounter+1)
        hold on
        plot(t,rr2,'r')
        hold off
        title('RR: raw - blue ,retroicor - red (radians vs secs)');
    end
    subplot(maxRows,2,plotCounter+3)
        doFFT('FFT of RESP (pwr vs Hz)',resp,Fs)
    plotCounter = plotCounter + 4;
end

if ~isempty(bpChan)
    subplot(maxRows,2,plotCounter)
    plot(t,aux(:,bpChan));
    title('BP (volts vs secs)');
    subplot(maxRows,2,plotCounter+1)
    doFFT('FFT of BP (pwr vs Hz)',aux(:,bpChan),Fs);
    plotCounter = plotCounter + 2;
end
if ~isempty(ttlChan)
    ttl = aux(:,ttlChan);
    ttlInds = getTTLtimes(ttl);
    fprintf('Number of TTLs found: %d. ',length(ttlInds));
    dt = diff(t(ttlInds));
    fprintf('dT: %0.2f - %0.2f (mean=%0.2f)\n',min(dt),max(dt),mean(dt));
    subplot(maxRows,2,plotCounter)
    plot(t,ttl,t(ttlInds),ttl(ttlInds),'*');
    title('TTL (volts vs secs)')
    subplot(maxRows,2,plotCounter+1)
    plot(t(ttlInds(1:end-1)),dt,'x-');
    title('dT of TTL (1/secs vs secs)')
end

return

function showRange(theR,minSafeR,maxSafeR)
    f=find(theR<minSafeR | theR>maxSafeR);
    if isempty(f)
        fprintf(' ALL NORMAL. ');
    else
        fprintf(' %d/%d (%0.0f%%) ABNORMAL. ',length(f),length(theR),...
            100*length(f)/length(theR));
    end
    fprintf('%0.1f - %0.1f (mean=%0.1f)\n',min(theR),max(theR),mean(theR));
return

function doFFT(txt,x,Fs)
N = 2^12;
Y = fft(detrend(x),N);
Pyy = Y.*conj(Y) / N;
f = Fs*(0:(N/2)) / N;
P = Pyy(1:(1+(N/2)) );
plot(f,P);
title(txt);
ylabel('power');
return