function [X,phik] = addRegressors_retroicor(t,sig,mode)
% [X,phik] = addRegressors_retroicor(t,sig,mode)
% Basic retroicor, based on Glover et al 2000
%
%INPUTS:
% t = time in seconds
% sig = the 1D signal (respiration or cardiac) to estimate
%   4 regressors from
% mode = 'resp' = respiration signal
%        'card' = cardiac signal
%
%OUTPUTS:
% X = the four RETROICOR regressors (sin/cos and 1rs
%   harmonic
% phik = the value of phi_k which represents the phase in the cycle
%
%CALLS:
% reg_peakfinder.m,sg_getDeriv.m
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

M = 2; % second order only
nt = length(t);
phik = zeros(nt,1);

switch (mode)
    case 'resp'
        % step 1: normalize
        sig1 = sig - min(sig);
        R = sig1;
        Rmax = max(sig1);
        % step 2: compute the fancy phase
        [Hof_b,b] = hist(R,100);
        denom = sum(Hof_b);
        dR = sg_getDeriv(R); % a 25 point Savitzsky-Golay quadratic fit-based derivative
        for ti=1:length(t)
            [minVal,minInd] = min(abs(R(ti) - b));
            sumN = minInd;
            numer = sum(Hof_b(1:sumN));
            phik(ti) = pi*(numer/denom)*sign(dR(ti));
        end
    case 'card'
        [indpeak twfPer] = reg_peakfinder(sig);
        tpeak = t(indpeak);
        npeaks = length(indpeak);
        % just obtain the phase of the cardiac cycle
        for nthpeak = 1:npeaks-1
            t1 = tpeak(nthpeak);
            t2 = tpeak(nthpeak+1);
            dt = t2-t1;
            k1 = indpeak(nthpeak);
            k2 = indpeak(nthpeak+1)-1; 
            tk = t(k1:k2)-t(k1);
            phik(k1:k2) = 2*pi*tk/dt;
        end
    otherwise
        error('You did not specify a mode for retroicor!');
end



X = zeros(nt,2*M);
for h = 1:M
    c = 1 + 2*(h-1);
    X(:,c) = cos(h*phik);
    s = 2 + 2*(h-1);
    X(:,s) = sin(h*phik);
end

return