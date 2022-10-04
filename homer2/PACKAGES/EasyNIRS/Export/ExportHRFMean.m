function dcAvgMeanAll = ExportHRFMean(group,tMin,tMax,condNames,filename)

dcAvgMeanAll = [];

SD         = group.procInput.SD;
grpAvgPass = group.procResult.grpAvgPass;

kk=1;
for ii=1:length(group(1).subjs)
    dcAvg   = group(1).subjs(ii).procResult.dcAvg;
    tHRF    = group(1).subjs(ii).procResult.tHRF;
    nTrials = group(1).subjs(ii).procResult.nTrials;    
    if ~isempty(dcAvg) && ~isempty(tHRF)
        [dcAvgMeanAll(kk).dcAvgMean dcAvgMeanAll(kk).err] = ...
                  meanResponce(dcAvg,tHRF,tMin,tMax);
        dcAvgMeanAll(kk).subjId = group(1).subjs(ii).name;
        dcAvgMeanAll(kk).nTrials = nTrials;
        kk=kk+1;
    end
end
if isempty(dcAvgMeanAll)
    menu('You need to perform the GROUP analysis before this will export results.','OK');
    return;
end
for ii=1:length(dcAvgMeanAll)
    if dcAvgMeanAll(ii).err>0
        switch dcAvgMeanAll(ii).err
        case 2
           menu('tMin is outside tHRF range','OK');
        case 3
           menu('tMax is outside tHRF range','OK');
        case 4
           menu('tMin should be smaller or equal to tMax','OK');
        end
        return;
    end
end
grpAvgPass = group(1).procResult.grpAvgPass;
writeMeanResponce(dcAvgMeanAll,SD,grpAvgPass,condNames,filename);




% -------------------------------------------------------------------
function [dcAvgMean err] = meanResponce(dcAvg,tHRF,tMin,tMax)

dcAvgMean = [];
err = 0;
if isempty(tHRF)
    err=1;  return;
end
if tMin<tHRF(1) || tMin>tHRF(end)
    err=2;  return;
end
if tMax<tHRF(1) || tMax>tHRF(end)
    err=3;  return;
end
if tMin>tMax
    err=4;  return;
end

for iHb=1:size(dcAvg,2)
    for iCh=1:size(dcAvg,3)
        for iCond=1:size(dcAvg,4)
            lst = find(tHRF>=tMin & tHRF<=tMax);
            dcAvgMean(iHb,iCh,iCond) = mean(dcAvg(lst,iHb,iCh,iCond));
        end
    end
end


% -------------------------------------------------------------------
function writePassedIncCriteria(dcAvgMeanAll,SD,grpAvgPass,condNames,fid)

nCh = length(find(SD.MeasList(:,4)==1));
SDpairs=SD.MeasList(SD.MeasList(:, 4)==1, 1:2);

fprintf(fid,'=========================\n');
fprintf(fid,'Passed Inclusion Criteria\n');
fprintf(fid,'=========================\n');
fprintf(fid,'Condition\tSubjectID\t');
for iCh=1:nCh
    fprintf(fid,'%s,%s\t',num2str(SDpairs(iCh,1)), ...
                          num2str(SDpairs(iCh,2)) );
end
fprintf(fid,'\n\n');
if ~isempty(grpAvgPass)
    for iSubj=1:length(dcAvgMeanAll)
        dcAvgMean = dcAvgMeanAll(iSubj).dcAvgMean;
        subjId    = dcAvgMeanAll(iSubj).subjId;
        nTrials   = dcAvgMeanAll(iSubj).nTrials;
        for iCond=1:size(dcAvgMean,3)
          if(nTrials(:,iCond)>0)
                fprintf(fid,'%s\t',condNames{iCond});                
                fprintf(fid,'%s\t',subjId);
                
                for iCh=1:size(dcAvgMean,2)
                    fprintf(fid,'%d\t',grpAvgPass(iCh,iCond,iSubj));
                end
                fprintf(fid,'\n');
            end
        end
    end
end
fprintf(fid,'\n\n');


% -------------------------------------------------------------------
function writeMeanResponce(dcAvgMeanAll,SD,grpAvgPass,condNames,filename)

fid=fopen(filename,'w');
nCh = length(find(SD.MeasList(:,4)==1));
SDpairs=SD.MeasList(SD.MeasList(:, 4)==1, 1:2);

writePassedIncCriteria(dcAvgMeanAll,SD,grpAvgPass,condNames,fid);

%%%% Write column names
fprintf(fid,'=============\n');
fprintf(fid,'Mean Response\n');
fprintf(fid,'=============\n');
fprintf(fid,'Condition\tSubjectID\t');
for iCh=1:nCh
    for iHb=1:3
        switch(iHb)
        case 1
            fprintf(fid,'HbO,%s,%s\t',num2str(SDpairs(iCh,1)), ...
                                      num2str(SDpairs(iCh,2)) );
        case 2
            fprintf(fid,'HbR,%s,%s\t',num2str(SDpairs(iCh,1)), ...
                                      num2str(SDpairs(iCh,2)) );
        case 3
            fprintf(fid,'HbT,%s,%s\t',num2str(SDpairs(iCh,1)), ...
                                      num2str(SDpairs(iCh,2)) );
        end
    end
end
fprintf(fid,'\n\n');

%%%% Write each rwo: condition name followed by data (i.e. mean response)
for iSubj=1:length(dcAvgMeanAll)
    dcAvgMean = dcAvgMeanAll(iSubj).dcAvgMean;
    subjId    = dcAvgMeanAll(iSubj).subjId;
    nTrials   = dcAvgMeanAll(iSubj).nTrials;
    for iCond=1:size(dcAvgMean,3)
        if(sum(nTrials(:,iCond))>0)      
            fprintf(fid,'%s\t',condNames{iCond});
            fprintf(fid,'%s\t',subjId);

            for iCh=1:size(dcAvgMean,2)
                for iHb=1:size(dcAvgMean,1)
                    if isempty(grpAvgPass) || grpAvgPass(iCh,iCond,iSubj)
                        fprintf(fid,'%s\t',num2str(dcAvgMean(iHb,iCh,iCond)));
                    else
                        fprintf(fid,'%s\t','  ');
                    end
                end
            end
            fprintf(fid,'\n');
        end
    end
end

fclose(fid);
