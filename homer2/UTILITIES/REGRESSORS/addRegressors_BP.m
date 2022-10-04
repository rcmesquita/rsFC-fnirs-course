function [bp_low,bp_card,bp_resp,retroicor] = addRegressors_BP(t,bp)
%[bp_low,bp_card,bp_resp] = addRegressors_BP(t,bp)
%OR
%[bp_low,bp_card,bp_resp,retroicor] = addRegressors_BP(t,bp)
%
% Takes time and BP channel in, outputs regressors for the
% low frequency components of BP, the cardiac range component
% and the respiratory component. If you specify, you can also get
% all 8 components of retroicor from the cardiac and respiratory
% band signals
%
%INPUTS
%   t   - time vector
%   BP  - blood pressure signal vector
%OUTPUT
%   bp_low - low frequency component of BP
%   bp_card - the portion of the BP signal in the cardiac range
%   bp_resp - the portion of the BP signal in the respiratory range
%   retroicor (OPTIONAL OUTPUT, IF NOT LISTED, WILL NOT BE CALCULATED)
%       - 8 columns of retroicor signals - 4 cardiac and 4 respiratory
%
%CALLS
% addRegressors_retroicor
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

lowBp = 0.15;
cardRange = [45 320] / 60;  % I am taking the second harmonic too
respRange = [9 45] / 60;

Fs = 1./diff(t(1:2));

[b,a] = butter(8,lowBp / (Fs/2),'low');
bp_low = filtfilt(b,a,bp);

[b,a] = butter(9,cardRange / (Fs/2));
bp_card = filtfilt(b,a,bp);

[b,a] = butter(9,respRange(2) / (Fs/2) ,'low');
bp_resp = filtfilt(b,a,bp);
[b,a] = butter(8,respRange(1) / (Fs/2),'high');
bp_resp = filtfilt(b,a,bp_resp-bp_low);



if nargout==4
    % they want retroicor
    XrespRETRO = addRegressors_retroicor(t,bp_resp,'resp');
    XcardRETRO = addRegressors_retroicor(t,bp_card,'card');
    retroicor = [XcardRETRO XrespRETRO];
else
    retroicor = [];
end
return