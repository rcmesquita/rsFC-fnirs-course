function[y_new,X_new,shift,coor_max] = AdjustTemporalShift_for_Regression(y,X,maxLag)

%Input: 
%   y - signal to be filtered (regressed out)
%   X - Regressors
%
%Output
%
%   X_new - Shifted data with proper size.
%

for Nadd = 1:size(X,2)
    
    % Compute xcorr to find shifts between the physiology
    [corrValues Lags] = ...
        xcorr(y,X(:,Nadd),maxLag,'coeff');
    
    [max_coor_value index_Lag_corr]  = max(abs(corrValues));
    
    shift(Nadd) = Lags(min(index_Lag_corr));
    coor_max(:,Nadd) = corrValues(index_Lag_corr);

    % Shifted Additional Regressors
    X_new(:,Nadd) =...
        circshift(X(:,Nadd),shift(Nadd));
    
end

% Correct Design Matrix and the Y vector
% by removing the firts and last points
% based on the maximum allowed LAG
y_new=y;

X_new(1:maxLag,:) = [];
y_new(1:maxLag,:) = [];

X_new(end-maxLag:end,:) = [];
y_new(end-maxLag:end,:) = [];


end