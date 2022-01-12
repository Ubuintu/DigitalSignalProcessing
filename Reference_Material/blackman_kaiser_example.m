%% Comparison of HPF design of Kaiser with Blackman
%
close all
clear all
%% Define initial values

%corner frequency for stopband & passband
ws=0.7*pi;
wp=0.8*pi;
%tolerance in stopband & passband
deltas=0.0002;
deltap=0.001;
%Attenuation is determined using worst-case tolerance
A=-20*log10(deltas)

%% Blackman window design

%Transition width & order M
M=9.19*pi/(wp-ws);
%M has to be a type 1 filter so make sure its even
M=round(M)
%indicies
n=0:M;
%HP cutoff frequency
f1=((wp+ws)/2)/(2*pi);
%f2 is the highest frequency, which is 1/2 cycles/samples (slide 81?)
f2=1/2;
%desired IR
hd=2*f2*sinc(2*f2*(n-M/2))-2*f1*sinc(2*f1*(n-M/2));
win=blackman(M+1);
%multiple hd & win to find coeffs for freq resp
hb=hd.*win.';
[Hb,w]=freqz(hb,1,[0:.01:pi]);
figure(1)
clf
%plot magnitude
plot(w/(2*pi),20*log10(abs(Hb)))
title('Highpass filter using a Blackman window')
xlabel('f (cycles/sample)')
ylabel('20log(|H(e^{j\omega})|)')
grid

%note this filter does not meet spec since the corner frequency was .7pi
%which should be 0.35 cycles/sample; @ 0.35 cycles/sample, the
%an amplitude is around -60 dB; thus we need to increase order

%% Kaiser window design

%calculate order
M=(A-8)/(2.285*(wp-ws));
%make sure its even 
M=round(M)
n=0:M;
%beta for A > 50
beta = .1102*(A-8.7);
%if stopband attenuation is less than 50 print an error
if A<=50
display(['A=',num2str(A),', an incorrect expression was used for beta'])
end
win=kaiser(M+1,beta);
hd=2*f2*sinc(2*f2*(n-M/2))-2*f1*sinc(2*f1*(n-M/2));
hk=hd.*win.';

%freq resp is generated & plotted
[Hk,w]=freqz(hk,1,[0:.01:pi]);
figure(2)
clf
plot(w/(2*pi),20*log10(abs(Hk)))
title('Highpass filter using a Kaiser window')
xlabel('f (cycles/sample)')
ylabel('20log(|H(e^{j\omega})|)')
grid

%M = 92, has the same order as blackman window; we need -74 dB @ f = 0.35
%cycles/sample. Need to take closer look

%% Peak Ripple

%calculate peak ripple to see if passband meets spec

blackman_peak_ripple = max(abs(Hb))
kaiser_peak_ripple = max(abs(Hk))

% both meet spec (delta_p = 0.001) for the passband, BUT examining
% the plots, it appears neither meet spec for the stopband, can try 
% increasing M in steps of 2 (Type 1 filter) OR modify the 
% stopband ripple requirement
