function stimGUI_DisplayData(userdata_curr_row)
global stim

if(~stimGUI_Active())
    return;
end

if ~exist('userdata_curr_row')
    userdata_curr_row=0;
end

axes(stim.handles.axes1)
cla
hold on 

if(~isempty(stim.aux))
    h=plot(stim.t, stim.aux(:,stim.iAux),'color','k');
end
[lstR,lstC] = find(abs(stim.s)==1);
[lstR,k] = sort(lstR);
lstC = lstC(k);
nStim = length(lstR);
yy = ylim();
stim.Lines=repmat(struct('handle',0,'color',[]),length(lstR),1);
idxLg=[];
hLg=[];
kk=1;
for ii=1:nStim
    if(stim.s(lstR(ii),lstC(ii))==1)
        stim.Lines(ii).handle = plot([1 1]*stim.t(lstR(ii)), yy,'-');
    elseif(stim.s(lstR(ii),lstC(ii))==-1)
        stim.Lines(ii).handle = plot([1 1]*stim.t(lstR(ii)), yy,'--');
    end

    iCond = find(stim.CondRunIdx(stim.iFile,:)==lstC(ii));
    stim.Lines(ii).color = stim.CondColTbl(iCond,1:3);
    try 
        set(stim.Lines(ii).handle,'color',stim.Lines(ii).color);
    catch
        disp(sprintf('ERROR'));
    end
    if ii==userdata_curr_row
        set(stim.Lines(ii).handle,'linewidth',stim.linewidthHighl);
    else
        set(stim.Lines(ii).handle,'linewidth',stim.linewidthReg);
    end

    % Check which conditions are represented in S for the conditions 
    % legend display. 
    if isempty(find(idxLg == iCond))
        hLg(kk) = plot([1 1]*stim.t(1), yy,'-','color',stim.Lines(ii).color,'visible','off');
        idxLg(kk) = iCond;
        kk=kk+1;
    end
end

if get(stim.handles.radiobuttonZoom,'value')==1    % Zoom
    h=zoom;
    set(h,'ButtonDownFilter',@myZoom_callback);
    set(h,'enable','on')
    set(stim.handles.axes1,'Tag','axes1')

    
elseif get(stim.handles.radiobuttonStim,'value')==1 % Stim
    zoom off
    set(stim.handles.axes1,'ButtonDownFcn', 'stimGUI_DisplayData_StimCallback()');
    set(get(stim.handles.axes1,'children'), 'ButtonDownFcn', 'stimGUI_DisplayData_StimCallback()');
end


if(~isfield(stim,'userdata') | isempty(stim.userdata))
    data = repmat({0,''},length(lstR),1);
    for ii=1:length(lstR)
        data{ii,1} = stim.t(lstR(ii));
    end
    cnames={'1'};
    cwidth={100};
    ceditable=logical([1]);
elseif(isfield(stim,'userdata') & isfield(stim.userdata,'data') & isempty(stim.userdata.data))
    ncols = length(stim.userdata.cnames);
    data = [repmat({0},length(lstR),1) repmat({''},length(lstR),ncols)];
    for ii=1:length(lstR)
        data{ii,1} = stim.t(lstR(ii));
    end
    cnames    = stim.userdata.cnames;
    cwidth    = stim.userdata.cwidth;
    ceditable = stim.userdata.ceditable;
else
    data0     = stim.userdata.data;
    cnames    = stim.userdata.cnames;
    cwidth    = stim.userdata.cwidth;
    ceditable = stim.userdata.ceditable;

    ncols = size(data0,2);
    data  = cell(0,ncols);

    % Find which data to add/delete
    for ii=1:length(lstR)
        % Search for stim in current table
        data(ii,:) = [{0} repmat({''},1,ncols-1)];
        data{ii,1} = stim.t(lstR(ii));
        for jj=1:size(data0,1)
            tol=0.001; % ms tolerance
            if abs(data{ii,1}-data0{jj,1})<tol
                data(ii,:) = data0(jj,:);
            end
        end
    end
end
tableUserData_Update(stim.handles,data,cnames,cwidth,ceditable);

% Update legend
if(ishandle(stim.LegendHdl))
    delete(stim.LegendHdl);
    stim.LegendHdl = -1;
end
[idxLg,k] = sort(idxLg);
hLg = hLg(k);
if ~isempty(hLg)
    stim.LegendHdl = legend(hLg,stim.CondNamesAct(idxLg));
end



% ------------------------------------------------
function [flag] = myZoom_callback(obj,event_obj)

if strcmpi( get(obj,'Tag'), 'axes1' )
    flag = 0;
else
    flag = 1;
end

