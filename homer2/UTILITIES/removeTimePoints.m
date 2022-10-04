% function tAct = removeTimePoints( t, tAct )
%
% This function uses mouse inputs on the current axis to specify which
% time points should be excluded. The user left clicks the range in time on
% the current axis and a cyan patch appears to indicate that that time
% range has been marked for exclusion. The user can cancel after the first
% left click with a right click. The user can right click on a cyan patch
% to remove it. The function returns when the user presses <return>
%
% INPUTS
% t - time vector (#time points x 1)
% tAct - A vector of 1's indicating if the time point is included for
%        future analysis. 0's indicate it is to be excluded. 
%        (#time points x 1, OPTIONAL)
%
% OUTPUTS
% tAct - A vector of 1's indicating if the time point is included for
%        future analysis. 0's indicate it is to be excluded. 
%        (#time points x 1)
%
% DEPENDENCIES
% None
%
% TO DO
%
%


function tAct = removeTimePoints( t, tAct)
x1 = -999;
x2 = -999;
yy = ylim();

if ~exist('tAct')
    tAct=[];
end
if isempty(tAct)
    tAct = ones(length(t),1);
end

while ~isempty(x1) & ~isempty(x2)
    x1 = -999;
    x2 = -999;
    but2 = 1;
    
    % get first coordinate
    [x1,y1,but1] = ginput(1);
    if but1==1
        hl=line([x1 x1],[yy(1) yy(2)]);
        set(hl,'color','c')
    end
    if ~isempty(x1) & but1==1
        % get second coordinate
        [x2,y2,but2] = ginput(1);
        delete(hl);
        if but1==1 & but2==1
            xv = [x1 x2 x2 x1];
            yv = [yy(1) yy(1) yy(2) yy(2)];
            hp=patch(xv,yv,'c','FaceAlpha',0.25,'EdgeColor','none');
            set(hp,'tag','toRemove')
            tAct(find(t>x1,1):find(t>x2,1)) = 0;
        end
    end
    if but1==3 | but2==3
        if strcmp(get(gco,'type'),'patch')
            if strcmp(get(gco,'tag'),'toRemove')
                ch = menu('Remove patch','Yes','No');
                if ch==1
                    xx = unique(get(gco,'xdata'));
                    tAct( find(t>xx(1),1):find(t>xx(2),1) ) = 1;
                    delete(gco)
                end
            end
        elseif x2==-999
            zoom on
            ch = menu('Stop Zoom Mode','Okay');
            zoom off            
        end
    end
end

