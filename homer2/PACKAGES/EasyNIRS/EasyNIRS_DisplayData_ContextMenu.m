function EasyNIRS_DisplayData_ContextMenu( flag )
global hmr

t = get(gco,'xdata')';
if flag==1
    [filenm, pathnm] = uiputfile( '*.txt', 'Export single trace to:' );
    if filenm==0
        return
    end

    d = get(gco,'ydata')';
    tag{1} = get(gco,'tag');
elseif flag==2
    [filenm, pathnm] = uiputfile( '*.txt', 'Export all visible traces to:' );
    if filenm==0
        return
    end

    hl = findall(gca,'Type','line');
    d = [];
    tag = [];
    jj = 0;
    for ii=length(hl):-1:1
        foos = get(hl(ii),'tag');
        if ~isempty(foos)
            if foos(1)=='S'
                jj = jj + 1;
                d(:,jj) = get(hl(ii),'ydata');
                tag{jj} = get(hl(ii),'tag');
            end
        end
    end
end

% Save
wd=cd;
cd(pathnm);

fp=fopen(filenm,'w');
fprintf(fp,'time\t');
fprintf(fp,'%s\t',tag{1:end});
fprintf(fp,'\n');
fclose(fp);

d = [t d];
save(filenm,'d','-ascii','-tabs','-append')

cd(wd)



