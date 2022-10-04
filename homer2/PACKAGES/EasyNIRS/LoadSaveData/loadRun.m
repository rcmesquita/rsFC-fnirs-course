function run = loadRun(run,filename,varargin)
SD=[];
s=[];
t=[];
aux=[];

% load global run variable
run.filename = filename;

paramsLst = extractParams(varargin);
eval(sprintf('load(filename,''-mat'',%s);',paramsLst));

% load global run variable
if exist('d','var')
    run.d = d;
elseif paramRequested(varargin,'d')
    run.d = [];
end

if exist('t','var') && ~isempty(t)
    run.t = t;
elseif paramRequested(varargin,'t')
    run.t = [];
end

if exist('SD','var') && ~isempty(SD)
    run.SD = addSDData(SD);
elseif paramRequested(varargin,'SD')
    run.SD = [];
end

if exist('CondNames','var') && exist('s','var')
    run.stim.CondNames = CondNames;
elseif paramRequested(varargin,'CondNames') && exist('s','var')
    run.stim.CondNames = stimCondInit(s);
end

if exist('s','var') && ~isempty(s)
    run.s = s;
elseif paramRequested(varargin,'s')
    run.s = zeros(length(run.t),1);
end

if exist('s0','var') && ~isempty(s0)
    run.s0 = s0;
else
    run.s0 = run.s;
end

if exist('aux','var') && ~isempty(aux)
    run.aux = aux;
elseif paramRequested(varargin,'aux')
    run.aux = [];
end

% Compatibility aux
if exist('aux10','var')
    run.aux = aux10;
end

if exist('tIncMan','var')
    if isempty(tIncMan)
        tIncMan = ones(length(t),1);
    end
    run.tIncMan = tIncMan;
elseif paramRequested(varargin,'tIncMan')
    run.tIncMan = ones(length(t),1);
end

% Compatibility tIncMan ver1
if exist('timeExcludeVec','var')
    if isempty(timeExcludeVec)
        timeExcludeVec = zeros(length(t),1);
    end
    run.tIncMan = xor(timeExcludeVec,1);
end

% Compatibility tIncMan ver2
if exist('timeExclude','var')
    if ~isfield(timeExclude,'vec')
        timeExclude.vec = zeros(length(t),1);
    end
    run.tIncMan = xor(timeExclude.vec,1);
end


if exist('userdata','var') && ~isempty(userdata)
    run.userdata = userdata;
elseif paramRequested(varargin,'userdata')
    [data,cnames,cwidth,ceditable] = stimGUI_updateUserData(run.stim,run.s,run.t);
    run.userdata.data=data;
    run.userdata.cnames=cnames;
    run.userdata.cwidth=cwidth;
    run.userdata.ceditable=ceditable;
end

% ProcInput is a special case. It has to be loaded carefully.
run.procInput = loadDataFromRun(filename,'procInput');
if isempty(run.procInput) && exist('procInput','var')
   run.procInput = procInput;
end
   

if exist('procResult','var')
    run.procResult = procResult;
elseif paramRequested(varargin,'procResult')
    run.procResult = initProcResultStruct('run');
end




% ---------------------------------------------------------
function SD = addSDData(SD)

% calculate dimensions of SDG axes
distances=[];
lst=find(SD.MeasList(:,1)>0);
ml=SD.MeasList(lst,:);
lst=find(ml(:,4)==1);

for idx=1:length(lst)
    SrcPos=SD.SrcPos(ml(lst(idx),1),:);
    DetPos=SD.DetPos(ml(lst(idx),2),:);

    dist=norm(SrcPos-DetPos);
    distances=[distances; dist];
end

meanSD=mean(distances);

SD.xmin = min( [SD.SrcPos(:,1); SD.DetPos(:,1)] -1/2*meanSD);
SD.xmax = max( [SD.SrcPos(:,1); SD.DetPos(:,1)] +1/2*meanSD);
SD.ymin = min( [SD.SrcPos(:,2); SD.DetPos(:,2)] -1/2*meanSD);
SD.ymax = max( [SD.SrcPos(:,2); SD.DetPos(:,2)] +1/2*meanSD);

SD.nSrcs = size(SD.SrcPos,1);
SD.nDets = size(SD.DetPos,1);

if ~isfield(SD,'MeasListAct')
    SD.MeasListAct = ones(size(SD.MeasList,1),1);
end
if ~isfield(SD,'MeasListVis')
    SD.MeasListVis = ones(size(SD.MeasList,1),1);
end



% ---------------------------------------------------------
function paramsStr = extractParams(paramsLst)

if length(paramsLst)==0
    paramsStr='''''';
    return;
end

paramsStr='';
for ii=1:length(paramsLst)
    paramsStr = strcat(paramsStr,['''' paramsLst{ii} '''']);
    if ii<length(paramsLst)
        paramsStr = strcat(paramsStr,',');
    end
end



% ---------------------------------------------------------
function B=paramRequested(paramsLst, P)

B=0;
if isempty(paramsLst)
    B=1;
    return;
end
for ii=1:length(paramsLst)
    if strcmp(P,paramsLst{ii})
        B=1; break;
    end
end

