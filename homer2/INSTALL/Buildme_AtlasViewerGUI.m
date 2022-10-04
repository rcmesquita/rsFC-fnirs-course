function Buildme_AtlasViewerGUI(dirnameApp)

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
cd([dirnameApp, 'PACKAGES/AtlasViewerGUI']);

Buildme('AtlasViewerGUI', {'../SDgui','../Utils'});
for ii=1:length(platform.atlasviewer_exe)
    if exist(['./',  platform.atlasviewer_exe{ii}],'file')
        movefile(['./',  platform.atlasviewer_exe{ii}], dirnameInstall);
    end
end

cd(dirnameInstall);

