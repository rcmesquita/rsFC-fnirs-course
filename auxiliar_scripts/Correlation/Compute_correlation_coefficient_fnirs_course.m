function [CorrelationCoefficient] = ...
    Compute_correlation_coefficient_fnirs_course(dc,BadChannels)

    % Compute Pearson Correlation for all hemoglobin
    %
    % Input: 
    % dc - hemoglobin concentration - Time pnts x channel x hemoglobin
    % BadChannels - List of channels with low SNR
    
    % List of Short Channels 
    SSlist = [8 29 52 66 75 92 112 125];
   
    % Exclude channels from Correlation Matrix
    exclude_channels = unique([SSlist,BadChannels']);
    
    % Compute for HbO, HbR, and HbT  
    for Hb=1:3
        
        CorrelationCoefficient(:,:,Hb) = ...
            corrcoef(dc(:,:,Hb));
        
    end
    
    % Assign "Exclude channels" as nan
%     CorrelationCoefficient(exclude_channels,:,:) = nan;
%     CorrelationCoefficient(:,exclude_channels,:) = nan;
     
    % Remove "Exclude channels"
%     CorrelationCoefficient(exclude_channels,:,:) = [];
%     CorrelationCoefficient(:,exclude_channels,:) = [];
    
       % Assign "Exclude channels" as zeros
     CorrelationCoefficient(exclude_channels,:,:) = 0;
     CorrelationCoefficient(:,exclude_channels,:) = 0;

end