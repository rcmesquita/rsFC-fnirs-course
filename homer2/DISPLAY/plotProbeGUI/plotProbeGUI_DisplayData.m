function plotProbeGUI_DisplayData()
global hmr

displayAxes = hmr.displayAxes;

axes(displayAxes(1))
cla

% DISPLAY DATA
if isfield( hmr, 'plotLst' )

    % transform list for concentration data
    lst = hmr.plotLst;
    if ndims(hmr.y)==3
        lst2 = [];
        lst3 = find(hmr.SD.MeasList(:,4)==1);
        for ii=1:length(lst);
            lst2(ii) = find(hmr.SD.MeasList(lst3,1)==hmr.SD.MeasList(lst(ii),1) & ...
                hmr.SD.MeasList(lst3,2)==hmr.SD.MeasList(lst(ii),2) );
        end
        plotLst = lst2;
    else
        plotLst = lst;
    end

    lst = find(hmr.SD.MeasListAct(plotLst)==1);
    if ~isempty(lst)
        cla
        hold on
        if 0;%hmr.DisplayNormalized
            for ii=length(lst):-1:1
                h=plot(hmr.t,...
                    (hmr.y( :, plotLst(lst(ii)) ) -...
                    mean(hmr.y( :, plotLst(lst(ii))), 1)) );
                set(h,'color',hmr.color(lst(ii),:));
            end
        else
            if ndims(hmr.y)==2
                for ii=length(lst):-1:1
                    h=plot(hmr.t,...
                        hmr.y( :, plotLst(lst(ii))) );
                    set(h,'color',hmr.color(lst(ii),:));
                    set(h,'linewidth',2);
                end
            else
                for ii=length(lst):-1:1
                    if hmr.plotHbX(1)
                        h=plot(hmr.t,...
                            squeeze(hmr.y( :, 1, plotLst(lst(ii)),:)) );
                        set(h,'color',hmr.color(lst(ii),:));
                        set(h,'linewidth',2);
                        if ~isempty(hmr.yModel) & hmr.plotModel
                            h=plot(hmr.t,...
                                squeeze(hmr.yModel( :, 1, plotLst(lst(ii)),hmr.displayModel)) );
                            set(h,'color',hmr.color(lst(ii),:));
                        end
                    end
                    if hmr.plotHbX(2) & size(hmr.y,2)>1
                        h=plot(hmr.t,...
                            squeeze(hmr.y( :, 2, plotLst(lst(ii)),:)), '--' );
                        set(h,'color',hmr.color(lst(ii),:));
                        set(h,'linewidth',2);
                        if ~isempty(hmr.yModel) & hmr.plotModel
                            h=plot(hmr.t,...
                                squeeze(hmr.yModel( :, 2, plotLst(lst(ii)),hmr.displayModel)), '--' );
                            set(h,'color',hmr.color(lst(ii),:));
                        end
                    end
                end
            end
        end
        if ~isempty(hmr.s) & hmr.plotStim
            yrange = ylim();
            plot(hmr.t, hmr.s*yrange(2), '-.' );
        end
        hold off
        %             if cw6info.autoscale==0 & ~(cw6info.DisplayNormalized==1 & cw6info.Yrange(1)>0)
        %                 ylim( cw6info.Yrange );
        %             elseif cw6info.autoscale==0 & cw6info.DisplayNormalized==1
        %                 ylim( cw6info.YrangeDOD );
        %             else
        %                 ylim('auto')
        %             end
    else
        cla %this use to be clf but that crashed
    end
end


%xlim( cw6info.time([firstR cw6info.nRecords]) )
set(gca,'ygrid','on')



