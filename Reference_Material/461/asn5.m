%% 3
close all
clear all;
% Design a linear phase and causal FIR filter of length 31 using impulse response truncation to approximate an ideal LPF frequency 
% response given by
% Hd(e^j?) = 
% 1 if 0 < |f| < 1/8,
% 0 if 1/8 < |f| < 0.5.
% 
% Write a MATLAB program that plots the impulse response on one figure window and on another figure window |H(e^j?)|, 
% |H(e^j?)|^2 in dB and the phase response (as the angle of H(e^j?)) of this filter as subplots. Appropriately label the plots. 
% Also use the unwrap command for the angle to better view the phase response. Publish your m-file as a pdf document with suitable 
% section headings.

fc = 1/8;   %cutoff frequency of filter AKA B_L for brick-wall filter
M = 30; %order of filter; length = M+1
n = 0:M;    %sample indices

% The ideal frequency response for this LPF is assume a zero phase response

% sinc filter is an idealized filter that removes all frequency components above a given cutoff frequency, without 
% affecting lower frequencies, and has linear phase response.

% It is an "ideal" low-pass filter in the frequency sense, perfectly passing low frequencies, perfectly cutting high frequencies; 
% and thus may be considered to be a brick-wall filter.

% https://en.wikipedia.org/wiki/Sinc_filter
% using the above sites def for IR for LPF/brick-wall filter: A lowpass
% filter with brick-wall cutoff @ frequency B_L has Impulse Response &
% transter function given by:

h = 2*fc*sinc(2*fc*(n-M/2));      %see slide 78-79; shift of M/2 to make the system causal

%based on description of IR, it should be between 0 & 1/8 cycles/sample?

IR = figure('Name','LPF Imulse Response, h[n]');
clf
stem(n,h);
title('LPF Impulse Response, h[n]')
xlabel('n (samples)')
grid;
datacursormode(IR,'on');

% Generate & plot the frequency response
FR = figure('Name','Frequency Response');
clf
[H,w]=freqz(h,1);
subplot(3,1,1);
plot(w/(2*pi),abs(H));
ylabel('|H(e^{j\omega})|'); %Amplitude Response
title('LPF Frequency Response');
grid
subplot(3,1,2);
plot(w/(2*pi),10*log10(abs(H).^2))
grid
axis([0 .5 -50 10]);
ylabel('10 log{(|H(e^{j\omega})|^2)}'); %Amplitude Response in dB
subplot(3,1,3);
plot(w/(2*pi),unwrap(angle(H)));    %Phase Response
ylabel('\angle H(e^{j\omega})');
xlabel('frequency (cycles/sample)')
grid;
datacursormode(FR,'on');

% Q4
% I think he wants us to use the
% h1=2*f21*sinc(2*f21*(n-M/2))-2*f11*sinc(2*f11*(n-M/2)) method

fc = 1/8;   %cutoff frequency of filter AKA B_L for brick-wall filter
M = 30; %order of filter; length = M+1
n = 0:M;    %sample indices

% p.83; used lpf_to_hpf.m
% Generate difference between delta[n-M/2] & Low Pass Filter's Impulse Response.

h = -h; %negate LPF's IR
h(M/2+1) = 1+h(M/2+1);  %take location of Impulse Response & add 1 to that location
% now h is the impulse response of the HPF; see p.95

hHP=h;
w=-pi:.01:pi;
[H,w]=freqz(h,1,w);
beta=0;
alpha=M/2;
W=exp(-1i*(beta-alpha*w));
A=H.*W;
Ahpf=real(A);
HPF_IR = figure('Name','HPF Imulse Response, h[n]');
clf
plot(w/(2*pi),Ahpf)     %HPF 
title('Highpass Filter (Allpass Minus Lowpass)')
ylabel('A(e^{j\omega})')
xlabel('f (cycles/sample)')
grid;
datacursormode(HPF_IR,'on');        %via datacursor mode, was able to confirm A = 0.5 @ 0.125

%% 5
close all
% Convert the LPF in question 3 to a HPF. Use technique 1 (involving an all pass filter).
%  
% (a) What is the cutoff frequency of the HPF? Write a MATLAB program that plots the impulse response on one figure window, 
% |H(e^j?)|^2 in dB on a second figure window 
% and on a third figure window |H(e^j?)|, the amplitude response (use freqz in the process of calculating the amplitude
% response) and phase response (as a straight line) of this filter as subplots. 

% Appropriately label the plots. Publish your m-file as a pdf document with suitable section headings

fc=1/8; %cutoff frequency (cycles/sample)
M=30;   %order of filter
n=0:M;  %sample indicies

h = 2*fc*sinc(2*fc*(n-M/2));
% using technique 1, negate the LPF's Impulse Response by flipping it 
h=-h;

%take location of Impulse Response & add 1 to that location
h(M/2+1) = 1+h(M/2+1);  %"HPF can be generated from a LPF by subtracting the LP response from an allpass filter FR
% that has the same phase response as H_LPF Technique 1, slide 95.

