function regs = buildRegressorsCSV(fname,auxLIST,headChans,foreChans,closeChans,...
    tIGNORE,poxMODE,optionFlags,TR,nSlices,csvFile,extrapox,nSVD)
%regs = buildRegressorsCSV(fname,auxLIST,headChans,foreChans,closeChans,...
%    tIGNORE,poxMODE,optionFlags,TR,nSlices,csvFile,extrapox)
%
% given a nirs file, this script will output a .csv file with as many
% regressors as possible.
%
%INPUTS:
% fname = nirs file to open
% auxLIST = [pox resp bp MRtrig] values for aux channel numbers
% headChans = array of channels that are "good" on head (halflist)
% foreChans = array of channels that are "good" on forehead (could be
%             empty) (halflist)
% closeChans = array of close separation channels that are "good"
%             (halflist)
% tIGNORE = how many seconds to skip of the MR trigger channel
% poxMODE = 'TTL' or 'pulseox'
% optionFlags = [poxOnOff siemensPoxOnOff respOnOff bpOnOff headerOnOff sliceTimingOnOff]
% siemensPox = filename for siemen's pox data if available
% TR = size of TR in seconds
% nSlices = number of slices to cut the TR into
% csvFile = filename to output - if empty, no CSV file will be generated
% extrapox = if not empty, this is a siemens file with the pox data
% nSVD = number of SVD components to use (default = 5)
%
%OUTPUTS:
% regs - a datastructure containing anything this function computes
%
%CALLS: 
%  hmrIntensity2Conc.m,readPHSIOfile.m,addRegressors_HR.m,
%  addRegressors_retroicor.m,addRegressors_RR.m,fasttool_polytrendmtx.m,
%  getTTLtimes.m
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% load file
disp('Loading nirs file...');
X=load(fname,'-mat');
t=X.t;
aux=X.aux;
d=X.d;
Fs=1./diff(t(1:2));
SD=X.SD;
if sum(size(X.SD.MeasList)==size(X.ml))<2
    SD.MeasList = X.ml;
end
    
%% Extract corrected TR times
disp('Computing MR pulse times...')
nirsTR = aux(:,auxLIST(4));
TRindsAll = getTTLtimes(nirsTR);
goodTinds = find(t>=tIGNORE);
TRinds = intersect(TRindsAll,goodTinds);
if optionFlags(6)==1
    tAdd = linspace(0,TR,nSlices+1);
    TRinds2 = zeros(1,length(TRinds)*nSlices);
    counter = 1;
    for i=1:length(TRinds)
        TRtimes = t(TRinds(i)) + tAdd(1:end-1);
        for j=1:length(TRtimes)
            [m,i] = min(abs(t-TRtimes(j)));
            TRinds2(counter) = i;
            counter = counter + 1;
        end
    end
else
    % Do not correct for slice timing
    TRinds2 = TRinds;
end

%% Preprocess NIRs data (filter + raw->conc)
disp('Filtering and converting to conc...');

hpf = 0.02; % Hz
lpf = 0.20; % Hz
ppf = [6 6];
dc = hmrIntensity2Conc( d, SD, Fs, hpf, lpf, ppf );

%% Start the csv file
if ~isempty(csvFile)
    disp('Starting csv file...')
    if (optionFlags(5)==1)
        fid=fopen(csvFile,'w');
    end
else
    optionFlags(5)=0;
end

%% Compute the optical signal regressors
disp('Compute nirs regressors...')
oxyconc = squeeze(dc(:,1,:));
deoxyconc = squeeze(dc(:,2,:));
headcO = oxyconc(:,headChans);
headcD = deoxyconc(:,headChans);
forecO = oxyconc(:,foreChans);
forecD = deoxyconc(:,foreChans);
if ~exist('nSVD'),    nSVD = [];  end;
if isempty(nSVD),   nSVD = 5;   end;
[uHo,s,v] = svds(headcO,nSVD);
[uHd,s,v] = svds(headcD,nSVD);
[uFo,s,v] = svd(forecO);
[uFd,s,v] = svd(forecD);
if (optionFlags(5)==1)
    for i=1:size(uHo,2)
        fprintf(fid,'nirsHeadOxy%d,',i);
    end
    for i=1:size(uHd,2)
        fprintf(fid,'nirsHeadDeoxy%d,',i);
    end
    for i=1:size(uFo,2)
        fprintf(fid,'nirsForeheadOxy%d,',i);
    end
    for i=1:size(uFd,2)
        fprintf(fid,'nirsForeheadDeoxy%d,',i);
    end
end

