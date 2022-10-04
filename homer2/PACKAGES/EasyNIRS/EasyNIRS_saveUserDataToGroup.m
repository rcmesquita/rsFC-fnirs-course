function EasyNIRS_saveUserDataToGroup()
global hmr 

i = hmr.listboxFileCurr.iGrp;
j = hmr.listboxFileCurr.iSubj;
k = hmr.listboxFileCurr.iRun;
userdata = hmr.userdata;

% The number and names of columns in userdata should be same
% for all files in a group 
for ii=1:length(hmr.group)
    for jj=1:length(hmr.group(ii).subjs)
        for kk=1:length(hmr.group(ii).subjs(jj).runs)

            load(hmr.group(ii).subjs(jj).runs(kk).filename,'userdata','s','t','-mat');
            if isempty(userdata)
                userdata = hmr.userdata;
                save(hmr.group(ii).subjs(jj).runs(kk).filename,'userdata','-mat','-append');

                run.procInput = hmr.group(ii).subjs(jj).runs(kk).procInput;
                run.userdata = userdata;
                run.t = t;
                run.s = s;
                run.procInput = EasyNIRS_ProcessOpt_Update(run);
                hmr.group(ii).subjs(jj).runs(kk).procInput = run.procInput;
                continue;
            end

            userdata1 = userdata;
            userdata2 = hmr.userdata;

            % Column was renamed in the user data table of the current file 
            % selection. Rename the corresponding column in the user data tables 
            % of all other files in the group.
            if (length(userdata1.cnames) == length(userdata2.cnames))

                userdata1.cnames = userdata2.cnames;

            % Column was added in the user data table of the current file 
            % selection. Add corresponding column in the user data tables 
            % of all other files in the group.
            elseif (length(userdata1.cnames) < length(userdata2.cnames))

                n = length(userdata2.cnames)-length(userdata1.cnames);
                T=repmat({''},size(userdata1.data,1),n);
                userdata1.data      = [userdata1.data T];
                userdata1.cnames    = userdata2.cnames;
                userdata1.cwidth    = userdata2.cwidth;
                userdata1.ceditable = userdata2.ceditable;

            % Column was deleted in the user data table of the current file 
            % selection. Delete the corresponding column in the user data 
            % tables of all other files in the group.
            elseif (length(userdata1.cnames) > length(userdata2.cnames))

                iColDel=[]; c=1;
                for iCol1=1:length(userdata1.cnames)
                    for iCol2=1:length(userdata2.cnames)
                        if strcmp(userdata1.cnames{iCol1},userdata2.cnames{iCol2})
                             iColDel(c)=iCol1; 
                             c=c+1;
                             break;
                        end
                    end
                end
                userdata1.data      = userdata1.data(:,[1,iColDel+1]);
                userdata1.cnames    = userdata1.cnames(iColDel);
                userdata1.cwidth    = userdata1.cwidth(iColDel);
                userdata1.ceditable = userdata1.ceditable(iColDel);

            end
            userdata = userdata1;
            save(hmr.group(ii).subjs(jj).runs(kk).filename,'userdata','-mat','-append');

            run.procInput = hmr.group(ii).subjs(jj).runs(kk).procInput;
            run.userdata = userdata;
            run.t = t;
            run.s = s;
            run.procInput = EasyNIRS_ProcessOpt_Update(run);
            hmr.group(ii).subjs(jj).runs(kk).procInput = run.procInput;
        end
    end
end
hmr.procInput = hmr.group(i).subjs(j).runs(k).procInput;
