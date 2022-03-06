function [MER_out, betaTX_out, betaRCV_out, coeff_out, betaKais_out] = PPS_opt(varargin)
%% Documentation
%MER_opt find the coefficients that meet the reqired MER
%   Detailed explanation goes here
format long
format loose
%% Default values 
    defaultNum = 1;
    defaultRange = [10 20];
    defaultBRange = [0 0.01 0.1];
    sze = 20000;
    MER_out = zeros(1,sze);
    betaTX_out = zeros(1,sze);
    betaRCV_out = zeros(1,sze);
    coeff_out = zeros(1,sze);
    betaKais_out = zeros(1,sze);
    w = [0:0.001:1000]/1000*pi;
    
%% Anonymous functions
    validPosInt = @(var) isnumeric(var) && (var > 0) && ( rem(var,1)==0);
    validRange = @(var) isnumeric(var) && isvector(var) && (length(var)==2);
    validBetaRange = @(var) isnumeric(var) && isvector(var) && (length(var)==3);
    validcoeffs = @(var) validRange(var) && rem(var(1)-1,2)==0 && rem(var(2)-1,2)==0;

%% Input Parser
    p = inputParser;
    addParameter(p,'Nsps',defaultNum,validPosInt);
    addParameter(p,'MER',defaultNum,validPosInt);
    addParameter(p,'numCoeffs',defaultRange,validcoeffs);
    addParameter(p,'betaTX',defaultBRange ,validBetaRange);
    addParameter(p,'betaRCV',defaultBRange ,validBetaRange);
    addParameter(p,'betaKais',defaultBRange ,validBetaRange);
    addParameter(p,'debug',0);

    parse(p,varargin{:});
%% Usage
    if (isempty(varargin))
        fprintf("--------------------------- PPS_opt() usage ---------------------------\n");
        fprintf("'Nsps'            : optional parameter to label comparison's plot with a legend\n");
        fprintf("'MER'             : optional parameter to label comparison's plot with a legend\n");
        fprintf("'numCoeffs'       : optional parameter to label comparison's plot with a legend\n");
        fprintf("'betaTX'          : optional parameter to label comparison's plot with a legend\n");
        fprintf("'betaRCV'         : optional parameter to label comparison's plot with a legend\n");
        fprintf("'betaKais'        : optional parameter to label comparison's plot with a legend\n");
        fprintf("'debug'           : optional parameter to label comparison's plot with a legend\n");
        fprintf("\nExample usage: [MER_out, betaTX_out, betaRCV_out, coeff_out] = MER_opt('Nsps',4,'numCoeffs',[25 77],'betaTX',[.11 0.01 .16],'betaRCV',[0.12 0.01 0.34],'MER',10);\n");
        fprintf("\n--------------------------- MER_opt() usage ---------------------------\n");
        return
    end

%% Functionality
% variables    
    cnt = 0;
    idx = 1;
    cBeta = char(hex2dec('03b2'));
    indx = 1;
    
% Debugging
    if (p.Results.Nsps ~= 0)
%         fprintf("Valid Nsps value of %d was passed\n",p.Results.Nsps);
    end
    if ( rem( (p.Results.numCoeffs(1)-1)/p.Results.Nsps,1 )~=0 | rem( (p.Results.numCoeffs(2)-1)/p.Results.Nsps,1 )~=0 )
        error('coefficient range is not divisible by Nsps');
    end
    
%     disp(p.Results.numCoeffs);
    
    for coeffIdx = p.Results.numCoeffs(1):p.Results.Nsps:p.Results.numCoeffs(2)
%         fprintf("coefficient index is %d\n",coeffIdx);
        for betaIdxTX = p.Results.betaTX(1):p.Results.betaTX(2):p.Results.betaTX(3)
%             fprintf("beta index for TX is %1.2f\n",betaIdxTX);
            for betaIdxRCV = p.Results.betaRCV(1):p.Results.betaRCV(2):p.Results.betaRCV(3)