IR = figure('Name','HPF Impulse Response, h[n]');
clf
stem(n,h)
title('HPF Impulse Response');
xlabel('n (samples)');
grid;
datacursormode(IR,'on'); 


% plot AR in dB
IR_dB = figure('Name','HPF Amplitude Response, h[n]');
[H,w] = freqz(h,1);
%plot normalized to pi
plot(w/(2*pi), 20*log10(H.*conj(H)));
ylabel('10 log{(|H(e^{j\omega})|^2)}');
xlabel('\omega normalized to 2\pi');
title('HPF Response in dB');
grid;
datacursormode(IR_dB,'on'); 

%Generate Frequency Response
A = H.*exp(1i*w*M/2);
FR = figure('Name','HPF Frequency Response, |H(e^j\omega}| & \theta(\omega)');
subplot(3,1,1);
plot(w/(2*pi), abs(H));
ylabel('|H(e^{j\omega})|');
title('HPF Frequency Response');

subplot(3,1,2)
plot(w/(2*pi), real(A));    %Amplitude Response has small imaginary components, real() removes them
ylabel('A(e^{j\omega})');

subplot(3,1,3);
plot(w/(2*pi), -(M/2)*w);
ylabel('\theta(e^{j\omega})');
xlabel('frequency (cycles/sample)');
grid;
datacursormode(FR,'on'); 

% fprint("Cutoff frequency is the same as the LPF, fc = 1/8 cycles/sample");

%% 6
clear all
close all

% Convert the LPF in question 3 to a HPF. Use technique 2 (involving
% modulation). slide 97

fc=1/8; %cutoff frequency (cycles/sample)
M=30;   %order of filter
n=0:M;  %sample indicies

hLP = 2*fc*sinc(2*fc*(n-M/2));    %freq resp of LPF

h = hLP.*(-1).^n;   %modulation theorem

IR = figure('Name','HPF Impulse Response, h[n]');
clf
stem(n,h)
title('HPF Impulse Response');
xlabel('n (samples)');
grid;
datacursormode(IR,'on'); 

% plot AR in dB
IR_dB = figure('Name','HPF Amplitude Response, h[n]');
[H,w] = freqz(h,1);
%plot normalized to pi
plot(w/(2*pi), 20*log10(H.*conj(H)));
ylabel('10 log{(|H(e^{j\omega})|^2)}');
xlabel('\omega normalized to 2\pi');
title('HPF Response in dB');
grid;
datacursormode(IR_dB,'on'); 

beta = 0;
alpha = M/2;
W = exp(-j*(beta-alpha*w-pi));  %note -pi term due to the H_HP being equal to H_LP shifted by pi

%Generate Frequency Response
A = H.*W;
FR = figure('Name','HPF Frequency Response, |H(e^j\omega}| & \theta(\omega)');
subplot(3,1,1);
plot(w/(2*pi), abs(H));
grid;
ylabel('|H(e^{j\omega})|');
title('HPF Frequency Response');

% Using modulation theorem, note that the theoritical frequency response of
% a HPF is the FR of the LPF shited by pi on slide 98.
subplot(3,1,2)
grid;
plot(w/(2*pi), real(A));    %Amplitude Response has small imaginary components, real() removes them
ylabel('A(e^{j\omega})');


subplot(3,1,3);
plot(w/(2*pi), -(M/2)*w);
ylabel('\theta(e^{j\omega})');
xlabel('frequency (cycles/sample)');
grid;
datacursormode(FR,'on'); 

% a) cutoff frequency of the HPF using the modulation method should be pi -
% wc_Lp = pi - 2pi*0.125 = 3pi/4; wc_HPF normalized to 2pi is 3/8 = 0.375.
% VIA datacursor mode, we see that the amplitude response is 0.5 @ f =
% 0.375 which agrees with the theoritical value on slide 99.

%% 13
close all
clear all;
% Design a symmetric linear phase FIR filter with order 80 using impulse response truncation and ideal
% magnitude response
% 
%                 1           if 0.2? < |?| < 0.6?,
%     Hd(e^j?) =  0.5         if 0.7? < |?| < 0.8?,
%                 0               elsewhere.
%             
% Write a MATLAB program that plots the impulse response on one figure window, the magnitude
% response in dB on a second figure window and on a third figure window the magnitude response,
% amplitude response and phase response of this filter as subplots.    

% We need to design a 2 band filter using the IRT technique on slides 80-83

%**Define initial values for BPF's IR on slide 83 & 85**
M = 80;
n = 0:M;

% Remember omega = 2pi*f, f = omega/2pi
% Lower frequency band; f_i1
f11 = 0.1;   % 0.2pi/2pi = 0.1 cycles/samples
f21 = 0.3;

% Upper frequency band; f_i2
f12 = 0.35;     %leftmost frequency
f22 = 0.4;      %rightmost frequency

% slide 85: Band gain is C_k. Bandgain is given as 1 & 0.5 from the given
% frequency response i.e. bandgain is 1 when frequency is in between 0.2pi
% & 0.6pi.
C1 = 1;     %lower band
C2 = 0.5;

