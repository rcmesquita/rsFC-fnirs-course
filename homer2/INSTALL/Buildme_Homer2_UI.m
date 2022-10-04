function Buildme_Homer2_UI(dirnameApp)

platform = setplatformparams();

if ~exist('dirnameApp','var') | isempty(dirnameApp)
    dirnameApp = ffpath('setpaths.m');
    if exist('./INSTALL','dir')
        cd('./INSTALL');
    end
end
if dirnameApp(end)~='/' & dirnameApp(end)~='\'
    dirnameApp(end+1)='/';
end

dirnameInstall = pwd;
cd(dirnameApp);

Buildme('Homer2_UI', {}, {'.svn','DISPLAY','AtlasViewerGUI','tMCimg','SDgui','NIRS_Probe_Designer_V1'});
for ii=1:length(platform.homer2_exe)
    if exist(['./',  platform.homer2_exe{ii}],'file')
        movefile(['./',  platform.homer2_exe{ii}], dirnameInstall);
    end
end

cd(dirnameInstall);
