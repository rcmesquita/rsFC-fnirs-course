function EasyNIRS_DisplayData_PatchCallback( idx )
global hmr

ch = menu( 'Remove this Exclude Region?','Yes','No');
if ch==1
    t = hmr.t;
    s = hmr.s;
    p = timeExcludeRanges(hmr.tIncMan,t);
    lst = find(t>=p(idx,1) & t<=p(idx,2));
    hmr.tIncMan(lst) = 1;
    
    for i=1:size(s,2)
        lst2 = find(s(lst,i)==-1);
        hmr.s(lst(lst2),i) = 1;
    end
    
    hmr.fileChanged = 1;
    set(hmr.handles.pushbuttonSave,'visible','on')

    EasyNIRS_NIRSsignalProcessEnable('on')    
    
    EasyNIRS_DisplayData();
end
