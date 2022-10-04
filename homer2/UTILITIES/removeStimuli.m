% function [s,tActAuto,p] = removeStimuli(d, t, s, trange, trmv, noiseThresh, mlact, tActMan)
%
% Remove stimuli and mark periods of time that are influenced by a motion
% artifact that exceeds a specified threshold in any of the active channels
%
% INPUT
% d - intensity data (#time points x #channels)
% t - time vector (#time points x 1)
% s - stim vector (#time points x 1)
% trange - time range over which to remove a stim if near a motion artifact
%          ( [tmin tmax] )
% trmv - time window over which to mark data for removal ( [tmin tmax] )
% noiseThresh - threshold above which noise in the data is considered a
%               motion artifact
% mlact - the active measurement list (#channels x 1) with a value of 1 for
%         an active channel and 0 for inactive
% tActMan - A list of 1's indicating which time points are included in the
%           analysis (#time points x 1). A 0 indicates it is excluded and
%           the stimuli within trange are removed.
%
% OUTPUT
% s - the revised stim vector
% tActAuto - the data points which are considered good indicated by a 1 and
%         are considered influenced by a motion artifact indicated by a 0
% p - ???
%
% DEPENDENCIES
% None
%
% TO DO
% Gracefully handle when lstAct is empty.
%
%
function [s,tActAuto,p] = removeStimuli(d, t, s, trange, trmv, noiseThresh, mlact, tActMan)


if ~exist('mlact')
    mlact = ones(size(d,2),1);
elseif isempty(mlact)
    mlact = ones(size(d,2),1);
end
lstAct = find(mlact==1);

if ~exist('tActMan')
    tActMan = [];
end
if isempty(tActMan)
    tActMan = ones(length(t),1);
end

% Find locations where signal changes more than x percent
dd = max( abs(diff(d(:,lstAct),1,1)) ,[],2);
ro = find(dd > noiseThresh);


dt = t(2)-t(1);

sorig = s;
rmvd = zeros(size(s));

% zero the stimuli occuring at manually removed time points
% and check if within trange of removed time points
s = s.*tActMan;
lstStim = find(s==1);
for iStim = 1:length(lstStim)
    foo = tActMan( find(t>(t(lstStim(iStim))+trange(1)),1):find(t>(t(lstStim(iStim))+trange(2)),1));
    if ~isempty(find(foo==0))
        s(lstStim(iStim))=0;
    end
end


for idx=1:size(ro,1)
    istart = round(ro(idx)-trange(2)/dt);
    istop = round(ro(idx)-trange(1)/dt);
    if istart<1
        istart = 1;
    elseif istart>size(s,1)
        istart = size(s,1);
    end
    if istop<1
        istop = 1;
    elseif istop>size(s,1)
        istop = size(s,1);
    end
    s(istart:istop)=0;
    
    istartrm = round(ro(idx)+trmv(1)/dt);
    istoprm = round(ro(idx)+trmv(2)/dt);
    if istartrm<1
        istartrm = 1;
    elseif istartrm>size(s,1)
        istartrm = size(s,1);
    end
    if istoprm<1
        istoprm = 1;
    elseif istoprm>size(s,1)
        istoprm = size(s,1);
    end
    rmvd(istartrm:istoprm)=1;
end

% Calc actually active timepoints
% DAB (09-11-20) I don't like this
% slist = find(sorig==1);
% for idx = 1:size(slist)
%     istart = round(slist(idx)+trange(1)/dt);
%     istop = round(slist(idx)+trange(2)/dt);
%     if istart<1
%         istart = 1;
%     elseif istart>size(s,1)
%         istart = size(s,1);
%     end
%     if istop<1
%         istop = 1;
%     elseif istop>size(s,1)
%         istop = size(s,1);
%     end
%     rmvd(istart:istop)=(s(slist(idx)) == 0);
% end

tActAuto = (rmvd == 0);

%stupid fix
rmvd(1) = 0;
rmvd(end) = 0;

% The rest is for visualizing what has been removed

srmlist = find((sorig - s)==1);
lftr = find(diff(rmvd)==1);
rgtr = find(diff(rmvd)==-1);

slist = find(s==1);


rrem = 100*size(srmlist,1)/(size(slist,1)+size(srmlist,1));
p = rrem;

if size(lftr)~=size(rgtr)
    disp('Error');
end

if isempty(lstAct)
    disp('Did not plot removeStimuli because MeasListAct=0' )
    return
end

figure;
plot(t,d(:,lstAct));
title([num2str(rrem,2) '% of stimuli removed']);
ylim = get(gca,'YLim');

for idx=1:size(lftr)
    xv = [t(lftr(idx)); t(rgtr(idx)); t(rgtr(idx)); t(lftr(idx))];
    yv = [ylim(1); ylim(1); ylim(2); ylim(2)];
    patch(xv,yv,'r','FaceAlpha',0.25,'EdgeColor','none');
    
    %rectangle('position',[t(lft(idx)) ylim(1) t(rgt(idx))-t(lft(idx)) ylim(2)-ylim(1)],'FaceColor','r');
    %alpha(gco,0.5);
end

lftr = find(diff(tActMan)==-1);
rgtr = find(diff(tActMan)==1);
for idx=1:size(lftr)
    xv = [t(lftr(idx)); t(rgtr(idx)); t(rgtr(idx)); t(lftr(idx))];
    yv = [ylim(1); ylim(1); ylim(2); ylim(2)];
    hp=patch(xv,yv,'c','FaceAlpha',0.25,'EdgeColor','none'); 
    set(hp,'tag','toRemove')
end

for idx=1:size(slist)
    xv = [t(slist(idx)); t(slist(idx))];
    yv = [ylim(1); ylim(2)];
    line(xv,yv,'Color','r','LineWidth',2);
end
for idx=1:size(srmlist)
    xv = [t(srmlist(idx)); t(srmlist(idx))];
    yv = [ylim(1); ylim(2)];
    line(xv,yv,'Color','r','LineStyle','--','LineWidth',2);
end








