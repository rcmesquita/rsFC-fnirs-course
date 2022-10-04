function [est,indpeak,rr] = hmrBuildRetroicorEstimate(t,sig,kindof)
%
%INPUTS
% t = time in seconds
% sig = pulseox or respiration signal
% kindof = 'card' - pulseox
%          'resp' - respiration
%
%OUTPUTS
% est = estimated signal after using retroicor
%
%REQUIRED FUNCTIONS
% addRegressors_retroicor.m
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

X = addRegressors_retroicor(t,sig,kindof);
b = glmfit(X,sig,'normal');
est = glmval(b, X,'identity');

return
