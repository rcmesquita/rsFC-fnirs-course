function imgrecon = getImgRecon(imgrecon, dirname, fwmodel, pialsurf, probe)

if isempty(imgrecon)
    return;
end

if iscell(dirname)
    for ii=1:length(dirname)
        imgrecon = getImgRecon(imgrecon, dirname{ii}, fwmodel, pialsurf, probe);
        if ~imgrecon.isempty(imgrecon)
            return;
        end
    end
    return;
end

if isempty(dirname)
    return;
end

if dirname(end)~='/' && dirname(end)~='\'
    dirname(end+1)='/';
end
dirnameOut = [dirname 'imagerecon/'];


% Since sensitivity profile exists, enable all image panel controls 
% for calculating metrics
set(imgrecon.handles.pushbuttonCalcMetrics_new, 'enable','on');

imgrecon.mesh = fwmodel.mesh;

if exist([dirnameOut, 'metrics.mat'])
    load([dirnameOut, 'metrics.mat']);
    imgrecon.localizationError = localizationError;
    imgrecon.resolution = resolution;
end


% Check if there's group acquisition data to load
[~,~, group] = findSubjDirs();
if ~isempty(group)
    imgrecon.subjData.SD = getSD(group);
    imgrecon.subjData.name = group.name;
    imgrecon.subjData.procResult = group.procResult;
    imgrecon.subjData.subjs = group.subjs;
    set(imgrecon.handles.menuItemImageReconGUI, 'enable', 'on');
end


if exist([dirnameOut, 'Aimg_conc.mat'],'file')
    imgrecon.Aimg_conc = load([dirnameOut, 'Aimg_conc.mat'], '-mat');
end
if exist([dirnameOut, 'Aimg_conc_scalp.mat'],'file')
    imgrecon.Aimg_conc_scalp = load([dirnameOut, 'Aimg_conc_scalp.mat'], '-mat');
end

if ~isempty(probe.ml) & ~isempty(fwmodel.Adot)
    enableImgReconGen(imgrecon, 'on');
    enableImgReconDisplay(imgrecon, 'on');
else
    enableImgReconGen(imgrecon, 'off');
    enableImgReconDisplay(imgrecon, 'off');
end

if ~imgrecon.isempty(imgrecon)
    imgrecon.pathname = dirname;
end