%% Pulseox
if optionFlags(1)==1
    disp('Pulseox...')
    if optionFlags(2)==1 && exist('extrapox') && ~isempty(extrapox)
        % generate a TTL signal from the siemens pox data
        [pox2,tpulse,peakTimes] = readPHSIOfile(extrapox);
        pox = t*0;
        firstTR = t(TRinds(1));
        for w=1:length(peakTimes)
            [m,i] = min(abs(t-peakTimes(w)-firstTR));
            pox(i) = 1;
        end
    else
        % standard pox
        pox = aux(:,auxLIST(1));
    end
    XpoxRETRO = addRegressors_retroicor(t,pox,'card');
    [simpleHR,peakBeats,cardEnv,CVT] = addRegressors_HR(t,pox,poxMODE);
    if (optionFlags(5)==1)
        fprintf(fid,'XpoxRETRO1,XpoxRETRO2,XpoxRETRO3,XpoxRETRO4,HR,');
        if ~isempty(cardEnv)
            fprintf(fid,'cardEnv1,cardEnv2,'); 
        end
        if ~isempty(CVT)
            fprintf(fid,'CVT,');
        end
    end
else
    simpleHR = []; cardEnv =[]; XpoxRETRO=[]; CVT = [];
end
    
%% Resp
if optionFlags(3)==1
    disp('Resp...');
    resp = aux(:,auxLIST(2));
    XrespRETRO = addRegressors_retroicor(t,resp,'resp');
    [simpleRR,indpeak,RVT,RRF]=addRegressors_RR(t,resp);
    if (optionFlags(5)==1)
        fprintf(fid,'XrespRETRO1,XrespRETRO2,XrespRETRO3,XrespRETRO4,RR,RVT,RRF,');
    end
else
    simpleRR=[]; RVT=[]; RRF =[]; XrespRETRO=[];
end

%% bp
if optionFlags(4)==1
    disp('BP...');
    bp = aux(:,auxLIST(3));
    [bp_low,bp_card,bp_resp,bp_retroicor] = addRegressors_BP(t,bp);
    if (optionFlags(5)==1)
        fprintf(fid,'BP_low,BP_retroCard1,BP_retroCard2,BP_retroCard3,');
        fprintf(fid,'BP_retroCard4,BP_retroResp1,BP_retroResp2,BP_retroResp3,');
        fprintf(fid,'BP_retroResp4,');
    end
else
    bp = []; bp_low = []; bp_retroicor = [];
end

%% close separation sensors
disp('Close separation...')
Xclose =  [oxyconc(:,closeChans) deoxyconc(:,closeChans)];
if (optionFlags(5)==1) && ~isempty(Xclose)
    fprintf(fid,'CloseSep,');
end;

%% MRI Polynomial regressor
disp('Poly...');
ntrs = length(TRinds2);
order = 3;
[XPoly] = fasttool_polytrendmtx(1,ntrs,1,order);
if (optionFlags(5)==1), fprintf(fid,'Poly0,Poly1,Poly2'); end;


%% Put them all into a big bucket
disp('all regressors...');
XregressorsU = [XpoxRETRO simpleHR cardEnv CVT ...
          XrespRETRO simpleRR RVT RRF bp_low bp_retroicor Xclose];
XregressorsUnirs  = [uHo uHd uFo uFd];
Xregressors = [XregressorsUnirs(TRinds2,:) XregressorsU(TRinds2,:) XPoly];

%% Write the numerical part of the CSV file
if (optionFlags(5)==1)
    fprintf(fid,'\n');
    fclose(fid);
end
if ~isempty(csvFile)
    disp('Writing file...')
    dlmwrite(csvFile,Xregressors,'delimiter',',','-append');
    disp('Done.')
end

%% Build data structure
regs = struct('TRinds2',TRinds2,'TRinds',TRinds,'nSlices',nSlices,'t',t,...
    'Fs',Fs,'TR',TR,'fname',fname,...
    'uHo',uHo,'uHd',uHd,'uFo',uFo,'uFd',uFd,...
    'XpoxRETRO',XpoxRETRO,'simpleHR',simpleHR,'cardEnv',cardEnv,...
    'CVT',CVT,...
    'XrespRETRO',XrespRETRO,'simpleRR',simpleRR,'RVT',RVT,'RRF',RRF,...
    'bp',bp,'bp_low',bp_low,'bp_retroicor',bp_retroicor,...
    'Xclose',Xclose,'XPoly',XPoly,'Xregressors',Xregressors,...
    'XregressorsU',XregressorsU,'headcO',headcO,'headcD',...
    headcD);
