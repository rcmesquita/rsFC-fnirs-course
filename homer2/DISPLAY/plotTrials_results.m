function plotTrials_results( yTrials, tHRF, SD )

nS = length(yTrials);
S = [];
for ii=1:nS
    S{ii} = num2str(ii);
end

[selection,ok]=listdlg( 'liststring', S,'selectionmode','single','promptstring','Plot Trials for Stim Condition');
if ok==1    
    plotProbeGUI( yTrials(selection).yblk, tHRF, SD );
end
