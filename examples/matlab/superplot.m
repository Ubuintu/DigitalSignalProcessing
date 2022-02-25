function [plot_out] = superplot(x,y,varargin)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    defaultName = 'My plot';
    defaultFigure = 'testFigure';
    
    p = inputParser;
    addRequired(p,'x');
    addRequired(p,'y');
    addParameter(p,'plotName',defaultName,@isstring);
    addParameter(p,'figureName',defaultFigure,@isstring);
    parse(p,x,y,varargin{:});
    
    plot_out = figure('name',p.Results.figureName);
    hold on
    plot(x,y);
    title(p.Results.plotName);
    grid;
    hold off;
end

