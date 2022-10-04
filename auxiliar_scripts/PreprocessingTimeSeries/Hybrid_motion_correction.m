function[dOD_corrected] = Hybrid_motion_correction(dOD,SD)

% Motion artifact correction with Spline interpolation followed by Wavelet
% decomposition.
%
%   INPUT:
%       dOD - Optical density.
%       SD - fNIRS structure commonly used on Homer.
%   
%   OUTPUT:
%       dOD_corrected - Optical density after motion artifact correction.
%

% First perform Spline correction
% Spline
SplineThreshold = 4.5;
dOD_spline = ...
    SplineCorrection_fnirs_course(dOD,SD,SplineThreshold);

% Create MeasListAct (internal variable for Homer that indicates which
% channels should be consired)
SD.MeasListAct = ...
    ones(size(dOD,2),1);

% Wavelet Parameter
wavelet_parameter = 1.5;

%Perform Wavelet
dOD_corrected = hmrMotionCorrectWavelet...
    (dOD_spline,SD,wavelet_parameter);

end