%% Halfband Filter Design Using a Kaiser Window
%
%% Define initial values
transition_width = 0.1*2*pi;    %radians/sample
fc=0.25; 
delta=0.001;
%% Generate the response
A=-20*log10(delta)  % stopband attenuation
M=(A-8)/(2.285*(transition_width))  
M=round(M)  %recall M must be even
n=0:M;
beta = .1102*(A-8.7) % A>50 for kaiser
if A<=50
display(['A=',num2str(A),', an incorrect expression was used for beta'])
end
win=kaiser(M+1,beta);
hd=2*fc*sinc(2*fc*(n-M/2)); %sinc function via IRT
h=hd.*win.';
%% Plot impulse response
% every 2nd coefficient should be zero, thus this is halfband filter
figure(1)
stem(n,h),grid
title('Halfband filter impulse response using a Kaiser window')
xlabel('f (cycles/sample)')
%% Plot response
% Magnitude response of the filter
[H,w]=freqz(h,1,[-pi:.0001:pi]);
figure(2)
clf
plot(w/(2*pi),20*log10(abs(H)))
title('Halfband filter using a Kaiser window')
xlabel('f (cycles/sample)')
ylabel('20log(|H(e^{j\omega})|)')
grid
%% Peak Ripple
% peak ripple can be be calulcated by subtracting the max value of frequency response by
% the nominal passband gain
peak_ripple = max(abs(H)) - 1 
% with M=36, this meets spec in the passband but does not meet the 
% stopband spec of 60 dB at (stopband corner frequency is given by cutoff frequency + half of transition width) fs = 0.25 + 0.1/2 = 0.3. 
% It meets spec at M=40, recall that M must be even.

% At 0.3, we should exceed 60 dB attenuation; if you look at the plot &
% zoom in, you should see that @ 0.3 cycles/sample, the attenuation is -58
% dB