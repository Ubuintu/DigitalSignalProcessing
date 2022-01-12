%% Example - Two Band Filter
% Design a two band filter, using the impulse response truncation techinue,
% with M=80, f11=0.1, f21=0.2, f12=0.35, f22=0.4, C1=1, C2=0.5. Plot the 
% impulse response on one figure and the amplitude response on a second 
% figure for f from -0.5 to 0.5 cycles/sample. Use the MATLAB function fft
% to generate the amplitude response.
%% Define intial values
f11=.1; % (cycles/sample)
f21=.2; 
f12=.35;
f22=.4;
C1=1;
C2=.5;
M=80; % order of filter
n=0:M; % sample indices
%% Generate and plot the impulse response, h
h1=2*f21*sinc(2*f21*(n-M/2))-2*f11*sinc(2*f11*(n-M/2)); %IR for first band
h2=2*f22*sinc(2*f22*(n-M/2))-2*f12*sinc(2*f12*(n-M/2)); %IR for 2nd band
h=C1*h1+C2*h2;  %IR for the 2 bands with gains are summed
figure(1)
clf
stem(n,h)
title('Two Band Impulse Response, h[n]')
xlabel('n (samples)')
grid
%% Generate and plot the amplitude response
figure(2)
clf
L=256;
hz=[h,zeros(1,L-length(h))];
H=fft(hz);
k=0:L-1;
% M is even - thus this a type 1 filter with a linear phase response of 
% -(M/2)*2*pi*f, where f=k/L
W=exp(-j*(-(M/2)*2*pi)*k/L);    %W vector is complex exp of phase response
A=H.*W;
A=real(A);  %find real A to remove imaginary
plot(k/L-0.5,fftshift(A))   %use ffshift since fft generates freq resp from 0 to L-1; need to generate for cycles per sample so we need x-axis to be k/L shifted by 0.5 for a double sided spectrum
ylabel('A(e^{j\omega})')    %2 band AR
title('Two Band Amplitude Response')
xlabel('f (cycles/sample)')
grid


