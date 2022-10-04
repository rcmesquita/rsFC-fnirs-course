function setpaths_proprietary(options)


if options.fluence_simulate
    genMultWlFluenceFiles_CurrWorkspace;
end

[r(1), toolboxes1] = checkToolboxes_Homer2();
[r(2), toolboxes2] = checkToolboxes_AtlasViewer();

fprintf('\n');
if all(r==1)
    fprintf('All required toolboxes are installed.\n');
elseif ismember(3, r)
    fprintf('Unable to verify if all required toolboxes are installed ...\n');
elseif ismember(4, r)
    fprintf('Unable to verify if all required toolboxes are installed with older Matlab release...\n');
else
    fprintf('Some required toolboxes are missing...\n');
end

% Check if wavelet data db2.mat is available in toolbox.
% If no then create it from known data
fullpathhomer2 = fileparts(which('Homer2_UI.m'));
if fullpathhomer2(end)~='/' & fullpathhomer2(end)~='\'
    fullpathhomer2(end+1)='/';
end
findWaveletDb2([fullpathhomer2, 'UTILITIES/Wavelet/']);

pause(2);
% open([fullpathhomer2, 'PACKAGES/Test/Testing_procedure.pdf']);
msg{1} = sprintf('For instructions to perform basic tests of Homer2_UI and AtlasViewerGUI, open the PDF file %s', ...
    [fullpathhomer2, 'PACKAGES/Test/Testing_procedure.pdf']);
fprintf('\n\n*** %s ***\n\n', [msg{:}]);