%                 fprintf("beta index for RCV is %1.1f\n",betaIdxRCV);
                    for betaIdxKais = p.Results.betaKais(1):p.Results.betaKais(2):p.Results.betaKais(3)
                        
                        M=coeffIdx-1;
                        beta = betaIdxKais; Nsps=p.Results.Nsps; 
                        fc=1/2/Nsps; fp=(1-0.12)*fc; fs=(1+0.12)*fc;
                        fb = [0 fp fc fc fs .5]*2;
                        a = [1 1 1/sqrt(2) 1/sqrt(2) 0 0];
                        % wght vector needs to 2.4535 for passband
                        wght = [2.4535 1 1];
                        h_TX = firpm(M,fb,a,wght);
                        
                        wn = kaiser(length(h_TX),beta);
                        h_TX = h_TX.*wn.';
                        
                        span = (coeffIdx-1)/p.Results.Nsps; h_RCV = rcosdesign(betaIdxRCV,span,p.Results.Nsps);h_RC = conv(h_TX,h_RCV);
        %                 fprintf("span is %2.4f, coeff is %d\n",span,coeffIdx);
        %                 fprintf("%s is %2.4f | span is %2.4f | Nsps: %d\n",cBeta,betaIdxRCV,span,p.Results.Nsps);
                        num = h_RC(coeffIdx);den = zeros(floor(length(h_RC)/p.Results.Nsps),1);idx = 1;
                        for i = 1:length(h_RC)
                            if cnt == 0 && i ~= coeffIdx
                                den(idx) = h_RC(i);
                                cnt = cnt + 1;
                                idx = idx + 1;
                            elseif cnt >= p.Results.Nsps-1
                                cnt = 0;
                            else
                                cnt = cnt + 1;
                            end
                        end

                        MER_theo = 10*log10( num^2/sum(den.^2) );
        %                 fprintf('Theoretical MER is: %2.4f | %s for TX: %1.4f | %s for RCV: %1.4f | # of coefficients: %d\n',...
        %                     MER_theo, cBeta,betaIdxTX, cBeta,betaIdxRCV, coeffIdx);
        %                 g = sprintf('%1.17f',h_RC);
        %                 fprintf("h_RC is: %1.17f \n",h_RC);
        %                 fprintf("\t****Filter coefficients****\n");disp(h_RC); fprintf("peak: %1.17f\n",num); fprintf("denominator:\n");
        %                 disp(den');
        
                        H_TX = freqz(h_TX,1,w);
                        mag_H = 20*log10(abs(H_TX));
                        baseband_ind = find( w/2/pi <= 0.14);
                        OB1_ind = find(w/2/pi > 0.14 & w/2/pi <= 0.1752);
                        OB2_ind = find(w/2/pi > 0.1752 & w/2/pi <= 0.42);
                        OB3_ind = find(w/2/pi > 0.42);
                        
                        conv2mW = @(x) 10.^(x/20);
                        conv2dBm =  @(x) 20.*log10(x);
                        
                        spec_mW = sum(conv2mW(mag_H));
                        bb_mW = sum(conv2mW(mag_H(baseband_ind(1):baseband_ind(end))));
                        OB1_mW = sum(conv2mW(mag_H(OB1_ind(1):OB1_ind(end))));
                        OB2_mW = sum(conv2mW(mag_H(OB2_ind(1):OB2_ind(end))));
                        OB3_mW = sum(conv2mW(mag_H(OB3_ind(1):OB3_ind(end))));

                        spec_dBm = conv2dBm(spec_mW);
                        bb_dBm = conv2dBm(bb_mW);
                        OB1_dBm = conv2dBm(OB1_mW);
                        OB2_dBm = conv2dBm(OB2_mW);
                        OB3_dBm = conv2dBm(OB3_mW);

                        OB1_58 = bb_dBm-OB1_dBm;
                        OB2_60 = bb_dBm-OB2_dBm;
                        OB3_63 = bb_dBm-OB3_dBm;
        
                        if MER_theo >= p.Results.MER && OB1_58>58 && OB2_60>60 && OB3_63>63
                            fprintf('Theoretical MER is: %2.4f | %s for TX: %1.6f | %s for RCV: %1.4f | # of coefficients: %d | %s for Kaiser: %1.6f\n',...
                            MER_theo, cBeta,betaIdxTX, cBeta,betaIdxRCV, coeffIdx, cBeta,betaIdxKais);
                            MER_out(indx)=MER_theo;betaTX_out(indx)=betaIdxTX;betaRCV_out(indx)=betaIdxRCV;coeff_out(indx)=coeffIdx;betaKais_out(indx)=betaIdxKais;
                            indx = indx+1;
                        end
                        
                    end
            end
        end
    end

  last = find(~MER_out,1);
  MER_out = MER_out(1:last-1);
  betaTX_out = betaTX_out(1:last-1);
  betaRCV_out = betaRCV_out(1:last-1);
  coeff_out = coeff_out(1:last-1);
  betaKais_out = betaKais_out(1:last-1);
    
  
end

