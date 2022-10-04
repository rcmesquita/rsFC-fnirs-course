function CondTblEntry = stimCondInitTblEntry(filename)

MSGID = 'MATLAB:load:variableNotFound';
warning('off', MSGID);

CondTblEntry = {};

load(filename,'-mat','s','CondNames');
if exist('CondNames','var')
    [CondNames nTrials] = stimCondInit(s,CondNames);
else
    [CondNames nTrials] = stimCondInit(s);
end
CondTblEntry = [filename {nTrials} CondNames];
