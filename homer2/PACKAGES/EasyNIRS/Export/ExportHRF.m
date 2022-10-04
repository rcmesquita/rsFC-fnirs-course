function ExportHRF(subj,condNames,filename,mode)

COND_HDR_ENABLE = 1;
HB_CH_HDR_ENABLE = 2;
COND_VERTICAL = 4;
DATA_VERTICAL = 8;


SD         = subj.procInput.SD;
if ~exist('filename','var') || isempty(filename)
    filename = [subj.name '_HRF.txt'];
end
if ~exist('mode','var') || isempty(mode)
    mode = 0;
end

fid=fopen(filename,'w');
dcAvg = subj.procResult.dcAvg;
nCond = size(dcAvg,4);
nCh = length(find(SD.MeasList(:,4)==1));
nTp = size(subj.procResult.dcAvg,1);
nHb = 3;

fprintf(fid, 'Subject %s\n', subj.name);
SDpairs=SD.MeasList(SD.MeasList(:, 4)==1, 1:2);

if bitand(mode,COND_VERTICAL)
    fclose(fid);
    for iCond=1:nCond
        fid=fopen(filename, 'a');
        % Write out header info: condition name
        if bitand(mode,COND_HDR_ENABLE)
            fprintf(fid,'\nStim Condition:   %s\n',condNames{iCond});
        end
        
        % Write out header info: channel # and Hb type
        if bitand(mode,HB_CH_HDR_ENABLE)
            for iCh=1:nCh
                for iHb=1:nHb
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
            fprintf(fid,'\n');
        end
        fclose(fid);
        
        dlmwrite(filename, reshape(dcAvg(:, :, :, iCond), nTp, nHb*nCh), '-append', 'delimiter','\t')
        
        
    end
    
    
else
    
    % Write out header info: condition name
    if bitand(mode,COND_HDR_ENABLE)
        for iCond=1:nCond
            fprintf(fid,'Stim Condition: %s',condNames{iCond});
            for iCh=1:nCh
                for iHb=1:nHb
                    fprintf(fid,'\t\t');
                end
            end
            fprintf(fid,'\t\t');
        end
        fprintf(fid,'\n');
    end
    
    
    % Write out header info: channel # and Hb type
    if bitand(mode,HB_CH_HDR_ENABLE)
        
        for iCond=1:nCond
            for iCh=1:nCh
                for iHb=1:nHb
                    switch(iHb)
                        case 1
                            fprintf(fid,'HbO,%s,%s\t\t',num2str(SDpairs(iCh,1)), ...
                                num2str(SDpairs(iCh,2)) );
                        case 2
                            fprintf(fid,'HbR,%s,%s\t\t',num2str(SDpairs(iCh,1)), ...
                                num2str(SDpairs(iCh,2)) );
                        case 3
                            fprintf(fid,'HbT,%s,%s\t\t',num2str(SDpairs(iCh,1)), ...
                                num2str(SDpairs(iCh,2)) );
                    end
                end
            end
            fprintf(fid,'\t\t');
        end
        fprintf(fid,'\n');
    end
    
    
    % Write out the data itself
    for iData=1:nTp
        
        for iCond=1:size(dcAvg,4)
            for iCh=1:nCh
                for iHb=1:nHb
                    fprintf(fid,'%s\t\t',num2str(dcAvg(iData,iHb,iCh,iCond)));
                end
            end
            fprintf(fid,'\t\t');
        end
        fprintf(fid,'\n');
    end
    
    fclose(fid);
end



