% hmrNirsFileDownsample()
%
% A utility that let's you pick NIRS files in a file dialog box that
% are then decimated to the specified frequency using a low pass filter as
% implemented by the matlab 'downsample' command.
%
% Note that original copies of the NIRS files are not preserved. It is
% advised that you create a back up of your NIRS files in case you want to
% recover the higher sample rate date.
% Modified from resample code
% fixed the problem with edges
% fixed the problem with s vector - Meryem Oct 2016
% add code to allow non-integer downsampling factor - Meryem Oct 2018

function hmrNirsFileDownsample()

[files, pathnm] = uigetfile( '*.nirs', 'Pick files to decimate', 'multiselect','on');
if ~iscell(files)
    if files==0
        return;
    end
end

fsn = inputdlg( 'Decrease the sampling rate of a sequence by', 'Downsample NIRS files', 1 );
fsn = str2num(fsn{1});

wd = cd;
cd(pathnm)

if ~iscell(files)
    foo{1} = files;
    files = foo;
end

for iFile = 1:length(files)
    load( files{iFile}, '-mat');
    clear procResult tIncMan s0
    if exist('aux10') & ~exist('aux')
        aux = aux10;
        clear aux10
    end
    varLst = whos();
    
    fs = 1/(t(2)-t(1));
    
    if floor(fsn) == fsn % integer check
      
        d = downsample(d,fsn);
        if exist('aux')
            if ~isempty(aux)
                aux = downsample(aux,fsn);
            end
        end
        t = downsample(t,fsn);
        s_sampled = zeros(size(t,1),size(s,2));
        for j=1:size(s,2);
        lst = find(s(:,j)==1);
        lst = round(lst/fsn);
        s_sampled(lst,j) = 1;
        end
        for j=1:size(s,2);
        lst = find(s(:,j)==-1);
        lst = round(lst/fsn);
        s_sampled(lst,j) = -1;
        end
        s = s_sampled;
    else  % if downsample factor is not an integer (first upsample then downsample)
        t_new = linspace(1, size(d,1), 10*size(d,1));
        d = interp1(d, t_new);
        d = downsample(d,round(fsn*10));
        if exist('aux')
            if ~isempty(aux)
                aux = interp1(aux, t_new);
                aux = downsample(aux,round(fsn*10))';
            end
        end
        
        t = interp1(t, t_new);
        t = downsample(t,round(fsn*10))';
        
        s_sampled = zeros(size(t,1),size(s,2));
        for j=1:size(s,2);
        lst = find(s(:,j)==1);
        lst = round(lst/fsn);
        s_sampled(lst,j) = 1;
        end
        for j=1:size(s,2);
        lst = find(s(:,j)==-1);
        lst = round(lst/fsn);
        s_sampled(lst,j) = -1;
        end
        s = s_sampled;
    
    end
        
    
    clear procResult tIncMan s0
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
