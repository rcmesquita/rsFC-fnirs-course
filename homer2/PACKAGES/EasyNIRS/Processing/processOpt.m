function processOpt(filepath)

% Generates default processOpt.cfg file. 
% Note that fprintf outputs formatted text where some characters 
% are special characters - such as '%'. In order to write a 
% literal '%' you need to type '%%' in fprintf argument string 
% (2nd argument).
% 
% $Log: %
% 

slashes = [findstr(filepath,'/') findstr(filepath,'\')];
if(~isempty(slashes))
    filename = ['.' filepath(slashes(end):end)];
end
fid=fopen(filename,'w');
fprintf(fid,'%% test 1\n');
fprintf(fid,'%% test 2\n');
fprintf(fid,'@ hmrIntensity2OD dod (d\n');
fprintf(fid,'@ enPCAFilter #[dod,svs,nSV] (dod,SD,tIncMan nSV %%0.1f 0\n');
fprintf(fid,'@ hmrMotionArtifact tIncAuto (dod,t,SD,tIncMan tMotion %%0.1f 0.5 tMask %%0.1f 1 STDEVthresh %%0.1f 50 AMPthresh %%0.1f 5\n');
fprintf(fid,'@ enStimRejection [s,tRangeStimReject] (t,s,tIncAuto,tIncMan tRange %%0.1f_%%0.1f -5_10\n');
fprintf(fid,'@ hmrBandpassFilt dod (dod,t hpf %%0.3f 0 lpf %%0.1f 3\n');
fprintf(fid,'@ hmrOD2Conc dc (dod,SD ppf %%0.1f_%%0.1f 6_6\n');
fprintf(fid,'@ enStimIncData_varargin [s,nFuncParam0,funcParam0,funcParamFormat0,funcParamVal0] (s,t,userdata *\n');
fprintf(fid,'@ hmrBlockAvg [dcAvg,dcAvgStd,tHRF,nTrials,dcSum2] (dc,s,t trange %%0.1f_%%0.1f -5_30\n');
fclose(fid);
