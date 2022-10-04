function EasyNIRS_saveUserDataToCurrRun()
global hmr 

i = hmr.listboxFileCurr.iGrp;
j = hmr.listboxFileCurr.iSubj;
k = hmr.listboxFileCurr.iRun;

userdata = hmr.userdata;
save(hmr.group(i).subjs(j).runs(k).filename,'userdata','-mat','-append');
