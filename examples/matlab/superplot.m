function [plot_out] = superplot(x,y,varargin)
%SUPERPLOT This is function handles the majority of the required plotting
%functions
%   Detailed explanation goes here

%% Default Parameters
    defaultString = 'unknown';
    defaultPlot = zeros(length(x),1);
    defaultAxis = [x(1) x(length(x)) min(y) max(y)];
    emptyString = "";
%     defaultChoice = 0;
    
%% Input parser
    p = inputParser;
    validVector = @(var) isvector(var) && ~isempty(var);
    validLength = @(v) length(v) == length(x);
    addRequired(p,'x',validVector);
    addRequired(p,'y',validVector);
    addParameter(p,'cmpY',defaultPlot,validLength);
    addParameter(p,'plotName',defaultString,@isstring);
    addParameter(p,'figureName',defaultString,@isstring);
    addParameter(p,'plotAxis',defaultAxis,validVector);
    addParameter(p,'xName',defaultString,@isstring);
    addParameter(p,'yName',defaultString,@isstring);
    addParameter(p,'yLegend',defaultString,@isstring);
    addParameter(p,'cmpYLegend',emptyString);
    addParameter(p,'txt',emptyString);
    parse(p,x,y,varargin{:});
    
%% Usage
% disp("Total number of input arguments: " + nargin)
% celldisp(varargin);
% fprintf("%d\n",length(varargin));

if (isempty(varargin))
    fprintf("--------------------------- superplot() usage ---------------------------\n");
    fprintf("superplot parameters:\n\n");
    fprintf("'x'               : required parameter to plot data in Y to corresponding values in X (vectors X and Y MUST have same length)\n");
    fprintf("'y'               : required parameter to plot data in X to corresponding values in Y\n");
    fprintf("'cmpY'            : optional parameter to compare plot of Y's data\n");
    fprintf("'plotName'        : optional parameter to give plot a title\n");
    fprintf("'figureName'      : optional parameter to name plot's figure\n");
    fprintf("'plotAxis'        : optional parameter to change plot's axes ex: [xmin, xmax, yMin, yMax]\n");
    fprintf("'xName'           : optional parameter to label x-axis\n");
    fprintf("'yName'           : optional parameter to label y-axis\n");
    fprintf("'yLegend'         : optional parameter to label y's plot with a legend\n");
    fprintf("'cmpYLegend'      : optional parameter to label comparison's plot with a legend\n");
    fprintf("\nExample usage: plot_variable = superplot(x,cos(x),'plotName',""cosine plot"");\n");
    fprintf("plot is not normalized, will come out in future patch lol\n");
    fprintf("\n--------------------------- superplot() usage ---------------------------\n");
    plot_out = [];
    return
end

%% Directory setup
if isfolder('pics') == 0
    mkdir('pics')
end
    
%% Plotting
    plot_out = figure('name',p.Results.figureName);
    hold on
    plot(x,y);
    title(p.Results.plotName);
    axis(p.Results.plotAxis);
    ylabel(p.Results.yName);
    xlabel(p.Results.xName);
    legend(p.Results.yLegend);
    grid;
    
%% Optional plotting
    if any(p.Results.cmpY)
        plot(x,p.Results.cmpY)
    end
    if (p.Results.cmpYLegend ~= "")
        legend(p.Results.yLegend, p.Results.cmpYLegend);
    end
    datacursormode(plot_out,'on');
    plot_out.Position = [5 5 1500 900];
%     plot_out.InnerPosition = [5 5 2000 1000];
    location = strcat('./pics/',p.Results.figureName,'.png');
    print(plot_out, '-dpng', location);
    hold off;
end