function [rr,indpeak,rvt,rrf] = addRegressors_RR(t,resp)
%rr = addRegressors_RR(t,resp)
%[rr,indpeak] = addRegressors_RR(t,resp)
%[rr,indpeak,rvt] = addRegressors_RR(t,resp)
%[rr,indpeak,rvt,rrf] = addRegressors_RR(t,resp)
%
% Computes the respiration rate, RVT and RRF from a respiration
% signal and time. Depending on the number of outputs you write
% you will either compute all or part of these signals
%
%INPUTS:
% resp = the data by 1 array of respiration signal
% t = the time in seconds
%
%OUTPUTS:
% rr = respiration rate signal, interpolated to every timepoint
% rvt = respiration per volume time (birn et al 2006)
% rrf = respiration response function (birn et al 2007)
% indpeak = indices of peak breath times (used to compute RR)
%
%** NOTE: if you give only the first 2 output parameters, this runs faster
%
%CALLS:
%   reg_peakfinder.m,computeRR.m,computeRVT.m
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
minRR = 0;
maxRR = 45;
cleanTF = 1; % yes, filter the resp data first
[rr,dt,indpeak] = computeRR(resp,t,[minRR maxRR],cleanTF);

if (nargout>2)
    %% compute RVT (birn et al 2006)
    rvt = computeRVT(indpeak,dt,t,resp);
end
if (nargout>3)
    %% compute RRF (birn et al 2007)
    rrf = computeRRF(rvt,t);
end
return


%% RRF
function RRF = computeRRF(RVT,t)
% given RVT and t in seconds, the RRF is a simple computation (Birn et al
% 2007)
rrf1 = (0.6*t.^2.1).*exp(-t/1.6) - (0.0023*t.^3.54).*exp(-t/4.25);
RRF = conv(rrf1,RVT);
RRF = RRF(1:length(RVT));
return