function [outputArg1] = MER_opt(varargin)
%% Documentation
%MER_opt find the coefficients that meet the reqired MER
%   Detailed explanation goes here

%% Default values 
    defaultNum = 1;
    
%% Anonymous functions
    validPosInt = @(var) isnumeric(var) && (var > 0) && ( rem(var,1)==0);

%% Input Parser
    p = inputParser;
    addParameter(p,'Nsps',defaultNum,validPosInt);

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

    outputArg1 = 0;
end

