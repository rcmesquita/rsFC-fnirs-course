function addRegressors( fni, fno ,cardCh,respCh )
% addRegressors(fni,fno,cardCh,respCh)
%
% This function will add regressors for use with GLM based on the
% respiration and cardiac signals.
%
%INPUTS:
% fni = filename used as an input NIRS files
% fno = filename used as an output NIRS file
% cardCh = cardiac aux channel number (pulseox assumed)
% respCh = respiration aux channel number
%
%OUTPUTS:
% none
%
%CALLS:
%  addRegressors_retroicor,addRegressors_HR,
%  addRegressors_RR,addRegressors_nearSD,
%  peakfinder, getSpikes, pruneBeats, NORMALIZEfilter, 
%  findpeaks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% All options are here
% the maximum distance between source and detector that would
% still be considered close-separation source-detector pairs
closeSepDist = 1.2;

%% Load the file
X = load(fni,'-mat');
Fs = 1./diff(X.t(1:2));

%% Initially, add the cardiac and respiration aux channels, unaltered
regressors = X.aux(:,[cardCh respCh]);
regressorNames = {'pulseox','respiration'};

%% Add close separation channels (if available)
[closeSep,srcs,dets,closeInds] = addRegressors_nearSD(X.SD,d,maxDist);
regressors = [regressors closeSep];
for p=1:size(srcs)
    thisName = {['closeSD' num2str(closeInds(p)) '_' ...
        num2str(srcs(p)) '_' num2str(dets(p))]};
    regressorNames = [regressorNames thisName];
end

%% Add retroicor
Xc = addRegressors_retroicor(X.t,X.aux(:,cardCh,'card'));
Xr = addRegressors_retroicor(X.t,X.aux(:,respCh,'resp'));
regressors = [regressors Xc Xr];
m = size(Xc,2);
regressorNames = [regressorNames repmat({'cardiacRetroICOR'},1,m)];
m = size(Xr,2);
regressorNames = [regressorNames repmat({'respirationRetroICOR'},1,m)];

%% Add HR,cardEnv
[simpleHR,peakBeats,cardEnv] = addRegressors_HR(X.t,X.aux(:,cardCh),'pulseox');
regressors = [regressors simpleHR cardEnv];
regressorNames = [regressorNames {'HR'} {'cardEnvHi'} ...
    {'cardEnvLo'}];

%% Add RR, RVT, RRF
[simpleRR,indpeaks,RVT,RRF]=addRegressors_RR(X.t,X.aux(:,respCh));
regressors = [regressors simpleRR RVT RRF];
regressorNames = [regressorNames {'RR'} {'RVT'} {'RRF'}];

%% save the file
X.regressors = regressors;
X.regressorNames = regressorNames;
eval(['save ' fno ' -struct X']);

return
