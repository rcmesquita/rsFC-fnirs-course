function hmrNirsFileSegment()
% Description: This function divides the nirs data into segments predefined by
% user input. User should input the time period of the segments of the nirs
% data as eg [0 200; 400:900; 950:1000] in *sec*
% Meryem A Yucel, Nov 2016
%%%%%%%%%%%%%%%

[files, pathnm] = uigetfile( '*.nirs', 'Pick the .nirs file', 'multiselect','on');
if files==0
    return
end

[pathstr,name,ext] = fileparts(files); 

if ~iscell(files)
    if files==0
        return;
    end
end

fsn = inputdlg( 'Select the time range (in seconds) for the segment of data to save in a separate file. You can enter multiple time ranges, separated by a '';'', to save different segments to different files. For example, [0 100; 300 400]', 'Segment NIRS file', 1 );
if length(fsn)==0
    return
end
fsn = str2num(fsn{1});

wd = cd;
cd(pathnm)

if ~iscell(files)
    foo{1} = files;
    files = foo;
end

for iFile = 1:length(files)
    load( files{iFile}, '-mat');
    fs = 1/(t(2)-t(1));
    
    d_all = d;
    t_all = t; maxT = max(t);
    s_all = s;
    if exist('aux10') & ~exist('aux')
        aux = aux10;
    end
    if exist('aux')
        aux_all = aux;
    else
        aux_all = zeros(size(d,1),1);
    end
    
    if fsn(1,1) == 0; % if time starts from 0, take the first data sample!
        fsn(1,1) = 1/fs;
    end
       
        
    for P = 1:size(fsn,1) % loop over different parts
        
        if fsn(P,1)> maxT || fsn(P,2) > maxT
            errordlg('Time period (in sec) exceeds the maximum time. Please re-try.','Retry');
            return
        elseif fsn(P,1) < 0 || fsn(P,2) < 0
            errordlg('Time period (in sec) should consist of positive numbers. Please re-try.','Retry');
            return
        end
        
        d = d_all(round(fsn(P,1)*fs):round(fsn(P,2)*fs),:);
        t = t_all(round(fsn(P,1)*fs):round(fsn(P,2)*fs),:);
        s = s_all(round(fsn(P,1)*fs):round(fsn(P,2)*fs),:);
        aux = aux_all(round(fsn(P,1)*fs):round(fsn(P,2)*fs),:);
        
        fname = sprintf([name '_part_' num2str(P) '.nirs']);
        if exist('ml') && exist('CondNames')
            save(fname,'d','t','s','aux','SD','ml','CondNames');
        elseif exist('ml')
            save(fname,'d','t','s','aux','SD','ml');
        else
            save(fname,'d','t','s','aux','SD');
        end
    end
end
 
 
    
cd(wd);
