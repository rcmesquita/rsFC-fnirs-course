function[dc_w] = RemoveAutocorrelation_dc_fnirs_course(dc,SD)
% Removes autocorrelation from Resting State Data
% with prehitenning methodology.
%
% INPUT:
%   dc - Concentration chances: Time pnts x Channels x Hemoglobin
%   SD - SD structure common in fNIRS files.
%
% OUTPUT:
%   dc_w = whitenned concentration changes.
%
%
% For details contact refer to:
%
% 1 - Characterization and correction of the false-discovery rates
% in resting state connectivity using functional
% near-infrared spectroscopy
%
% 2 - Autoregressive model based algorithmfor correcting motion and
% seriallycorrelated errors in fNIRS
%

% Maximum parameter order. A conservative approach is to use more than
% 20 seconds as upper bound.
Pmax = round(20*SD.f);

% Whitenned data
dc_w = nan*zeros(size(dc));


% Time Series Length
n = size(dc,1);

% Run on HbO and HbR
for Hb=1:2
    
    for Nchannel=1:size(dc,2)
        
        if isempty(find(isnan(dc(:,Nchannel,Hb))==1))
            
            clear y yf a vt
            
            % Get Original Time Series
            y = dc(:,Nchannel,Hb);
            
            for P=1:Pmax
                % For a given parameters P we find the coefficients that
                % minimize autoregressive model (AR(P));
                a = aryule(y,P);
                
                % Once we have the parameters a, we can filter the error
                % to find the new non atucorrelated error (vt).
                vt = filter(a,+1,y);
                
                % Next, we can compute the baysian information
                % criterion (BIC(P)).
                
                % Log Likelihood
                LL = -1*(n/2)*log( 2*pi*mean(vt.^2))+...
                    -0.5*(1/mean(vt.^2))*sum(vt.^2);
                
                % Baysian information
                BIC(P) = -2*LL+P*log(n);
            end
            
            %Optimal is the P that minimizes BIC
            [~,OptimalP] = min(BIC);
            
            AR_Parameters = aryule(y,OptimalP); %Find parameters
            
            % Filter y
            yf = filter(AR_Parameters,+1,y);
            
            % Update dc_w
            dc_w(:,Nchannel,Hb) = yf;
            
            % Save OptimalP for double checking
            SD.Optimal_P(Nchannel,Hb) = OptimalP;
            
        end
        
    end
    
end


% Compute Total Hemoglobin
dc_w(:,:,3) = dc_w(:,:,1) + dc_w(:,:,2);

% Remove undetermined points (first P_max points)
dc_w = dc_w(Pmax+1:end,:,:);


end