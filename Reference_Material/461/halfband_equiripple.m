%% Halfband Filter Design Using the Equiripple (Parks-McClellan) Method
%
%% Define intial values
tw=.1; % transition width (cycles/sample)
% calculate the corner frequencies from fc & convert them into radians/sample
wp = (.25-tw/2)*2*pi; 
ws = (.25+tw/2)*2*pi; 
deltap = 0.001;
deltas = 0.001;
Gp = 1;
Gs = 0;
%% Generate filter order 
M_firpmord=firpmord([wp/pi,ws/pi],[1 0],[deltap,deltas])
M=round(M_firpmord) % M must be even

%% Design the equiripple filter
fb=[0,wp/pi,ws/pi,1];   % frequency band vector
a=[Gp,Gp,Gs,Gs];        % gain vector
wght=[1,deltap/deltas]; % weight vector
% or could use wght=[1/deltap,1/deltas];
b=firpm(M,fb,a,wght);   %calculate M+1 IR coefficients for vector b
%% Plot impulse response
% every 2nd coefficcient is 0
figure(1)
n=0:M;
stem(n,b),grid
title('Halfband filter impulse response using Parks-McClellan')
xlabel('f (cycles/sample)')
%% Plot the magnitude response
% Linear magnitude response
figure(2)
clf
[H,w]=freqz(b,1,[0:.01:pi]);
plot(w/(2*pi),abs(H))
grid
title(['Halfband Equiripple Filter Frequency Response with order M=',num2str(M)])
ylabel('|H(e^{j\omega})|')
xlabel('f (cycles/sample)')
%% Plot the magnitude response (dB)
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

%% Determine the passband ripple
peak_ripple = max(abs(H)) -1;
% with M=32, this does not meet spec in the passband or stopband, have to 
% increase M by 2 and try again (M must be even)