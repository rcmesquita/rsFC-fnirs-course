function rvt = computeRVT(indpeak,dt,t,resp)
% Compute RVT (birn et al 2006)
%1. get min and max of a breath = range
%2. range / dt for that breath
%3. interpolate to all points
%
%INPUTS:
% indpeak = indices of peaks in the respiration signal
% dt = diff(t(indpeak))
% t = time in seconds
% resp = raw respiration signal
%
%OUTPUTS:
% rvt = respiration per volume time (see birn et al 2006)
%
%CALLS:  n/a
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
rvt1=zeros(1,length(indpeak)-1);
for breath=1:(length(indpeak)-1)
    % note I use the min from after the max... meaning the expriation after the inspiration
    breathRange = resp(indpeak(breath)) - min(resp(indpeak(breath):indpeak(breath+1)));
    rvt1(breath) = breathRange ./ dt(breath);
end
rvt=interp1(t(indpeak(1:end-1)),rvt1,t,'pchip');
return