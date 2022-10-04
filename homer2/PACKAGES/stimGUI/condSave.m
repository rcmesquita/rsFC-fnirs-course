function condSave(CondTbl)

if isempty(CondTbl)
    return;
end

fid = fopen('./stimConditionNames.txt','w');
for iF=1:size(CondTbl,1)
    fprintf(fid,'%s\n',CondTbl{iF}{1});
    for iC=3:length(CondTbl{iF})
        fprintf(fid,'%s\n',CondTbl{iF}{iC});
    end
    fprintf(fid,'\n');
end
fclose(fid);