%** Generate and plot the impulse response h **
%lower frequency band/IR for first band
h1 = 2*f21*sinc(2*f21*(n-M/2)) - 2*f11*sinc(2*f11*(n-M/2)); 
%upper frequency band
h2 = 2*f22*sinc(2*f22*(n-M/2)) - 2*f12*sinc(2*f12*(n-M/2)); 

%IR for the 2 bands with their gains summed
h = C1*h1 + C2*h2;

figure(1)
clf
stem(n,h)
title('Two Band Impulse Response h[n]');
xlabel('n (samples)')
grid

%** Generate and plot the amplitude response **
figure(2);
clf;
L=256;
%zeropad the freq resp w/length of 256
hz=[h,zeros(1,L-length(h))];
%Discrete Fourier Transform via Fast Fourier Transform
H=fft(hz);
k=0:L-1;
% M is even - thus this a type 1 filter with a linear phase response of 
% -(M/2)*2*pi*f, where f=k/L
% k is a vector from 0 to 255; L is 256.

% W vector is complex exp of phase response
W=exp(-1i*(-M/2*2*pi)*k/L);
% Amplitude Response
A=H.*W;
A=real(A);  %remove minor IM components
% use ffshift since fft generates freq resp from 0 to L-1; need to generate 
% for cycles per sample so we need x-axis to be k/L shifted by 0.5 for a double sided spectrum
plot(k/L-0.5, fftshift(A));
% 2 Band Amp Resp
ylabel('A(e^{j\omega})');
title('Two Band Amplitude Response');
xlabel('f (cycles/sample)')
grid; 

% plot AR in dB
IR_dB = figure('Name','HPF Amplitude Response, h[n]');
%plot normalized to pi
plot(k/L-0.5, 20*log10(fftshift(A)));
ylabel('10 log{(|H(e^{j\omega})|^2)}');
xlabel('\omega normalized to 2\pi');
title('HPF Response in dB');
grid;
datacursormode(IR_dB,'on'); 

%% 14
close all
clear all;
% Design a symmetric linear phase FIR filter using impulse response truncation with phase delay
% M/2 = 40 and ideal magnitude response
% 
%                 1           if 0     < |?| < pi/3,
%     Hd(e^j?) =  0.5         if 2pi/3 < |?| < pi,
%                 0               elsewhere.
%             
% Write a MATLAB program that plots the impulse response on one figure window, the magnitude
% response in dB on a second figure window and on a third figure window the magnitude response,
% amplitude response and phase response of this filter as subplots.    

% We need to design a 2 band filter using the IRT technique on slides 80-83

%**Define initial values for BPF's IR on slide 83 & 85**
M = 80;
n = 0:M;

% Remember omega = 2pi*f, f = omega/2pi
% Lower frequency band; f_i1
f11 = 0;   
f21 = 1/6;  %pi/3/2pi = 1/6

% Upper frequency band; f_i2
f12 = 1/3;     %leftmost frequency
f22 = 0.5;      %rightmost frequency

% slide 85: Band gain is C_k. Bandgain is given as 1 & 0.5 from the given
% frequency response i.e. bandgain is 1 when frequency is in between 0.2pi
% & 0.6pi.
C1 = 1;     %lower band
C2 = 0.5;

%** Generate and plot the impulse response h **
%lower frequency band/IR for first band
h1 = 2*f21*sinc(2*f21*(n-M/2)) - 2*f11*sinc(2*f11*(n-M/2)); 
%upper frequency band
h2 = 2*f22*sinc(2*f22*(n-M/2)) - 2*f12*sinc(2*f12*(n-M/2)); 

%IR for the 2 bands with their gains summed
h = C1*h1 + C2*h2;

figure(1)
clf
stem(n,h)
title('Two Band Impulse Response h[n]');
xlabel('n (samples)')
grid

%** Generate and plot the amplitude response **
figure(2);
clf;
L=256;
%zeropad the freq resp w/length of 256
hz=[h,zeros(1,L-length(h))];
%Discrete Fourier Transform via Fast Fourier Transform
H=fft(hz);
k=0:L-1;
% M is even - thus this a type 1 filter with a linear phase response of 
% -(M/2)*2*pi*f, where f=k/L
% k is a vector from 0 to 255; L is 256.

% W vector is complex exp of phase response
W=exp(-1i*(-M/2*2*pi)*k/L);
% Amplitude Response
A=H.*W;
A=real(A);  %remove minor IM components
% use ffshift since fft generates freq resp from 0 to L-1; need to generate 
% for cycles per sample so we need x-axis to be k/L shifted by 0.5 for a double sided spectrum
plot(k/L-0.5, fftshift(A));
% 2 Band Amp Resp
ylabel('A(e^{j\omega})');
title('Two Band Amplitude Response');
xlabel('f (cycles/sample)')
grid; 

% plot AR in dB
IR_dB = figure('Name','HPF Amplitude Response, h[n]');
%plot normalized to pi
plot(k/L-0.5, 20*log10(fftshift(A)));
ylabel('10 log{(|H(e^{j\omega})|^2)}');
xlabel('\omega normalized to 2\pi');
title('HPF Response in dB');
grid;
datacursormode(IR_dB,'on'); 
