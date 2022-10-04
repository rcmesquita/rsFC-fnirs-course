function group = loadGroupNirsDataFile(dirname)

group = [];
if ~exist('dirname','var') || ~exist(dirname, 'dir')
    dirname = pwd;
end
if dirname(end)~='/' && dirname(end)~='\'
    dirname(end+1) = '/';
end

% If groupResult.mat does not exist in the folder dirname then it's not a
% group folder. 
if ~exist([dirname, 'groupResults.mat'],'file')
    return;
end

% Error checks: If groupResults exists but is corrupt then it's not a
% group folder.
nirsdata = load([dirname, 'groupResults.mat']);
if ~isfield(nirsdata, 'group')
    return;
end
if ~isstruct(nirsdata.group) && ~isobject(nirsdata.group)
    return;
end
if ~isfield(nirsdata.group, 'procResult')
    return;
end
if ~isfield(nirsdata.group, 'procInput')
    return;
end
group = nirsdata.group;
