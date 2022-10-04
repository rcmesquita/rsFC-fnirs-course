function inds = getTTLtimes(sig)
% given a signal that has TTL-like rising edges
% obtain a set of indices for when this happens.
%
% The assumption is that there are low values and high
% values, and halfway between them is the threshold for
% rising edges. If you have very noisy data, or non-TTL
% data, this clearly will fail.
%

[counts,xout] = hist(sig,9);
cutoff = xout(4);

sig1 = sig>cutoff;
inds = find(diff([0; sig1])>0);

return