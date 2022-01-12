%% Example: Least Squares FIR Filter Design
% Design a lowpass filter using a least squares design and compare it 
% with a Kaiser window design. The filter specifications are  
% $\delta_p = 0.1,  \delta_p = 0.01, \omega_p = 0.2\pi$ and $\omega_s=0.3\pi$.
%
% Determining the order of the filter is a trial an error process 
% involving selecting the order to obtain the desired stop band 
% attuenuation. The resulting chosen filter has an order of M=32.
%
% The firls designed filter is compared with a filter designed using a
% Kaiser window. The Kaiser filter has an order of M = 45. This is a significant
% difference in length of filters, which primarily results from allowing the
% pass band ripple to be different and larger than the stop band ripple.
%
close all
clear all
%
%% Define intial values

%pass&stopband tolerance
deltap=0.1;
deltas=0.01;
%corner frequency for passband & stopband
wp=0.2*pi;
ws=0.3*pi;

%% Least squares design
M=32 % chosen by trial and error; normally have to do this design & repeat until you get desired attenuation

%f specifies bands; have to divide by pi to meet notation as specified by
%matlab
f=[0 wp ws pi]/pi; % NOTE: the values in f assume the nyquist
                     %frequency is 1 not 1/2 as commonly used 
                     % in the literature
a=[1 1 0 0]; % amplitude/gain vector (constant from start to end of band; traditionally LPF)
wght=[deltap^-1 deltas^-1]; % weight vector consists of inverse of ripple terms
% wght=[1 deltap/deltas]; %this also works (ie wght is a relative
% weighting); takes above term & multiply by deltap to get the same result
% since weight vector is relative weighting
b=firls(M,f,a,wght);
[H,w]=freqz(b,1,[0:.01:pi]);

%% Kaiser window design

wc=(0.2*pi+0.3*pi)/2;
%stopband attenuation
A=-20*log10(min(deltas,deltap));
beta=0.5842*(A-21)^.4 + 0.07886*(A-21); %21<=A<=50
%calculate order
Mk=(A-8)/(2.285*(ws-wp));
Mk=ceil(Mk) % M = 45
%calculate coeffs using fir1
bk=fir1(Mk,wc/pi,'low',kaiser(Mk+1,beta)); % note wc is divided by pi
[Hk,w]=freqz(bk,1,[0:.01:pi]);

%% Plot magnitude responses
figure(1)
clf
plot(w/(2*pi),20*log10(abs(H)))
hold
plot(w/(2*pi),20*log10(abs(Hk)))
grid
legend('Least Squares','Kaiser')
xlabel('f (cycles/sample)')
ylabel('20log(|H(e^{j\omega})|)')
title('Filter Design Comparison: firls with kaiser')

%FR is fairly close by firls has order of 32 whereas kaiser is 45; stopband
%should reach -40 dB; omega_s was .3pi = 0.15 cycles/sample which should be
%-40 dB; kaiser window meets this spec, questionable if LS meets this

%% Plot the pass band ripple
figure(2)
clf
W=exp(-j*((-M/2)*w));
A=H.*W;
A=real(A);
plot(w,A)
grid
hold
Wk=exp(-j*((-Mk/2)*w));
Ak=Hk.*Wk;
Ak=real(Ak);
plot(w,Ak)
plot([0,wp],[1+deltap,1+deltap],'-k')
plot([0,wp],[1-deltap,1-deltap],'-k')
axis([0,ws,1-2*deltap,1+2*deltap])
legend('Least Squares','Kaiser')
title('Passband Ripple Comparison: firls with kaiser')
ylabel('A(e^{j\omega})')
xlabel('\omega (radians/sample)')

% deltap was .1, both filters meet spec but kaiser window is much smaller than LS ripple since deltap for kaiser window 
% is .01 which is stopband ripple; kaiser ripple has to be less than .01

%% Plot the stop band ripple

figure(3)
clf
plot(w,A)
grid
hold
plot(w,Ak)
plot([ws,pi],[deltas,deltas],'-k')
plot([ws,pi],[-deltas,-deltas],'-k')
axis([wp,pi,-2*deltas,2*deltas])
legend('Least Squares','Kaiser')
title('Stopband Ripple Comparison: firls with kaiser')
ylabel('A(e^{j\omega})')
xlabel('\omega (radians/sample)')

% both filters meet spec, start of stopband, corner frqeuency occurs @
% blackline; LS method does not meet spec BUT kaiser does, order of LS has
% to be increased by 1 or 2