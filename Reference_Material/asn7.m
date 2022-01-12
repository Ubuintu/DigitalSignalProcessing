%% Question 1 *TODO*
clc
clear all
close all
% Design a halfband filter using a Kaiser window, with a stopband attenuation of 60 dB and a transition
% width of 0.1 cycles/sample.

% initial values
tw = 0.1*2*pi;  % rads/sample
fc = 0.25;  % cycles/sample
A = 60;

M = (A-8)/(2.285*tw);
M = round(M);   % make sure M is even for halfband filter
n = 0:M;    %sample index
beta = 0.1102*(A-8.7);

%% Question 2
clc
clear all
close all
% Design a halfband filter using the Parks-McClellan method, with a stopband attenuation of 60 dB
% and a transition width of 0.1 cycles/sample.

% Define intial values
tw=.1; % transition width (cycles/sample)
% calculate the corner frequencies & convert them into radians/sample
wp = (.25-tw/2)*2*pi;   % radians/samples
ws = (.25+tw/2)*2*pi; 
deltap = 10^(-60/20);
deltas = deltap;
Gp = 1;
Gs = 0;

% Generate filter order using 4 techniques (original just use firpmord
% since its more accurate?)
M_Bellanger = (2/3)*log10(1/(10*deltap*deltas))*(2*pi/abs(ws-wp))
M_Kaiser=(-20*log10(sqrt(deltap*deltas))-13)/(2.32*abs(wp-ws))
M_Harris=(-20*log10(deltas))/(22*abs(wp-ws)/(2*pi))

M_firpmord=firpmord([wp/pi,ws/pi],[1 0],[deltap,deltas])
M=round(M_firpmord) % M must be even

% Design the equiripple filter
fb=[0,wp/pi,ws/pi,1];   % frequency band vector
a=[Gp,Gp,Gs,Gs];        % gain vector
wght=[1,deltap/deltas]; % weight vector
% or could use wght=[1/deltap,1/deltas];
b=firpm(M,fb,a,wght);   %calculate b coefficients; b is a vector containing M+1 calc IR coeffs

% Plot impulse response
% every 2nd coefficcient is 0
figure(1)
n=0:M;
stem(n,b),grid
title('Halfband filter impulse response using Parks-McClellan')
xlabel('f (cycles/sample)')

% Plot the magnitude response
% Linear magnitude response
figure(2)
clf
[H,w]=freqz(b,1,[0:.01:pi]);
plot(w/(2*pi),abs(H))
grid
title(['Halfband Equiripple Filter Frequency Response with order M=',num2str(M)])
ylabel('|H(e^{j\omega})|')
xlabel('f (cycles/sample)')

% Plot the magnitude response (dB)
% Note that filter does not meet spec since its greater than 60 dB thus we
% increase the order
figure()
clf
[H,w]=freqz(b,1,[0:.01:pi]);
plot(w/(2*pi),20*log10(abs(H)))
grid
title(['Halfband Equiripple Filter Frequency Response with order M=',num2str(M)])
ylabel('20log|H(e^{j\omega})|')
xlabel('f (cycles/sample)')

% Determine the passband ripple
peak_ripple = max(abs(H)) -1;
% with M=32, the peak ripple is 0.0014, thus this does not meet spec in the passband or stopband, have to 
% increase M by 2 and try again (M must be even)



%% Question 3
clc
clear all
close all

fc = 1/8;
b = 0.25;
Nsps = 4;
n=12;   % 12 samples from plot; see the peak

h = (1/Nsps)*sinc(n/Nsps)*cos(pi*b*n/Nsps)/( 1 - (2*b*n/Nsps).^2 );
% h = pi/4/Nsps*sinc(1/2/b);
% h = 0.5 + 0.5*cos( pi*(fc-fc*(1-b))/2/b/fc );      %slide 163



%% Question 4
clc
clear all
close all

% Rolloff factor, specified as a real nonnegative scalar not greater than 1. 
% The rolloff factor determines the excess bandwidth of the filter. 
% Zero rolloff corresponds to a brick-wall filter and unit rolloff to a pure raised cosine.
beta = 0.99;
% Number of symbols
span = 7;
% Number of samples per symbol (oversampling factor), specified as a positive integer scalar.
Nsps = 4;

h = rcosdesign(beta,span,Nsps);
mx = max(abs(h-rcosdesign(beta,span,Nsps,'sqrt')));
fvtool(h,'Analysis','impulse');

% [H,w] = freqz(h,1);
% stem(w,H);

