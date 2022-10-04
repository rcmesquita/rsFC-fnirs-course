function [x_ok] = SplineCorrection_fnirs_course(x,SD,p)


%%% Motion Artefact remotion by using Spline base on doi:10.1088/0967-3334/31/5/004.
%%% INPUTS:
%%% x - Time series. It can be a vector or a mtrix. Lines are the time
%%% points and colluns should be the channels.
%%% SD - SD structure, commonly used in nirs files.
%%% p - Free paramter, it is the threshold to look for motion. It varies
%%% with the quality of the data. 
%%%
%%% OUTPUT: Corrected time series (free from motion artefacts).
%%%
%%%

% Window for spline (it has to be larger than HR oscillations)
k = round(2.5*SD.f);

W = (2*k)+1;
N = size(x,1);

for Nchan=1:size(x,2)
    for tt=k+1:N-k
        %%% first term:
        a = x(tt-k:tt+k,Nchan)'*x(tt-k:tt+k,Nchan);
        
        %%% second term:
        b = (sum(x(tt-k:tt+k,Nchan)))^2;
        b = (-1/(2*k+1))*b;
        %%% Combining
        ss(tt,Nchan) = (1/(2*k+1))*(sqrt(a+b));
    end
end

%%% Thresholding the moving standard deviation ss,
%%% I changed the criteria from the original apper
%%% It seems to be better to use a criteria based on the
%%% distribution of the ss.

%ss(find(ss<p)) = 0;
for Nchan=1:size(x,2)
    lst = find(ss(:,Nchan)<mean(ss(k+1:end,Nchan)) + p*std(ss(k+1:end,Nchan)));
    ss(lst,Nchan) = 0;
end
%%% Taking the begning and ending of each MA.

for Nchan=1:size(x,2)
    cnt=2;
    lst = find(ss(:,Nchan)>0);
    if ~isempty(lst)
        seg{Nchan}(1)=lst(1);
        
        for i=2:length(lst)
            if lst(i)-lst(i-1)>1
                seg{Nchan}(cnt) = lst(i-1);
                seg{Nchan}(cnt+1) = lst(i);
                cnt = cnt+2;
            end
        end
        seg{Nchan}(end+1)=lst(end);
    else
        seg{Nchan} = [];
    end
    
end

%%% Segmentation of the time series: x_ok and x_MA.
if exist('seg')~=0
    for Nchan=1:size(x,2)
        cnt=1;
        if size(seg{Nchan},2)>0
            for nMA=1:2:size(seg{Nchan},2)
                x_MA{Nchan}{cnt} = x(seg{Nchan}(nMA):seg{Nchan}(nMA+1),Nchan);
                cnt = cnt+1;
            end
        else
            x_MA{Nchan}=[];
        end
        
    end
    
    %%% Image to check the motion artefacts.
    if 0
        figure()
        plot(x)
        hold on
        for i=1:size(x_MA{1},2)
            
            a = x_MA{1}{i};
            
            if ~isempty(a)
                area(seg{1}(2*(i-1)+1):seg{1}(2*(i-1)+2),a);
                alpha(.1);
                ylim([min(x) max(x)]);
            end
            
            
        end
    end
    
    %%% Perform the Sppline interpolation
    %%% Note that to calculate the spline interpolation, weshould have at least
    %%% four poits (it uses a 3-order polynimo). Therefore, if we have a
    %%% motion artefact with less than three points, we do not perform the
    %%% spline, we set the value of them as zero and then correct the baseline
    %%% by adding the average of the segments adjacenct o the motion artefact.
    
    t = linspace(0,size(x,1)*SD.f,size(x,1)); %% Create vector t.
    t = t';
    pp=0.01;
    for Nchan=1:size(x,2)
        for nMA=1:size(x_MA{Nchan},2)
            lstt = seg{Nchan}(2*(nMA-1)+1):seg{Nchan}(2*(nMA-1)+2);
            if length(lstt)<=3
                x_MA_ok{Nchan}{nMA}= 0;
            else
                x_MASpline{Nchan}{nMA} = csaps(t(lstt),x_MA{Nchan}{nMA}, pp,t(lstt));
                x_MA_ok{Nchan}{nMA} = x_MA{Nchan}{nMA} - x_MASpline{Nchan}{nMA};
            end
        end
    end
    
    
    
    %%% Reconstruction of the Whole Time Series
    
    %%% Correcting for the different "baselines"
    x_ok=x;
    for Nchan=1:size(x,2)
        %close all;
        for nSeg=1:1:size(seg{Nchan},2)
            
            if nSeg==1
                t1 = 1:seg{Nchan}(nSeg); %% First Segment (Frames).
                t2 = seg{Nchan}(nSeg):seg{Nchan}(nSeg+1); % Second Segment (Frames).
                
                x1 = x(t1,Nchan);
                x2 = x_MA_ok{Nchan}{1};
                %xx_ok(t2,Nchan) = CorrectBaselineMARA(x1,x2,SD); % Second Segment corrected.
                
                
            elseif mod(nSeg,2)==0 && nSeg~= size(seg{Nchan},2)
                t1 = seg{Nchan}(nSeg-1):seg{Nchan}(nSeg); % p segment.
                t2 = seg{Nchan}(nSeg):seg{Nchan}(nSeg+1); % p+1 segment.
                
                x1 = x_ok(t1,Nchan);
                x2 = x(t2,Nchan);
                %xx_ok(t2,Nchan) = CorrectBaselineMARA(x1,x2,SD);
                
                
            elseif mod(nSeg,2) == 1
                t1 = seg{Nchan}(nSeg-1):seg{Nchan}(nSeg); % p segment.
                t2 = seg{Nchan}(nSeg):seg{Nchan}(nSeg+1); % p+1 segment.
                
                x1 = x_ok(t1,Nchan);
                x2 =  x_MA_ok{Nchan}{(nSeg+1)/2};
                
                %xx_ok(t2,Nchan) = CorrectBaselineMARA(x1,x2,SD);
                
            elseif nSeg == size(seg{Nchan},2)
                t1 = seg{Nchan}(nSeg-1):seg{Nchan}(nSeg); % p segment.
                t2 = seg{Nchan}(nSeg):size(x,1);
                
                x1 = x_ok(t1,Nchan);
                x2 = x(t2,Nchan);
                
                % xx_ok(t2,Nchan) = CorrectBaselineMARA(x1,x2,SD);
                
            end
            x_ok(t2,Nchan) = SplineCorrectBaseline_fnirs_course(x1,x2,SD);
        end
        %    plot(x(:,Nchan));
        %     hold on
        %     plot(x_ok(:,Nchan));
        %legend('RAW','Corrected');
    end
    
    
end