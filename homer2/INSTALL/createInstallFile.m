function createInstallFile(options)

if ~exist('options','var') | isempty(options)
    options = 'all';
end
if exist('./INSTALL','dir')
    cd('./INSTALL');
end

% Find installation path and add it to matlab search paths
dirnameInstall = fileparts(which('createInstallFile.m'));
if isempty(dirnameInstall)
    m1 = sprintf('Cannot create installation package.\n');
    menu([m1],'OK');
    return;
end
addpath([dirnameInstall, '/../PACKAGES/Utils'], '-end')
[pp,fs] = getpathparts(dirnameInstall);
dirnameApp = buildpathfrompathparts(pp(1:end-1), fs(1:end-1,:));
if isempty(dirnameApp)
    m1 = sprintf('Cannot create installation package.\n');
    menu([m1],'OK');
    return;
end
if dirnameInstall(end)~='/' & dirnameInstall(end)~='\'
    dirnameInstall(end+1)='/';
end
if dirnameApp(end)~='/' & dirnameApp(end)~='\'
    dirnameApp(end+1)='/';
end
addpath(dirnameInstall, '-end')

cd(dirnameInstall);

% Start with a clean slate
cleanup(dirnameInstall, dirnameApp);

% Set the executable names based on the platform type
platform = setplatformparams();

if exist([dirnameInstall, 'homer2_install'],'dir')
    rmdir([dirnameInstall, 'homer2_install'],'s');
end
if exist([dirnameInstall, 'homer2_install.zip'],'file')
    delete([dirnameInstall, 'homer2_install.zip']);
end
mkdir([dirnameInstall, 'homer2_install']);

dirnameAtlas = 'PACKAGES/AtlasViewerGUI/Data/';

% Zip up MC application 
if exist([dirnameApp, 'PACKAGES/', platform.mc_exe_name],'dir')
    tar([dirnameInstall, 'homer2_install/', platform.mc_exe_name, '.tar'], [dirnameApp, 'PACKAGES/', platform.mc_exe_name]);
    gzip([dirnameInstall, 'homer2_install/', platform.mc_exe_name, '.tar']);
    delete([dirnameInstall, 'homer2_install/', platform.mc_exe_name, '.tar']);
end

% Generate executables
if ~strcmp(options, 'nobuild')
	Buildme_Setup(pwd);
	Buildme_Homer2_UI(dirnameApp);
	Buildme_AtlasViewerGUI(dirnameApp);
    if islinux()
        perl('./makesetup.pl','./run_setup.sh','./setup.sh');
    elseif ismac()
        perl('./makesetup.pl','./run_setup.sh','./setup.command');
    end
end


dirnameDb2DotMat = findWaveletDb2([dirnameInstall, 'homer2_install/']);

% Copy files to installation package folder
for ii=1:length(platform.atlasviewer_exe)
    if exist([dirnameInstall, platform.atlasviewer_exe{ii}],'file')
        copyfile([dirnameInstall, platform.atlasviewer_exe{ii}], [dirnameInstall, 'homer2_install/', platform.atlasviewer_exe{ii}]);
	end
end
for ii=1:length(platform.homer2_exe)
    if exist([dirnameInstall, platform.homer2_exe{ii}],'file')
        copyfile([dirnameInstall, platform.homer2_exe{ii}], [dirnameInstall, 'homer2_install/', platform.homer2_exe{ii}]);
    end
end
if exist([dirnameInstall, platform.setup_script],'file')==2
    copyfile([dirnameInstall, platform.setup_script], [dirnameInstall, 'homer2_install']);
    if ispc()
        copyfile([dirnameInstall, platform.setup_script], [dirnameInstall, 'homer2_install/Autorun.bat']);
    end
end
for ii=1:length(platform.setup_exe)
    if exist([dirnameInstall, platform.setup_exe{ii}],'file')
        if ispc()
            copyfile([dirnameInstall, platform.setup_exe{1}], [dirnameInstall, 'homer2_install/installtemp']);
        else
            copyfile([dirnameInstall, platform.setup_exe{ii}], [dirnameInstall, 'homer2_install/', platform.setup_exe{ii}]);
        end
	end
end
if exist([dirnameApp, dirnameAtlas, 'Colin'],'dir')
    copyfile([dirnameApp, dirnameAtlas, 'Colin/anatomical/*.*'], [dirnameInstall, 'homer2_install']);
    copyfile([dirnameApp, dirnameAtlas, 'Colin/fw/*.*'], [dirnameInstall, 'homer2_install/']);
end

if exist([dirnameApp, 'PACKAGES/Test'],'dir')
    copyfile([dirnameApp, 'PACKAGES/Test'], [dirnameInstall, 'homer2_install/Test']);
end

for ii=1:length(platform.createshort_script)
    if exist([dirnameInstall, platform.createshort_script{ii}],'file')
        copyfile([dirnameInstall, platform.createshort_script{ii}], [dirnameInstall, 'homer2_install']);
    end
end

if exist([dirnameDb2DotMat, 'db2.mat'],'file')
    copyfile([dirnameDb2DotMat, 'db2.mat'], [dirnameInstall, 'homer2_install']);
end

if exist([dirnameInstall, 'makefinalapp.pl'],'file')
    copyfile([dirnameInstall, 'makefinalapp.pl'], [dirnameInstall, 'homer2_install']);
end

if exist([dirnameInstall, 'README.txt'],'file')
    copyfile([dirnameInstall, 'README.txt'], [dirnameInstall, 'homer2_install']);
end

for ii=1:length(platform.iso2meshmex)
    % Use dir instead of exist for mex files because of an annoying matlab bug, where a  
    % non existent file will be reported as exisiting as a mex file (exist() will return 3)
    % because there are other files with the same name and a .mex extention that do exist. 
    % dir doesn't have this problem.
    if ~isempty(dir([platform.iso2meshbin, platform.iso2meshmex{ii}]))
        copyfile([platform.iso2meshbin, platform.iso2meshmex{ii}], [dirnameInstall, 'homer2_install']);
    else
        menu(sprintf('Warning: could not find mex file %s', platform.iso2meshmex{ii}), 'OK');
    end
end

% Zip it all up into a single installation file
zip([dirnameInstall, 'homer2_install.zip'], [dirnameInstall, 'homer2_install']);

% Clean up 
fclose all;
cleanup(dirnameInstall, dirnameApp);