% The time it takes for the signal to die down is delay spread; original
% time of pulse is called symbol time
% Note that the zero crossings of the time-domain pulse shape are spaced by Ts seconds (i.e. by the symbol time



%% Question 5
clc
clear all;
close all

% Given the filter specifications, ? = 0.2, Nsps = 4, Nsymb = span = 25 and the nominal passband gain
% is 0 dB, complete the following questions.
% 
% ***(a) Generate the impulse response of a square root raised cosine pulse shaping filter | slide 184***

%excess Bandwidth
% beta = 0.2;
beta = 0.1;
% # of symbols per sample
Nsps = 4;
% length of the pulse
span = 25;

% Order of filter
M = Nsps*span;

% cutoff frequency for rrc filter
fc = 1/(2*Nsps);    %160
fp = (1-beta)*fc;
fs = (1+beta)*fc;

% design impulse response of rrc s.183-184; note that rrc is made by default
hrrc = rcosdesign(beta,span,Nsps);

% To make frequency response have a nominal passband gain of 1 
% the pulse must be scaled to produce the same square root raised cosine
% pulse made by the truncated ideal pulse | see slide 169
hrrcs = hrrc/max(hrrc)*( 1/Nsps + beta/Nsps*(4/pi-1) );

% ***(b) Generate, using firpm, the impulse response of a square root Nyquist pulse shaping filter. | slide 176***

%frequency band vector: passband from 0 to fp, 0 width frequency band from
%fc from fc, and finally the stopband to 0.5. NOte that frequency band
%vector is multiplied by 2 to confirm to matlab's notation
fb = [0 fp fc fc fs .5]*2;

% Gain vector for the frequencies specified in fb
a = [1, 1, 1/sqrt(2), 1/sqrt(2), 0, 0];

% weight of the trans, 0 width, & stopband
wght = [2.4535 1 1];

% b (impulse) vector calculation for a squart root Nyquist pulse shaping
% filter
hsrn = firpm(M, fb, a, wght);

% ***(c) Plot the two impulse responses on a single figure.***

IR = figure('Name','SRRC & SR Nyquist Impulse Response, h[n]');
% square root raised cosine pulse shaping filter
n = 0:length(hrrc)-1;
stem(n,hrrc);
hold on

% square root nyquist pulse shaping filter
n = 0:length(hsrn)-1;
stem(n,hsrn);
legend('Root Raised Cosine','Square Root Nyquist');
grid;
datacursormode(IR,'on'); 

% ***(d) Plot the dB magnitude response of the two filters on a single figure.***

% plot frequency spectrum of the square root raised cosine pulse shape
% filter
f = [0:.0001:.5];
[Hrrc,w] = freqz(hrrc,1,f*2*pi);
MR = figure('Name','SRRC & SR Nyquist Magnitude Response, 20log|H(e^{j\omega})|');
plot(f,20*log10(abs(Hrrc)));
hold on

% plot frequency spectrum of the square root Nyquist pulse shaping filter
[Hsrn,w] = freqz(hsrn,1,f*2*pi);
plot(f,20*log10(abs(Hsrn)));
legend('Root Raised Cosine','Square Root Nyquist');
grid
datacursormode(MR,'on'); 

% ***(e) If ? is decreased to 0.1, what is the effect on the stopband attenuation of the two filters. If***
% there is a change in the stopband attenuation, provide an explanation of why?

% When ? is decreased to 0.1, the root raised cosine is scaled by 2.
% Looking at the 2nd plot, we can see that there is a change in the
% stopband attenuation. 

% slide 168 mentions that the stopband attenuation is
% affected by ? & the length of the pulse AKA span.

% looking at slide 163, the frequency response points such as the passband
% & stopband depend on ? 

% From wikipedia, we can see that a larger beta has a greater attenuation
% in the stopband & a small beta has almost no attenuation in the stopband.

% ? controls the sharpness in the transition band,  a lower beta has a
% smoother transition from passband to stopband but the attenuation may
% become weaker



%% Question 6
clc
clear all;
close all

% Given the specifications, ? = 0.2, Nsps = 4, Nsymb = span = 25 and the impulse response has unit
% energy, complete the following questions.
% 
% (a) Generate the impulse response of a square root raised cosine pulse shaping filter.

% slide 184 specifies requirements for a square root raised cosine pulse
% w/unit energy; s.183 mentions that rcosdesign designs the impulse
% response w/unit energy. Should just use rrc but no need to scale pulse
% since that was to get a passband gain of 1



%% Question 7
clc
clear all;
close all

% Consider a pulse shaping filter followed by a matched filter, both having a unit energy square root
% raised cosine impulse response with the following specifications, ? = 0.2, Nsps = 4, Nsymb = span =
% 25.

% (a) Generate a 1000 sample random sequence consisting of two amplitudes: 1 and -1. Insert
% Nsps?1 zeros between each sample and use this as the input to t

% Initial Values
beta = 0.2;
Nsps = 4;
span = 25;
M = span*Nsps;
fc = 1/2/Nsps;
fp = (1-beta)*fc;
fs = (1+beta)*fc;

% Square Root Raised Cosine
hrrc = rcosdesign(beta,span,Nsps);

% Random Input sequence
nbits = 1000;
%input sequence
input_seq = 2*(floor(2*rand(1,nbits))-0.5); %1,-1
%input pulse shape
input_ps = reshape([input_seq;zeros(Nsps-1,nbits)],1,Nsps*nbits);

% impulse response of output pulse shape filter
output_ps = conv(input_ps,hrrc);
n=0:length(output_ps)-1;
figure
stem(n,output_ps);

% (b) Generate and plot the output of the matched filter
output_mf = conv(output_ps,hrrc);
n=0:length(output_mf)-1;
figure
stem(n,output_mf);

% (c) Determine the output sequence by sampling the matched filter output every Nsps samples, taking into consideration the transients at the beginning 
% and end. Plot this sequence.
output_seq = output_mf(M+1:Nsps:end-M); %discard transients
stem([0:length(output_seq)-1],output_seq)
title('Output of the Sequence Samples')

% (d) Given the input sequence and the output sequence, calculate the ISI and plot it.
isi_seq = output_seq - input_seq;
figure
stem([0:length(isi_seq)-1],isi_seq)
title('Output of the ISI')

% (e) Calculate the RMS ISI value.
rms_isi = sqrt(mean(isi_seq.^2));

%(f) Generate a linear magnitude response plot of the convolution of the square root raised cosine
% pulse with itself. What is the pulse generated by the convolution called? Is the transition band
% spectrum generated from the convolution odd symmetric about the cutoff frequency?

hrc = conv(hrrc,hrrc);
f = [0:.0001:.5];
[Hrc,w] = freqz(hrc,1,f*2*pi);
figure
plot(f,abs(Hrc))
hold on
[Hrrc,w] = freqz(hrrc,1,f*2*pi);
plot(f,abs(Hrrc))
title('linear magnitude response plot of Raised Cosine and Square Root Raised Cosine');
hold off
legend('Raised Cosine','Square Root Raised Cosine');
grid;

% g) Generate the dB magnitude response plot of the square root raised cosine pulse. What is the
% stopband attenuation.
figure
plot(f,20*log10(abs(Hrc)))
hold on
plot(f,20*log10(abs(Hrrc)))
title('dB magnitude response plot of Raised Cosine and Square Root Raised Cosine');
hold off
legend('Raised Cosine','Square Root Raised Cosine');
axis([0 0.5 -250 30]);
grid;



