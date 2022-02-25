function plot_out = myplot(x,y, plot_name, my_title)
%myplot custom plotting function
%   This function plots and prints the figure to be made.
    plot_out = figure('name',plot_name);
    hold on
    plot(x,y);
    title(my_title);
    grid;
    hold off;
    datacursormode(plot_out,'on');
    plot_out.Position = [10 10 1000 900];
    location = ['./pics/',plot_name,'.png'];
    print(plot_out, '-dpng', location);
end

