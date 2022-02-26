function [plot_out] = superplot(x,y,varargin)
%SUPERPLOT This is function handles the majority of the required plotting
%functions
%   Detailed explanation goes here
    defaultString = 'unknown';
    defaultPlot = zeros(length(x),1);
    defaultAxis = [x(1) x(length(x)) min(y) max(y)];
    defaultChoice = 0;
    
    p = inputParser;
    validVector = @(var) isvector(var) && ~isempty(var);
    validLength = @(v) length(v) == length(x);
    addRequired(p,'x',validVector);
    addRequired(p,'y',validVector);
    addOptional(p,'cmpY',defaultPlot,validLength);
    addParameter(p,'plotName',defaultString,@isstring);
    addParameter(p,'figureName',defaultString,@isstring);
    addParameter(p,'plotAxis',defaultAxis,validVector);
    addParameter(p,'xName',defaultString,@isstring);
    addParameter(p,'yName',defaultString,@isstring);
    parse(p,x,y,varargin{:});
    
    plot_out = figure('name',p.Results.figureName);
    hold on
    plot(x,y);
    title(p.Results.plotName);
    axis(p.Results.plotAxis);
    ylabel(p.Results.yName);
    xlabel(p.Results.xName);
    grid;
    if any(p.Results.cmpY)
        plot(x,p.Results.cmpY)
    end
    hold off;
    datacursormode(plot_out,'on');
    plot_out.Position = [10 10 1000 900];
    location = strcat('./pics/',p.Results.figureName,'.png');
    print(plot_out, '-dpng', location);
end