%% Question 8
clc
clear all;
close all

% Repeat the previous question using a square root Nyquist impulse response generated using firpm.
% For the odd symmetric question of 7f), note that for the current question the spectral bump near
% fp is in the transition band. Compare the RMS ISI and the stopband attenuation with the previous
% question.
% Define Initial Values 
beta = 0.2;
Nsps = 4;
span = 25;

M = span* Nsps; % order of the filter

fc = 1/(2*Nsps); %cutoff frequency
fp = (1-beta)*fc; %passband frequency
fs = (1+beta)*fc; %corner frequency

% Square Root Nyquist firpm() slide 176
fb = [0 fp fc fc fs 0.5] *2; %all the frequencies
a = [1 1 1/sqrt(2) 1/sqrt(2) 0 0]; %desired gain values
wght = [2.4535 1 1]; %weight derived from pg2 of given paper
% wght = [10 1 1]; %Q10

%Implement approach from the Harris Paper
%First initialize for the while loop
hsrn = firpm(M,fb,a,wght);%generate the initial impulse response

% Generate a Random Input Sequence 
nbits = 1000;
input_seq = (floor(2*rand(1,nbits))-0.5)/0.5; % 1,-1
input_ps = reshape([input_seq;zeros(Nsps-1,nbits)],1,Nsps*nbits);

% Generate and Plot the Output of the Pulse Shaping Filter 
output_ps = conv(input_ps,hsrn);
n=0:length(output_ps)-1;
figure(1)
stem(n,output_ps)
title('Output of the Pulse Shaping Filter')

% Generate and Plot the Output of the Matched Filter
output_mf = conv(output_ps,hsrn);
n=0:length(output_mf)-1;
figure(2)
stem(n,output_mf)
title('Output of the Matched Filter')

% Generate and Plot the Output Sequence Samples
output_seq = output_mf(M+1:Nsps:end-M); %discard transients
figure(3)
stem([0:length(output_seq)-1],output_seq)
title('Output of the Sequence Samples')

