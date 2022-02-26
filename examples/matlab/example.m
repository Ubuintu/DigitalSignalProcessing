clc
close all
clear

if isfolder('pics') == 0
    mkdir('pics')
end

x = 1:100;
y = rand(100,1);
idxmin = find(y == max(y));
idxmax = find(y == min(y));
txt = ['\leftarrow y = ',int2str(max(y))];
hold on
plot(x,y)
plot(x,y,'o','MarkerIndices',[idxmin idxmax],'MarkerFaceColor','red','MarkerSize',5)
t = text(idxmax,y(idxmax),txt);
t.Color = [153/255 153/255 255/255];
hold off
legend('random plot [0:1]');
print -dpng ./pics/test.png
close
%% testing plot function
clc

x = [0:0.01:2]*pi;
y = sin(x);
yCmp = cos(x);
string = 'My test plot';
p_title = 'test_print';

% test = myplot(x,y,string,p_title);
test2 = superplot(x,y,'plotName',"My super plot",'figureName',"super_plot");
test3 = superplot(x,y,yCmp);
legend('y','compare y');
% close(test);

testV = ones(1,1);
testV(2) = 5;