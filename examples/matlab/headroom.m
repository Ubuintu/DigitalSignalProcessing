%% How to use matlab to simulate your filter and verify maximum output
clear
close all
clc

h = [0.8 -0.7 0.4];

% create a random input that fits within a 2s8 format. 
% rand() will create a random length of numbers with values between 0 & 1
% that are uniformly distributed

% a gaussian distributed sequence can be find using randn()
x = rand(1,1000);

% we want our random input to be within -2:2
x = x*4;    %x ranges from 0,4

% now x ranges from -2:2
x = x-2;

% our max and min should be close to the prevs specified range
max_x = max(x);
min_x = min(x);

% we can plot x to see its distribution 
plot(x);

% we can simulate the operation of the filter by convolving the input
% sequence with the impulse response
y = conv(x,h);

% see if worse case values match our theoretical range of -3.8:3.8
max_y = max(y);
min_y = min(y);

% if your worse case value does not match your theoretical range, you will need to
% generate more random numbers
x = rand(1,1E8)*4 - 2;
max_x = max(x);
min_x = min(x);

y = conv(x,h);
max_y = max(y);
min_y = min(y);

% by increasing the length of the random sequence, we can see that the
% minimum and maximum values of our filter match the theoretical values we
% predicted
