function [outputArg1] = MER_opt(varargin)
%% Documentation
%MER_opt find the coefficients that meet the reqired MER
%   Detailed explanation goes here

%% Default values 
    defaultNum = 1;
    defaultRange = [10 20];
    
%% Anonymous functions
    validPosInt = @(var) isnumeric(var) && (var > 0) && ( rem(var,1)==0);
    validRange = @(var) isvector(var) && (length(var)==2);

%% Input Parser
    p = inputParser;
    addParameter(p,'Nsps',defaultNum,validPosInt);
    addParameter(p,'numCoeffs',defaultRange,validRange);

    parse(p,varargin{:});
%% Usage
    if (isempty(varargin))
        fprintf("--------------------------- MER_opt() usage ---------------------------\n");
        outputArg1 = 0;
        return
    end

%% Functionality
    
    if (p.Results.Nsps ~= 0)
        fprintf("Valid Nsps value of %d was passed\n",p.Results.Nsps);
    end
    
    disp(p.Results.numCoeffs);

    outputArg1 = 0;
end

