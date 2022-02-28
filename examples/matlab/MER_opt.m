function [outputArg1] = MER_opt(varargin)
%% Documentation
%MER_opt find the coefficients that meet the reqired MER
%   Detailed explanation goes here
format long
format loose
%% Default values 
    defaultNum = 1;
    defaultRange = [10 20];
    defaultBRange = [0 0.01 0.1];
    
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

    parse(p,varargin{:});
%% Usage
    if (isempty(varargin))
        fprintf("--------------------------- MER_opt() usage ---------------------------\n");
        fprintf("'cmpYLegend'      : optional parameter to label comparison's plot with a legend\n");
        fprintf("'Nsps'            : optional parameter to label comparison's plot with a legend\n");
        fprintf("'MER'             : optional parameter to label comparison's plot with a legend\n");
        fprintf("'numCoeffs'       : optional parameter to label comparison's plot with a legend\n");
        fprintf("'betaTX'          : optional parameter to label comparison's plot with a legend\n");
        fprintf("'betaRCV'          : optional parameter to label comparison's plot with a legend\n");
        fprintf("\n--------------------------- MER_opt() usage ---------------------------\n");
        outputArg1 = 0;
        return
    end

%% Functionality
% variables    
    cnt = 0;
    idx = 1;
    cBeta = char(hex2dec('03b2'));
    
% Debugging
    if (p.Results.Nsps ~= 0)
%         fprintf("Valid Nsps value of %d was passed\n",p.Results.Nsps);
    end
    
%     disp(p.Results.numCoeffs);
    
    for coeffIdx = p.Results.numCoeffs(1):p.Results.Nsps:p.Results.numCoeffs(2)
%         fprintf("coefficient index is %d\n",coeffIdx);
        for betaIdxTX = p.Results.betaTX(1):p.Results.betaTX(2):p.Results.betaTX(3)
%             fprintf("beta index for TX is %1.2f\n",betaIdxTX);
            for betaIdxRCV = p.Results.betaRCV(1):p.Results.betaRCV(2):p.Results.betaRCV(3)
%                 fprintf("beta index for RCV is %1.1f\n",betaIdxRCV);
                span = (coeffIdx-1)/p.Results.Nsps;
%                 fprintf("span is %2.4f, coeff is %d\n",span,coeffIdx);
                h_TX = rcosdesign(betaIdxTX,span,p.Results.Nsps);
%                 fprintf("%s is %2.4f | span is %2.4f | Nsps: %d\n",cBeta,betaIdxRCV,span,p.Results.Nsps);
                h_RCV = rcosdesign(betaIdxRCV,span,p.Results.Nsps);
                h_RC = conv(h_TX,h_RCV);
                num = h_RC(coeffIdx);
                den = zeros(floor(length(h_RC)/p.Results.Nsps),1);
                
                idx = 1;
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
                fprintf('Theoretical MER is: %2.4f | %s for TX: %1.4f | %s for RCV: %1.4f | # of coefficients: %d\n',...
                    MER_theo, cBeta,betaIdxTX, cBeta,betaIdxRCV, coeffIdx);
            end
        end
    end

    
    
    
    outputArg1 = 0;
end

