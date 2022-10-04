function[filtered_dc,Stats] = ...
    PhysiologyRegression_GLM_fnirs_course...
    (dc,SD,SSlistGood,AdditionalRegressors)
% This function performs physiological Regression based
% on Short-channel and with additional Regressors of physiology.
% The additional Regressors must be inputed.
% The regressions will be performed with the robustfit matlab function:
% robustfit(X,y,'bisquare',[],'on');
%
%   INPUT:
%       dc: Hemoglobin concentration - Time pnts x Channels x Hemoglobin
%
%       SD: standard fNIRS SD structure
%
%       SSlistGood: List with good short channels
%
%       AdditionalRegressors: Physiological data to be regressed in
% addition to the short channels. The dimension of this data should match
% the ones from the concentration data (dc).
%
%
%
%    OUTPUT:
%       filtered_dc: This is the filtered concentration data after all
% regression, which is basically the residual of the robustfit.

% Perform regression in HbO and HbR
for Hb=1:2
    
    for Nchan=1:size(dc,2)
        
        % Step 1: Perform Regression in a given channel Nchan
        y = dc(:,Nchan,Hb);
        
        % Step 2: Create Design Matrix (X) for regression
        X=[];
        
        if ~isempty(SSlistGood)
            % Add HbO and HbR in the design matrix
            Xshort = [dc(:,SSlistGood,1),dc(:,SSlistGood,2)];
            
            % PCA for removing collinearity
            [coeff_pca Xshort_pca] = pca(Xshort);
            
            % Update Design Matrix with the PCs
            X = [X,Xshort_pca];
            
        end
        
        
        if ~isempty(AdditionalRegressors)
            
            % Perform shift in each additional regressor
            % that maximizes the correlation with the fNIRS channel.
            % The maximum allowed shift is 20 seconds.
            
            maxLag = round(20*SD.f);
            [y,AdditionalRegressors_s,shift_AD,coor_max] = ...
                AdjustTemporalShift_fnirs_course...
                (y,AdditionalRegressors,maxLag);
            
            % We have to cut the begning and end of the design matrix
            % as we did with the shifted time series and y vector inside
            % "AdjustTemporalShift_for_Regression".
            if ~isempty(X)
                X(1:maxLag,:) = [];
                X(end-maxLag:end,:) = [];
            end
            
            % Next, we add the shifted additional regressors
            % to the design matrix
            X = [X,AdditionalRegressors_s];
        end
        
        % Perform Robust Fit Regression
        [Dummy, StatsDummy] = robustfit(X,y,'bisquare',[],'on');
        
        % Save filtered data (residual)
        filtered_dc(:,Nchan,Hb) = StatsDummy.resid;
        
        % Save Additional Regressors Shifts for further analysis
        if ~isempty(AdditionalRegressors)
            StatsDummy.shift_AD = shift_AD./SD.f;
            StatsDummy.coor_AD = coor_max;
        end
        
        % Save Stats for further analysis
        Stats{Nchan}{Hb} = StatsDummy;
        
        clear y X StatsDummy;
        
        
    end
    
    
end

% Compute total hemoglobin
filtered_dc(:,:,3) = filtered_dc(:,:,1) + filtered_dc(:,:,2);

end



