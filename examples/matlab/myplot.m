function plot_out = myplot(x,y, string, my_title)
%myplot custom plotting function
%   This function plots and prints the figure to be made.
plot_out = figure('name',string);
hold on
plot(x,y);
title(string);
grid;
hold off;
datacursormode(plot_out,'on');
plot_out.Position = [10 10 1000 900];
location = ['./pics/',my_title,'.png'];
print(plot_out, '-dpng', location);
end

