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

%% Input Parser
    p = inputParser;
    addParameter(p,'Nsps',defaultNum,validPosInt);
    addParameter(p,'numCoeffs',defaultRange,validRange);
    addParameter(p,'betaR',defaultBRange ,validBetaRange);

    parse(p,varargin{:});
%% Usage
    if (isempty(varargin))
        fprintf("--------------------------- MER_opt() usage ---------------------------\n");
        outputArg1 = 0;
        return
    end

%% Functionality
% variables    
    cnt = 0;
    idx = 1;
    
% Debugging
    if (p.Results.Nsps ~= 0)
%         fprintf("Valid Nsps value of %d was passed\n",p.Results.Nsps);
    end
    
%     disp(p.Results.numCoeffs);
    
    for coeffIdx = p.Results.numCoeffs(1):p.Results.numCoeffs(2)
        fprintf("coefficient index is %d\n",coeffIdx);
        for betaIdx = p.Results.betaR(1):p.Results.betaR(2):p.Results.betaR(3)
            fprintf("beta index is %d\n",betaIdx);
        end
    end

    
    
    
    outputArg1 = 0;
end

