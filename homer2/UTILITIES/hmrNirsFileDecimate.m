% hmrNirsFileDecimate()
%
% A utility that let's you pick NIRS files in a file dialog box that
% are then decimated to the specified frequency using a low pass filter as
% implemented by the matlab 'resample' command.
%
% Note that original copies of the NIRS files are not preserved. It is
% advised that you create a back up of your NIRS files in case you want to
% recover the higher sample rate date.
%

function hmrNirsFileDecimate()

[files, pathnm] = uigetfile( '*.nirs', 'Pick files to decimate', 'multiselect','on');
if ~iscell(files)
    if files==0
        return;
    end
end

fsn = inputdlg( 'New sample rate (Hz)', 'Decimate NIRS files', 1 );
fsn = str2num(fsn{1});

wd = cd;
cd(pathnm)

if ~iscell(files)
    foo{1} = files;
    files = foo;
end

for iFile = 1:length(files)
    load( files{iFile}, '-mat');
    varLst = whos();
    
    fs = 1/(t(2)-t(1));
    
    d = resample(d,round(fsn),round(fs));
    if exist('aux10')
        if ~isempty(aux10)
            aux10 = resample(aux10,round(fsn),round(fs));
        end
    end
    if exist('aux')
        if ~isempty(aux)
            aux = resample(aux,round(fsn),round(fs));
        end
    end
    t = [1:size(d,1)]'*t(end)/size(d,1);

    for j=1:size(s,2);
    s_sampled(:,j) = resample(s(:,j),round(fsn),round(fs));
    end
    s = s_sampled;
    
    for ii=1:size(s,2)
        lst = find(s(:,ii)>max(s(:,ii))/2);
        if ~isempty(lst)
            lst2 = find( (t(lst(2:end))-t(lst(1:end-1)))>(3/fsn) );
            lst2(end+1) = length(lst);
            s(:,ii) = 0;
            s(lst(lst2),ii) = 1;
        end
    end
    
    foos = '''-mat''';
    boos = '';
    for ii=1:length(varLst)
        if ~strcmpi(varLst(ii).name,'wd') & ~strcmpi(varLst(ii).name,'files') & ~strcmpi(varLst(ii).name,'pathnm') ...
                & ~strcmpi(varLst(ii).name,'fsn') & ~strcmpi(varLst(ii).name,'fs') ...
                & ~strcmpi(varLst(ii).name,'foo') & ~strcmpi(varLst(ii).name,'iFile')
            foos = sprintf('%s, ''%s''', foos, varLst(ii).name);
            boos = sprintf('%s %s', boos, varLst(ii).name);
        end
    end
    eval( sprintf('save(''%s'',%s);',files{iFile},foos) );
    
    eval( sprintf('clear %s', boos ) );
 end

    
    
cd(wd);
