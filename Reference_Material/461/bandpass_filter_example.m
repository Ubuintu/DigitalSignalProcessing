%% Example - Bandpass Filter
% Design a bandpass filter, using the impulse response truncation
% technique, with cutoff frequencies of 
% 
% $$\omega_1 = 0.2 \pi, \omega_2=0.6\pi$$
%
% and an order of 40.
% Plot the impulse response on one plot, the amplitude response (linear) and phase
% response on a second plot and the magnitude response (linear) and associated phase
% response (with phase in the range -pi to pi) on a third plot. Plot the
% frequency response plots (second and third figures) a function of
% frequency in cycles/samples for the range -0.5 to 0.5.
%% Define intial values
f1=0.2*pi/(2*pi); % (cycles/sample)
f2= 0.6*pi/(2*pi); 
M=40; % order of filter
n=0:M; % sample indices
%% Generate and plot the impulse response, h
h=2*f2*sinc(2*f2*(n-M/2))-2*f1*sinc(2*f1*(n-M/2));  %as defined in slide 83
figure(1)
clf
stem(n,h)   %plots sinc function
title('Bandpass Impulse Response, h[n]')
xlabel('n (samples)')
grid
%% Generate and plot the amplitude response and phase response
figure(2)
clf
w=[-pi:0.01:pi];
H=freqz(h,1,w); %generate frequency response
W=exp(-j*(-M/2)*w); %complex exponential with linear phase response
A=H.*W; %amplitude response
A=real(A);  %AR will have small imaginary terms due to computational error
theta=-(M/2)*w;
subplot(2,1,1)
plot(w/(2*pi),A)    %fc = 0.1 < |x| <0.3; double sided
ylabel('A(e^{j\omega})')
title('Bandpass Amplitude Response')
grid
subplot(2,1,2)
plot(w/(2*pi),theta)    %linear phase response with slope -M/2
ylabel('\theta(\omega)')
xlabel('frequency (cycles/sample)')
grid
%% Generate and plot the magnitude response and phase response
figure(3)
subplot(2,1,1)
plot(w/(2*pi),abs(H))
ylabel('|H(e^{j\omega})|')
title('Bandpass Magnitude Response')
grid
subplot(2,1,2)
plot(w/(2*pi),angle(H)) %angle() results the phase being within -pi to pi
ylabel('\angle H(e^{j\omega})')
xlabel('frequency (cycles/sample)')
grid

