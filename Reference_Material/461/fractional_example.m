%% Fractional Re-Sampling
% Generate 3 cycles of a 1/24 cycles/sample sine. Resample this signal with
% a system consisting of a upsampler, followed by a filter, followed by a
% downsampler, where L=2 and M=3. 
% Design the filter using a Kaiser window. 
% The filter should have a stopband of 
% 80 dB and a transition width of 0.1 cycles/sample.
clc
close all
clear all

%% Define initial values
L=2;
M=3;
f1=1/24;    %cycles/sample
%length of input signal
Ns=24*3; %(24 samples/cycle * 3 cycles = 72 samples)
tw = 0.1; %cycles/sample
A = 80; % stopband attenuation in dB

%% Generate the filter
% find the cutoff frequency
fs=min(0.5/L,0.5/M); %cycles/sample
% passband corner frequency
fp=fs-tw;
fc=fs-tw/2;
% order of kaiser window
Mord=(A-8)/(2.285*(tw*2*pi));
Mord=round(Mord)  
beta = .1102*(A-8.7);
hw = kaiser(Mord+1,beta);
nf=0:Mord;
hd = 2*fc*sinc(2*fc*(nf-Mord/2));
h=hd.'.*hw;
%h=fir1(M,fc,hw); %or use this function

%% Generate the input and output signals and plot
n=0:Ns-1;
x = sin(2*pi*f1*n);
xu=upsample(x,L);
xf=filter(h,1,xu);
y=downsample(xf,M);

% Since M>L, we have a decimator with a factor of 3/2

figure
subplot(4,1,1)
% x[n] is a sinusoid w/f = 1/24
stem(x)
ylabel('x[n]')

subplot(4,1,2)
stem(xu)
ylabel('x_{u}[n]')

% interpolated signal/upsampled signal is filtered
subplot(4,1,3)
stem(xf)
ylabel('x_{f}[n]')

% output signal w/sampling rate that is 2/3's x[n]
subplot(4,1,4)
stem(y)
ylabel('y[n]')
xlabel('n (samples)')

% For decimation, the sampling rate is deceased by 3/2; note that x[n] has
% 72 samples & the output should have 48 samples (72*2/3)
