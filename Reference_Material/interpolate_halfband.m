%% Interpolate a sinusoid by a factor of 2
clear
close all
clc
% Generate 2 cycles of a 1/24 cycles/sample cosine. Interpolate this 
% sinusoid by a factor of L=2. 
% For the interpolation filter, use a halfband filter designed using a 
% Kaiser window. The interpolation filter should have a stopband of 
% 60 dB and a transition width of 0.1 cycles/sample.

%% Define initial values
transition_width = 0.1*2*pi;    %rads/sample
fc=0.25;
A = 60; % stopband attenuation in dB
f1 = 1/24; % frequency of cosine
L=2;    %upsampling factor

%% Generate the halfband filter
M=(A-8)/(2.285*(transition_width));
M=round(M)  %recall M must be even for halfband filter
beta = .1102*(A-8.7);
hw = kaiser(M+1,beta);
n=0:M;
hd = 2*fc*sinc(2*fc*(n-M/2));
h=hd.'.*hw;
%h=fir1(M,fc,hw); % or use this function
h=L*h; % interpolation filter has a gain of L

%% Generate the cosine, interpolate and plot

% Generate the cosine
x=cos(2*pi*f1*[0:48]);
% upsampled signal
xu=upsample(x,2);
% interpolated sequence
xi=filter(h,1,xu);
% adds M zeros to the input sequence
% xi=filter(h,1,[xu zeros(1, M)]); % show filter truncation
% we can see @ the backend that transient is occuring, thus you should keep
% this in mind when using filter()

figure
subplot(3,1,1)
stem([0:length(x)-1],x)
title('Signal Sequence')
ylabel('Original')

%original signal has been upsampled by a factor of 2; 0's have been
%inserted in each of the original samples
subplot(3,1,2)
stem([0:length(xu)-1],xu)
ylabel('Upsampled')

% Upsampled signal is filter w/half-band filter resulting in the
% interpolated signal
subplot(3,1,3)
stem([0:length(xi)-1],xi)
%stem(xi(M/2:end))
ylabel('Interpolated')
xlabel('n (samples)')

% Since the order is 36, there's initial transient of length 36/2 or 18
% samples @ the front end. Theres also transient @ the back end but its not
% shown since filter truncates the output to the length of the input
% signal

%% Plot signal spectrum
N=1024;
% GEnerated via FFT thats zero-padded up to 1024
% spectrum of input
X=fft(x,N);
% interploated seqeuence
Xi=fft(xi,N);
% upsampled spectrum 
Xu=fft(xu,N);

% plot
figure
% Original spectrum is upsampled by a factor of 2
subplot(3,1,1)
plot([-N/2:(N-1)/2]/N,fftshift(abs(X)))
title('Signal Spectrum')
ylabel('Original')
% The images of OG spectrum are shown @ odd mutiplies of pi OR 1/2; you can
% also see that the spectrum has been compressed by a factor of 2
subplot(3,1,2)
plot([-N/2:(N-1)/2]/N,fftshift(abs(Xu)))
ylabel('Upsampled')

% The filter removes these images and you end up with interpolated signal
% as shown
subplot(3,1,3)
plot([-N/2:(N-1)/2]/N,fftshift(abs(Xi)))
ylabel('Interpolated')
xlabel('f (cycles/sample)')

% filter command in matlab truncates output to length of input, if we want
% to see what the truncated portion looks like, we can go back into M-file
% & uncomment the above statement that adds M zeros to the input sequence