% Script for ploting correlation matrices of each preprocessing type.
% fNIRS couse 2022 - Resting state

% Remove autocorrelation and compute correlation coefficient
% - RAW case
if exist('dc')
    pw_dc_raw = RemoveAutocorrelation_dc_fnirs_course...
        (dc,SD);
    
    % Compute Pearson Correlation Coefficient
    [C_raw] = ...
        Compute_correlation_coefficient_fnirs_course...
        (pw_dc_raw,BadChannels);
    
    figure('Renderer', 'painters', 'Position', [50 100 1200 300])
    subplot(1,3,1)
    imagesc(C_raw(:,:,1),[-1 1]);
    colormap jet
    title('HbO - Raw')
    
    subplot(1,3,2)
    imagesc(C_raw(:,:,2),[-1 1]);
    colormap jet
    title('HbR - Raw');
    
    subplot(1,3,3)
    imagesc(C_raw(:,:,3),[-1 1]);
    colormap jet
    title('HbT - Raw')
    
    plot_seed_based_sphere_style_fnirs_course...
    (C_raw(:,:,3),BadChannels,[-.8 .8]);
    
    subplot(1,3,2)
    title('Sensorimotor Network - No Regression (HbT)');
   
end


% Remove autocorrelation and compute correlation coefficient
% - SC Only Case
if exist('dc_only_SC')
    pw_dc_only_SC = RemoveAutocorrelation_dc_fnirs_course...
        (dc_only_SC,SD);
    
    % Compute Pearson Correlation Coefficient
    [C_only_SC] = ...
        Compute_correlation_coefficient_fnirs_course...
        (pw_dc_only_SC,BadChannels);
    
    figure('Renderer', 'painters', 'Position', [50 100 1200 300])
    subplot(1,3,1)
    imagesc(C_only_SC(:,:,1),[-1 1]);
    colormap jet
    title('HbO - Only SC')
    
    subplot(1,3,2)
    imagesc(C_only_SC(:,:,2),[-1 1]);
    colormap jet
    title('HbR - Only SC');
    
    subplot(1,3,3)
    imagesc(C_only_SC(:,:,3),[-1 1]);
    colormap jet
    title('HbT - Only SC')
    
    plot_seed_based_sphere_style_fnirs_course...
    (C_only_SC(:,:,3),BadChannels,[-.8 .8]);
    
    subplot(1,3,2)
    title('Sensorimotor Network - Only SC (HbT)');

end


% Remove autocorrelation and compute correlation coefficient
% - Phys Only Case
if exist('dc_only_Phys')
    pw_dc_only_Phys = RemoveAutocorrelation_dc_fnirs_course...
        (dc_only_Phys,SD);
    
    % Compute Pearson Correlation Coefficient
    [C_only_Phys] = ...
        Compute_correlation_coefficient_fnirs_course...
        (pw_dc_only_Phys,BadChannels);
    
    figure('Renderer', 'painters', 'Position', [50 100 1200 300])
    subplot(1,3,1)
    imagesc(C_only_Phys(:,:,1),[-1 1]);
    colormap jet
    title('HbO - Only Phys')
    
    subplot(1,3,2)
    imagesc(C_only_Phys(:,:,2),[-1 1]);
    colormap jet
    title('HbR - Only Phys');
    
    subplot(1,3,3)
    imagesc(C_only_Phys(:,:,3),[-1 1]);
    colormap jet
    title('HbT - Only Phys')
    
    plot_seed_based_sphere_style_fnirs_course...
    (C_only_Phys(:,:,3),BadChannels,[-.8 .8]);
    
    subplot(1,3,2)
    title('Sensorimotor Network - Only Phys (HbT)');

end



% Remove autocorrelation and compute correlation coefficient
% - SC + Phys Case
if exist('dc_SC_Phys')
    
    pw_dc_SC_Phys = RemoveAutocorrelation_dc_fnirs_course...
        (dc_SC_Phys,SD);
    
    % Compute Pearson Correlation Coefficient
    [C_SC_Phys] = ...
        Compute_correlation_coefficient_fnirs_course...
        (pw_dc_SC_Phys,BadChannels);
    
    
    figure('Renderer', 'painters', 'Position', [50 100 1200 300])
    subplot(1,3,1)
    imagesc(C_SC_Phys(:,:,1),[-1 1]);
    colormap jet
    title('HbO - SC+Phys')
    
    subplot(1,3,2)
    imagesc(C_SC_Phys(:,:,2),[-1 1]);
    colormap jet
    title('HbR - SC+Phys');
    
    subplot(1,3,3)
    imagesc(C_SC_Phys(:,:,3),[-1 1]);
    colormap jet
    title('HbT - SC+Phys')
    
    plot_seed_based_sphere_style_fnirs_course...
    (C_SC_Phys(:,:,3),BadChannels,[-.8 .8]);
    
    subplot(1,3,2)
    title('Sensorimotor Network - SC+Phys (HbT)');
    
end

% Remove autocorrelation and compute correlation coefficient
% - SC + Phys Case
if exist('dc_pca_one')
    
    pw_dc_pca_one = RemoveAutocorrelation_dc_fnirs_course...
        (dc_pca_one,SD);
    
    % Compute Pearson Correlation Coefficient
    [C_pca_one] = ...
        Compute_correlation_coefficient_fnirs_course...
        (pw_dc_pca_one,BadChannels);
    
    
    figure('Renderer', 'painters', 'Position', [50 100 1200 300])
    subplot(1,3,1)
    imagesc(C_pca_one(:,:,1),[-1 1]);
    colormap jet
    title('HbO - PCA 1')
    
    subplot(1,3,2)
    imagesc(C_pca_one(:,:,2),[-1 1]);
    colormap jet
    title('HbR - PCA 1');
    
    subplot(1,3,3)
    imagesc(C_pca_one(:,:,3),[-1 1]);
    colormap jet
    title('HbT - PCA 1')
    
    plot_seed_based_sphere_style_fnirs_course...
    (C_pca_one(:,:,3),BadChannels,[-.8 .8]);
    
    subplot(1,3,2)
    title('Sensorimotor Network - PCA 1 (HbT)');
    
end

% Remove autocorrelation and compute correlation coefficient
% - SC + Phys Case
if exist('dc_pca_two')
    
    pw_dc_pca_two = RemoveAutocorrelation_dc_fnirs_course...
        (dc_pca_two,SD);
    
    % Compute Pearson Correlation Coefficient
    [C_pca_two] = ...
        Compute_correlation_coefficient_fnirs_course...
        (pw_dc_pca_two,BadChannels);
    
    
    figure('Renderer', 'painters', 'Position', [50 100 1200 300])
    subplot(1,3,1)
    imagesc(C_pca_two(:,:,1),[-1 1]);
    colormap jet
    title('HbO - PCA 2')
    
    subplot(1,3,2)
    imagesc(C_pca_two(:,:,2),[-1 1]);
    colormap jet
    title('HbR - PCA 2');
    
    subplot(1,3,3)
    imagesc(C_pca_two(:,:,3),[-1 1]);
    colormap jet
    title('HbT - PCA 2')
    
    plot_seed_based_sphere_style_fnirs_course...
    (C_pca_two(:,:,3),BadChannels,[-.8 .8]);
    
    subplot(1,3,2)
    title('Sensorimotor Network - PCA 2 (HbT)');
    
end