% Determine ISI and Plot
isi_seq = output_seq - input_seq;
figure(4)
stem([0:length(isi_seq)-1],isi_seq)
title('Output of the ISI')

% Determine RMS value of ISI
rms_isi = sqrt(mean(isi_seq.^2));


% Determine and Plot the convolution Magnitude Resposne 
hrc = conv(hsrn,hsrn);
f= [0:0.0001:0.5];
[Hrc,w] = freqz(hrc,1,f*2*pi);
figure(5)
plot(f,abs(Hrc)),grid
title('Linear Magnitude Response')

% Determine and Plot the dB Magnitude Resposne 
[Hsrn,w] = freqz(hsrn,1,f*2*pi);
figure(6)
plot(f,20*log10(abs(Hsrn))),grid
title('Magnitude Response (dB)')



%% Question 9

% The spectral bump that can be observed near the passband corner frequency in the plot of question 8f)
% affects both the ISI and stopband attenuation. This spectral bump can be reduced using an approach
% from the Harris paper listed in the slides that involves increasing fp in small increments for the square
% root Nyquist impulse response until the ISI stops decreasing. Repeat question 8 implementing this
% approach from the Harris paper. Compare the RMS ISI and the stopband attenuation with the
% previous two questions.


clc
clear all;
close all
% Define Initial Values 
beta = 0.1;
Nsps = 4;
span = 25;

M = span* Nsps; % order of the filter

fc = 1/(2*Nsps); %cutoff frequency
fp = (1-beta)*fc; %passband frequency
fs = (1+beta)*fc; %corner frequency

% Square Root Nyquist Harris Paper Way
fb = [0 fp fc fc fs 0.5] *2; %all the frequencies
a = [1 1 1/sqrt(2) 1/sqrt(2) 0 0]; %desired gain values
wght = [2.4535 1 1]; %weight derived from pg2 of given paper

%Implement approach from the Harris Paper
%First initialize for the while loop
h = firpm(M,fb,a,wght);%generate the initial impulse response
cnt=0; %counting variable
hconv = conv(h,h);
hconv(M+1)=0;%zero the peak value
isi_total_prev = sum(abs(hconv(1:Nsps:end)));
isi_total = isi_total_prev;
cstep=0.005; %step size for increment fp
c = 1;

%the second inequality in the while loop keeps fp<fc
while isi_total <= isi_total_prev && c <.9*fc/fp
    isi_total_prev = isi_total;
    c= c+cstep;
    fb = [0 c*fb fc fc fs 0.5];
    h=firpm(M,fb,a,wght);
    hconv = conv(h,h);
    hconv(M+1) = 0;
    isi_total = sum(abs(hconv(1:Nsps:end)));
    cnt= cnt+1;
end
hsrn=h/sqrt(sum(h.^2)); %normalize to unit energy

% Generate a Random Input Sequence 
nbits = 1000;
input_seq = (floor(2*rand(1,nbits))-0.5)/0.5; % 1,-1
input_ps = reshape([input_seq;zeros(Nsps-1,nbits)],1,Nsps*nbits);

% Generate and Plot the Output of the Pulse Shaping Filter 
output_ps = conv(input_ps,hsrn);
n=0:length(output_ps)-1;
figure(1)
stem(n,output_ps)
title('Output of the Pulse Shaping Filter')

% Generate and Plot the Output of the Matched Filter
output_mf = conv(output_ps,hsrn);
n=0:length(output_mf)-1;
figure(2)
stem(n,output_mf)
title('Output of the Matched Filter')

% Generate and Plot the Output Sequence Samples
output_seq = output_mf(M+1:Nsps:end-M); %discard transients
figure(3)
stem([0:length(output_seq)-1],output_seq)
title('Output of the Sequence Samples')

% Determine ISI and Plot
isi_seq = output_seq - input_seq;
figure(4)
stem([0:length(isi_seq)-1],isi_seq)
title('Output of the ISI')

% Determine RMS value of ISI
rms_isi = sqrt(mean(isi_seq.^2));


% Determine and Plot the convolution Magnitude Resposne 
hrc = conv(hsrn,hsrn);
f= [0:0.0001:0.5];
[Hrc,w] = freqz(hrc,1,f*2*pi);
figure(5)
plot(f,abs(Hrc)),grid
title('Linear Magnitude Response')


% Determine and Plot the dB Magnitude Resposne 
[hsrn,w] = freqz(hsrn,1,f*2*pi);
figure(6)
plot(f,20*log10(abs(Hrc))),grid
title('Magnitude Response (dB)')