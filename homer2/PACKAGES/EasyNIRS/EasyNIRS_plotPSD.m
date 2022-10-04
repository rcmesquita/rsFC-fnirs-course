function EasyNIRS_plotPSD()
global hmr


sclConc = 1e6; % convert Conc from Molar to uMolar

hf=figure;
set(hf,'color',[1 1 1]);


% DISPLAY DATA
%subplot(1,2,1)
axes('position',[0.1 0.1 0.5 0.8])
if isfield( hmr, 'plotLst' )

    lst = hmr.plotLst;
    if hmr.plotConc==1     % transform list for concentration data
        lst2 = [];
        lst3 = find(hmr.SD.MeasList(:,4)==1);
        for ii=1:length(lst);
            lst2(ii) = find(hmr.SD.MeasList(lst3,1)==hmr.SD.MeasList(lst(ii),1) & ...
                hmr.SD.MeasList(lst3,2)==hmr.SD.MeasList(lst(ii),2) );
        end
        plotLst = lst2;
    else                   % transform list for wavelength data
        plotLst = [];
        for ii = 1:length(hmr.plotLambdaLst)
            lst3 = find(hmr.SD.MeasList(:,4)==hmr.plotLambdaLst(ii));
            for jj=1:length(lst);
                plotLst(end+1) = lst3( find(hmr.SD.MeasList(lst3,1)==hmr.SD.MeasList(lst(jj),1) & ...
                    hmr.SD.MeasList(lst3,2)==hmr.SD.MeasList(lst(jj),2) ) );
            end
        end
    end

    
    % select results to plot
    if hmr.plotRaw==1
        d = hmr.d;
    elseif hmr.plotOD==1
            d = hmr.procResult.dod;
    elseif hmr.plotConc==1
            d = hmr.procResult.dc * sclConc;
    end
    t = hmr.t;
    
    
    % plot results
    lst = find(hmr.SD.MeasListAct(plotLst)==1);
    if ~isempty(lst)
        hold on
        
        if ndims(d)==2   % plot d or dod
            if length(hmr.plotLambdaLst)==1
                for ii=length(lst):-1:1
                    Fs = 1/(t(2)-t(1));
                    hw = spectrum.welch;    % Create a Welch spectral estimator.  
                    hw.SegmentLength = 100*Fs;
                    Hpsd = psd(hw,d(:,plotLst(lst(ii))),'Fs',Fs);             % Calculate the PSD 
                    h=plot(Hpsd.Frequencies, 20*log10(Hpsd.Data));                          % Plot the PSD.
                    set(h,'color',hmr.color(lst(ii),:));
                    set(h,'linewidth',2);
                end
            elseif length(hmr.plotLambdaLst)==2
                nCh = length(lst)/2;
                for ii=nCh:-1:1
                    Fs = 1/(t(2)-t(1));
                    hw = spectrum.welch;    % Create a Welch spectral estimator.     
                    hw.SegmentLength = 100*Fs;
                    Hpsd = psd(hw,d(:,plotLst(lst(ii))),'Fs',Fs);             % Calculate the PSD 
                    h=plot(Hpsd.Frequencies, 20*log10(Hpsd.Data));                          % Plot the PSD.
                    set(h,'color',hmr.color(lst(ii),:));
                    set(h,'linewidth',2);
                    
                    Hpsd = psd(hw,d(:,plotLst(lst(ii+nCh))),'Fs',Fs);             % Calculate the PSD 
                    h=plot(Hpsd.Frequencies, 20*log10(Hpsd.Data),':');                          % Plot the PSD.
                    set(h,'color',hmr.color(lst(ii),:));
                    set(h,'linewidth',2);
                end
            end
        else            % plot dc
            for iConc = 1:length(hmr.plotConcLst)
                for ii=length(lst):-1:1
                    Fs = 1/(t(2)-t(1));
                    hw = spectrum.welch;    % Create a Welch spectral estimator.  
                    hw.segmentLength = Fs*40;
                    Hpsd = psd(hw,d(:,hmr.plotConcLst(iConc), plotLst(lst(ii))),'Fs',Fs);             % Calculate the PSD 
                    h=plot(Hpsd.Frequencies, 20*log10(Hpsd.Data));                          % Plot the PSD.
                    set(h,'color',hmr.color(lst(ii),:));
                    set(h,'linewidth',2);
                    if iConc==2
                        set(h,'linestyle',':');
                    end
                end
            end
        end
        
        
        hold off
        set(gca,'yscale','linear');
        title( Hpsd.Name );
        ylabel( 'Power/Frequency (dB/Hz)' )
        xlabel( 'Frequency (Hz)' )

    else
        cla %this use to be clf but that crashed
    end
end


% DISPLAY SDG
%subplot(1,2,2)
axes('position',[0.65 0.05 0.3 0.9])

SD = hmr.SD;

cla
axis(gca, [SD.xmin SD.xmax SD.ymin SD.ymax]);
axis(gca, 'image')
set(gca,'xticklabel','')
set(gca,'yticklabel','')
set(gca,'ygrid','off')
axis off


lst=find(SD.MeasList(:,1)>0);
ml=SD.MeasList(lst,:);
lstML = find(ml(:,4)==1); %cw6info.displayLambda);


for ii=1:length(lstML) %size(ml,1)
    h = line( [SD.SrcPos(ml(lstML(ii),1),1) SD.DetPos(ml(lstML(ii),2),1)], ...
        [SD.SrcPos(ml(lstML(ii),1),2) SD.DetPos(ml(lstML(ii),2),2)] );
    set(h,'color',[1 1 1]*0.9);
    set(h,'linewidth',4);

end


% ADD SOURCE AND DETECTOR LABELS
for idx=1:SD.nSrcs
    if ~isempty(find(SD.MeasList(:,1)==idx))
        h = text( SD.SrcPos(idx,1), SD.SrcPos(idx,2), sprintf('%c', 64+idx), 'fontweight','bold' );
    end
end
for idx=1:SD.nDets
    if ~isempty(find(SD.MeasList(:,2)==idx))
        h = text( SD.DetPos(idx,1), SD.DetPos(idx,2), sprintf('%d', idx), 'fontweight','bold' );
    end
end


% DRAW PLOT LINES
% THESE LINES HAVE TO BE THE LAST
% ITEMS ADDED TO THE AXES
% FOR CHANNEL TOGGLING TO WORK WITH
% cw6_sdgToggleLines()
if isfield( hmr, 'plot' )
    if ~isempty(hmr.plot)
        if hmr.plot(1,1)~=0
            hmr.color(end:size(hmr.plot,1),:)=0;
            for idx=size(hmr.plot,1):-1:1
                h = line( [SD.SrcPos(hmr.plot(idx,1),1) SD.DetPos(hmr.plot(idx,2),1)], ...
                    [SD.SrcPos(hmr.plot(idx,1),2) SD.DetPos(hmr.plot(idx,2),2)] );
                set(h,'color',hmr.color(idx,:));
                set(h,'linewidth',2);
                if isfield(hmr,'plotLst') && ~SD.MeasListAct(hmr.plotLst(idx))
                    set(h,'linewidth',2);
                    set(h,'linestyle','--');
                end


            end
        end
    end
end










