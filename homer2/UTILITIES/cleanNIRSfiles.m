function cleanNIRSfiles()

[files,pathnm] = uigetfile('*.nirs','Select NIRS files to reset','multiselect','on');

files
if ~iscell(files)
    foo = files;
    clear files
    files{1} = foo;
end
    
wd = cd;
cd(pathnm)

for iFile = 1:length(files)
    load(files{iFile},'-mat');
    system(['mv ' files{iFile} ' ' files{iFile} '.orig']);
    save(files{iFile},'-mat','SD','ml','d','t','s','aux');
end

cd(wd)


