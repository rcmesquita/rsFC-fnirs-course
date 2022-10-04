function po = NORMALIZEfilter(t,po,const)
% Take this signal, and try to normalize each segment
% where segment size is const, time is t, and signal is po
%
totalT = t(end);
maxpo = mean(po) + 2*std(po);
for ti = 0:const:(totalT-const)
    f =find(t>=ti);
    ind1 = f(1);
    f = find(t<(ti+const));
    ind2 = f(end);
    snip=po(ind1:ind2);
    maxsnip=mean(snip) + 2*std(snip);
    po(ind1:ind2)=snip*maxpo/maxsnip;
end
return