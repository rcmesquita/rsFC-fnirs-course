function[x3] = SplineCorrectBaseline_fnirs_course(x1,x2,SD)

%%% Criterias to correct the baseline of each time series segment. 
%%% All criterias were extract from doi:10.1088/0967-3334/31/5/004 
%%% in Table 1. 

a = round(SD.f/3);
b = round(2*SD.f);


if length(x1)<=a && length(x2)<=a
    v = mean(x1) - mean(x2);
   
elseif a<length(x1) && b>length(x1) && length(x2)<=a 
    
    v = mean(x1(end-a:end)) - mean(x2);
    %x3 = 
elseif length(x1)>=b && length(x2)<=a 
    l = length(x1);
    v = mean(x1(end-round(l/10):end)) - mean(x2);
    
elseif length(x1)<=a && length(x2)<b && length(x2)>a 
    v = mean(x1) - mean(x2(1:a));
    
elseif a<length(x1) && b>length(x1) && a<length(x2) && b>length(x2)
    v  = mean(x1(end-a:end)) - mean(x2(1:a));

elseif length(x1)>=b && length(x2)<b && length(x2)>a 
    l = length(x1);
    v = mean(x1(end-round(l/10):end)) - mean(x2(1:a));
    
elseif length(x1)<=a && length(x2)>=b
    l = length(x2);    
    v = mean(x1) - mean(x2(1:round(l/10)));
    
elseif a<length(x1) && b>length(x1) && length(x2)>=b
    l = length(x2);
    v = mean(x1(end-a:end)) - mean(x2(1:round(l/10)));
else
    l1 = length(x1);
    l2 = length(x2);
    v = mean(x1(end-round(l1/10):end)) - mean(x2(1:round(l2/10)));
end
    if isnan(v)
       v=0; 
    end
    x3 = x2+v;
    
end