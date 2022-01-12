%% Example of LPF Filter Design Using a Kaiser Window
%
close all
clear all
%TLDR: if we increase order, M, to 74, we will meet specs
%% Define initial values

%corner frequency
wp=0.4*pi;
ws=0.5*pi;
%delta is tolerance for both stopband & passband freq
delta=0.001;

%% Generate the response

%stopband attenution
A=-20*log10(delta);
%Order
M=(A-7.95)/(2.285*(ws-wp));
M=round(M)
%index vector
n=0:M;
beta = .1102*(A-8.7)
% if A < 50, generate an error
if A<=50
display(['A=',num2str(A),', an incorrect expression was used for beta']);
end
% kaiser window calc, M+1 = length N & beta produce kaiser window
win=kaiser(M+1,beta);
%cutoff freq
fc=((wp+ws)/2)/(2*pi);
%desired IR
hd=2*fc*sinc(2*fc*(n-M/2));
%actual IR; note window is a column vector from kaiser() so we need to take
%its transpose
h=hd.*win.';

%% Plot response

%find frequency response
[H,w]=freqz(h,1,[-pi:.001:pi]);
figure(1)
clf
%generate dB plot
plot(w/(2*pi),20*log10(abs(H)))
title('Lowpass filter using a Kaiser window')
xlabel('f (cycles/sample)')
ylabel('20log(|H(e^{j\omega})|)')
grid 
figure(2)
clf
%generate linear plot
plot(w/(2*pi),abs(H))
title('Lowpass filter using a Kaiser window')
xlabel('f (cycles/sample)')
ylabel('|H(e^{j\omega})|')
grid 
%% Peak Ripple
%note from above plots, its hard to see peak ripple w/o zooming in, so we
%can calculate as shown below:
peak_value = max(abs(H))    %max abs value of freq resp

%note that the peak value was calculated in matlab as 1.001, which is
%higher than what was specified on slide 128, thus order has to be
%increased

% with M=72 or 73, this does not meet spec in the passband (the stopband
% meets spec), have to increase M

