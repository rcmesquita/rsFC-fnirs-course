function group = loadGroup(files)

group = [];

curr_dir=pwd; 
i = sort([findstr(curr_dir,'/') findstr(curr_dir,'\')]);
groupCurr(1).name = curr_dir(i(end)+1:end);
groupCurr(1).subjs = [];
groupCurr(1).procInput = initProcInputStruct('group');
groupCurr(1).procResult = initProcResultStruct('group');
groupCurr(1).nFiles = 0;
groupCurr(1).conditions = struct(...
                                 'CondTbl',{{}}, ...
                                 'CondNamesAct',{{}}, ...
                                 'CondRunIdx',[], ...
                                 'CondColTbl',[] ...
                                );
rnum = 1;
for ii=1:length(files)
    if files(ii).isdir

        jj = length(groupCurr(1).subjs)+1;
        groupCurr(1).subjs(jj).name = files(ii).name;
        groupCurr(1).subjs(jj).procInput = initProcInputStruct('subj');
        groupCurr(1).subjs(jj).procResult = initProcResultStruct('subj');           
        groupCurr(1).subjs(jj).fileidx = ii;
        groupCurr(1).subjs(jj).runs = [];
        
    else
        
        fname = files(ii).name;
        [sname rnum_tmp iExt] = getSubjNameAndRun(fname,rnum);
        if rnum_tmp ~= rnum
            rnum = rnum_tmp;
        end

        jj=1;
        while jj<=length(groupCurr(1).subjs)
            if(strcmp(sname, groupCurr(1).subjs(jj).name))
                nRuns = length(groupCurr(1).subjs(jj).runs);
                
                % If this run already exists under this subject, the user probably 
                % made a mistake in naming the file (e.g., having two files named
                % <subjname>_run01.nirs and <subjname>_run01_<descriptor>.nirs)
                % We handle it anyways by continuing through all existing subjects 
                % until we are forced to create a new subject with one run.
                flag=0;
                for kk=1:nRuns
                    if rnum == groupCurr(1).subjs(jj).runs(kk).rnum
                        sname = fname(1:iExt-1);
                        jj=jj+1;
                        
                        flag = 1;
                        break;
                    end
                end
                if flag==1
                    flag = 0;
                    continue
                end
                
                % Create new run in existing subject
                groupCurr(1).subjs(jj).runs(nRuns+1).filename = fname;
                groupCurr(1).subjs(jj).runs(nRuns+1).fileidx = ii;
                groupCurr(1).subjs(jj).runs(nRuns+1).rnum = rnum;
                groupCurr(1).subjs(jj).runs(nRuns+1).procInput = ...
                    loadProcInput(groupCurr(1).subjs(jj).runs(nRuns+1));                
                rnum=rnum+1;
                groupCurr(1).nFiles = groupCurr(1).nFiles+1;
                break;      
            end
            jj=jj+1;
        end

        % Create first run in new subject
        if(jj>length(groupCurr(1).subjs))

            groupCurr(1).subjs(jj).name = sname;
            groupCurr(1).subjs(jj).procInput = initProcInputStruct('subj');
            groupCurr(1).subjs(jj).procResult = initProcResultStruct('subj');
            groupCurr(1).subjs(jj).fileidx = 0;
            
            groupCurr(1).subjs(jj).runs(1).filename = fname;
            groupCurr(1).subjs(jj).runs(1).fileidx = ii;
            groupCurr(1).subjs(jj).runs(1).rnum = rnum;
            groupCurr(1).subjs(jj).runs(1).procInput = ...
                loadProcInput(groupCurr(1).subjs(jj).runs(1));
            rnum=rnum+1;
            
            groupCurr(1).subjs(jj).procInput.SD = ...
                groupCurr(1).subjs(jj).runs(1).procInput.SD;
            groupCurr(1).nFiles = groupCurr(1).nFiles+1;

        end
    end
end
groupCurr(1).procInput.SD = ...
    groupCurr(1).subjs(1).procInput.SD;


% Load group results if they exist and compare with the 
% current group of files represented by groupCurr
groupPrev = loadGroupNirsDataFile('.');
if ~isempty(groupPrev)
    
    % copy procResult from previous group to current group for 
    % all nodes that still exist in the current group.
    hwait = waitbar(0,'Loading group');
    groupCurr = copyProcParams(groupCurr,groupPrev,'group',hwait,length(files));
    close(hwait);

    if isempty(groupCurr.conditions.CondNamesAct)
        groupCurr = stimCondGroupInit(groupCurr,files);
    end

% If there's no groupResults.mat then set the change flags for group and
% subject procInput to 1 to indicate that the procResult needs to be 
% recalculated.
else

    for ii=1:length(groupCurr)
        for jj=1:length(groupCurr(ii).subjs)
            groupCurr(ii).subjs(jj).procInput.changeFlag=1;
        end
        groupCurr(ii).procInput.changeFlag=1;
    end

    groupCurr = stimCondGroupInit(groupCurr,files);
    
end

group = groupCurr;





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Extract the subject name and run number from a .nirs 
% filename.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [sname rnum k2] = getSubjNameAndRun(fname,rnum)

k1=findstr(fname,'/');
k2=findstr(fname,'.nirs');
if ~isempty(k1)
    sname = fname(1:k1-1);
else
    k1=findstr(fname,'_run');

    % Check if there's subject and run info in the filename 
    if(~isempty(k1))
        sname = fname(1:k1-1);
        rnum = [fname(k1(1)+4:k2(1)-1)];
        k3 = findstr(rnum,'_');
        if ~isempty(k3)
            if ~isempty(rnum)
                rnum = rnum(1:k3-1);
            end
        end
        if isempty(rnum) | ~isnumber(rnum)
            rnum = 1;
        else
            rnum = str2num(rnum);
        end
    else
        sname = fname(1:k2-1);
        rnum = 1;
    end
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copy processing params (procInut and procResult) from 
% N2 to N1 if N1 and N2 are same nodes
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function N1 = copyProcParams(N1,N2,type,hwait,ntot)

switch lower(type)
case {'group','grp'}
    if strcmp(N1.name,N2.name)
        for i=1:length(N1.subjs)
            j=existSubj(N1.subjs(i),N2);
            if (j>0)
                N1.subjs(i) = copyProcParams(N1.subjs(i),N2.subjs(j),'subj',hwait,ntot);
            end
        end
        if groupsSame(N1,N2)
            N1 = copyProcParamsFieldByField(N1,N2,'group');
        else
            N1.procInput.changeFlag=1;
        end
    end
case {'subj','subject'}
    if strcmp(N1.name,N2.name)
        % No need to copy run data from previous N2's runs to N1.
        % All run data was loaded from .nirs file when the current 
        % group was initialized.
        if subjsSame(N1,N2)
            N1 = copyProcParamsFieldByField(N1,N2,'subj');
        else
            N1.procInput.changeFlag=1;
        end
    end
case {'run'}
    hwait = waitbar( N1.fileidx/ntot, hwait, ...
                     sprintf('Loading file %s, %d of %d',N1.filename,N1.fileidx,ntot) );
    if strcmp(N1.filename,N2.filename)
        N1 = copyProcParamsFieldByField(N1,N2,'run');
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copy processing params (procInut and procResult) from 
% N2 to N1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function N1 = copyProcParamsFieldByField(N1,N2,type)

switch lower(type)

case {'group','grp'}

    % procInput
    if isfield(N2,'procInput') && ~isempty(N2.procInput)
        N1.procInput = copyStructFieldByField(N1.procInput,N2.procInput,'procInput');
    end

    % procResult
    if isfield(N2,'procResult') && ~isempty(N2.procResult)
        N1.procResult = copyStructFieldByField(N1.procResult,N2.procResult);
    end

    % conditions
    if isfield(N2,'conditions') && ~isempty(N2.conditions)
        N1.conditions = copyStructFieldByField(N1.conditions,N2.conditions,'conditions');
    end
    
case {'subj','subject'}

    % procInput
    if isfield(N2,'procInput')
        N1.procInput = copyStructFieldByField(N1.procInput,N2.procInput,'procInput');
    end

    % procResult
    if isfield(N2,'procResult') && ~isempty(N2.procResult)
        N1.procResult = copyStructFieldByField(N1.procResult,N2.procResult);
    end

case {'run'}

    % Load only those fields which are stored in memory. Anything 
    % that's stored only in files like procResult need not be loaded
    % and resaved.

    % procInput
    rundata = load(N2.filename,'-mat','procInput');

    % Try to get it from file first
    if isfield(rundata,'procInput')
        N1.procInput = copyStructFieldByField(N1.procInput,rundata.procInput,'procInput');
    end
    
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Groups N1 and N2 are considered same if their names 
% are same and their subject set is same.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function B=groupsSame(N1,N2)

B=1;
if ~strcmp(N1.name,N2.name)
    B=0;
    return;
end
for i=1:length(N1.subjs)
    j=existSubj(N1.subjs(i),N2);
    if j==0 || ~subjsSame(N1.subjs(i),N2.subjs(j))
        B=0;
        return;
    end
end
for i=1:length(N2.subjs)
    j=existSubj(N2.subjs(i),N1);
    if j==0 || ~subjsSame(N2.subjs(i),N1.subjs(j))
        B=0;
        return;
    end
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Subjects N1 and N2 are considered same if their names 
% are same and their sets of runs is same.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function B=subjsSame(N1,N2)

B=1;
if ~strcmp(N1.name,N2.name)
    B=0;
    return;
end
for i=1:length(N1.runs)
    j=existRun(N1.runs(i),N2);
    if j==0
        B=0;
        return;
    end
end
for i=1:length(N2.runs)
    j=existRun(N2.runs(i),N1);
    if j==0
        B=0;
        return;
    end
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Check whether subject S exists in group G and return 
% its index in G if it does exist. Else return 0.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function j=existSubj(S,G)

j=0;
for i=1:length(G.subjs)
    if strcmp(S.name,G.subjs(i).name)
        j=i;
        break;
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Check whether run R exists in subject S and return
% its index in S if it does exist. Else return 0.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function j=existRun(R,S)

j=0;
for i=1:length(S.runs)
    % Begin: forward compatibility with Homer3.
    if ~isfield(R, 'filename') & isfield(R, 'name')
        R.filename = R.name;
    end
    for ii=1:length(S.runs)
        if ~isfield(S.runs(ii), 'filename') & isfield(S.runs(ii), 'name')
            S.runs(ii).filename = S.runs(ii).name;
        end
    end
    % End: forward compatibility with Homer3.   
    
    [sname1 rnum1] = getSubjNameAndRun(R.filename,i);
    [sname2 rnum2] = getSubjNameAndRun(S.runs(i).filename,i);
    if strcmp(sname1,sname2) && rnum1==rnum2
        j=i;
        break;
    end
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load procInput for one run by copying it from the 
% corresponding .nirs field by field.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function procInput = loadProcInput(N1)

N1.procInput = initProcInputStruct('run');
rundata = load(N1.filename,'-mat','procInput');
if isfield(rundata,'procInput')
    N1.procInput = copyStructFieldByField(N1.procInput,rundata.procInput,'procInput');
end   
procInput = N1.procInput;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% No built in matlab function isnumber function which 
% takes a string arg. Using my own.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function b = isnumber(str)    
b = ~isempty(str2num(str));





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Generate Group conditions based on the collective 
% stims of the group files
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function group = stimCondGroupInit(group,files)

% Create CondTbl from stimConditionNames.txt file if it exists
% or if not, generate it by numbering cond for each run. 
% Then convert CondTbl to CondNames
global COND_TBL_OFFSET;
COND_TBL_OFFSET=2;

group.conditions.CondTbl = EasyNIRS_stimCondInit(files);
[CondNamesAct CondRunIdx] = stimGUI_MakeConditions(group.conditions.CondTbl);
group.conditions.CondNamesAct = CondNamesAct;
group.conditions.CondRunIdx = CondRunIdx;
group.conditions.CondColTbl = ...
[ ...
    0.0  0.0  1.0; ...
    0.0  1.0  0.0; ...
    1.0  0.0  0.0; ...
    0.5  1.0  1.0; ...
    1.0  0.5  0.0; ...
    0.5  0.5  1.0; ...
    0.5  1.0  0.5; ...
    1.0  0.5  0.5; ...
    1.0  0.5  1.0; ...
    1.0  0.0  1.0; ...
    0.2  0.3  0.0; ...
    0.2  0.2  0.2; ...
    0.0  1.0  1.0; ...
    0.2  0.4  0.5; ...
    0.6  0.6  0.6; ...
    0.2  0.1  0.8 ...
];
m = size(group.conditions.CondColTbl,1);
n = length(group.conditions.CondNamesAct);
d = n-m;
group.conditions.CondColTbl = [group.conditions.CondColTbl; rand(d,3)];

