%% Example: Lowpass Filter Design Using Equiripple (Parks-McClellan) Method
%
close all
clear all
%% Define intial values
wp = pi/4; 
ws = 3*pi/8; 
%corner frequency
deltap = 0.02;
deltas = 0.01;
%gains
Gp = 1; 
Gs = 0;
%% Generate filter order using 4 techniques
M_Bellanger = (2/3)*log10(1/(10*deltap*deltas))*(2*pi/abs(ws-wp))
M_Kaiser=(-20*log10(sqrt(deltap*deltas))-13)/(2.32*abs(wp-ws))
M_Harris=(-20*log10(deltas))/(22*abs(wp-ws)/(2*pi))
M_firpmord=firpmord([wp/pi,ws/pi],[1 0],[deltap,deltas])

M=round(M_Harris) % Use the Harris order
%Harris is largest so use that

%% Design the equiripple filter
%band frequencies
fb=[0,wp/pi,ws/pi,1];
a=[Gp,Gp,Gs,Gs];
wght=[1,deltap/deltas];
% or could use wght=[1/deltap,1/deltas];
b=firpm(M,fb,a,wght);

%% Plot the magnitude response
figure(1)
clf
[H,w]=freqz(b,1,[0:.01:pi]);
plot(w,abs(H))
grid
hold
plot([0,wp],[Gp+deltap,Gp+deltap],'-k')
plot([0,wp],[Gp-deltap,Gp-deltap],'-k')
plot([ws,pi],[Gs+deltas,Gs+deltas],'-k')
title(['Lowpass Equiripple Filter with order M=',num2str(M)])
ylabel('|H(e^{j\omega})|')
xlabel('\omega (radians/sample)')
text(1.5,1,['M_{Bellanger}=',num2str(M_Bellanger)]);
text(1.5,0.9,['M_{Kaiser}=',num2str(M_Kaiser)]);
text(1.5,0.8,['M_{Harris}=',num2str(M_Harris)]);
text(1.5,0.7,['M_{firpmord}=',num2str(M_firpmord)]);


%% Plot the amplitude response

figure(2)
clf
W=exp(-j*((-M/2)*w));
A=H.*W;
A=real(A);
plot(w,A)
grid
hold
plot([0,wp],[Gp+deltap,Gp+deltap],'-k')
plot([0,wp],[Gp-deltap,Gp-deltap],'-k')
plot([ws,pi],[Gs+deltas,Gs+deltas],'-k')
plot([ws,pi],[Gs-deltas,Gs-deltas],'-k')
title(['Lowpass Equiripple Filter with order M=',num2str(M)])
ylabel('A(e^{j\omega})')
xlabel('\omega (radians/sample)')
%last 2 commands determine delta_p & delta_s and plot them 
text(1.5,1,['{\rm measured }{\delta_p}=',num2str(max(A)-1)]);
text(1.5,0.9,['{\rm measured }{\delta_s}=',num2str(-min(A))]);
%both meet spec on slide 150

%% Plot the pass band of the amplitude response

figure(3)
clf
plot(w,A)
grid
hold
plot([0,wp],[Gp+deltap,Gp+deltap],'-k')
plot([0,wp],[Gp-deltap,Gp-deltap],'-k')
axis([0,ws,Gp-2*deltap,Gp+2*deltap])
title(['Passband of Lowpass Equiripple Filter with order M=',num2str(M)])
ylabel('A(e^{j\omega})')
xlabel('\omega (radians/sample)')

% spec is .02 which this meets

%% Plot the stop band of the amplitude response
figure(4)
clf
plot(w,A)
grid
hold
plot([ws,pi],[Gs+deltas,Gs+deltas],'-k')
plot([ws,pi],[Gs-deltas,Gs-deltas],'-k')
axis([wp,pi,Gs-2*deltas,Gs+2*deltas])
title(['Stopband of Lowpass Equiripple Filter with order M=',num2str(M)])
ylabel('A(e^{j\omega})')
xlabel('\omega (radians/sample)')
%meets spec

%% 2nd approach: Using firpmord to generate all vectors for firpm
% The frequency, amplitude and weighting vectors generated by firpmord are 
% are the same as the ones generated by hand in the approach used above.
figure(5)
clf
%use 1 for fsord, which means we can use actual cycles/sample in these
%vectors
[Mf,fo,ao,wo]=firpmord([wp/(2*pi),ws/(2*pi)],[Gp,Gs],[deltap,deltas],1);
% 2 for fsord we use the matlab approach which divides by pi
%[Mf,fo,ao,wo]=firpmord([wp/(pi),ws/(pi)],[Gp,Gs],[deltap,deltas],2);
% if not fsord is not specified, uses matlab approach of divide by pi
%[Mf,fo,ao,wo]=firpmord([wp/(pi),ws/(pi)],[Gp,Gs],[deltap,deltas]);
bf=firpm(Mf,fo,ao,wo);
[Hf,wf]=freqz(bf,1,[0:.01:pi]);
Wf=exp(-j*((-Mf/2)*wf));
Af=Hf.*Wf;
Af=real(Af);
plot(w,Af)
hold
plot([0,wp],[Gp+deltap,Gp+deltap],'-k')
plot([0,wp],[Gp-deltap,Gp-deltap],'-k')
plot([ws,pi],[Gs+deltas,Gs+deltas],'-k')
plot([ws,pi],[Gs-deltas,Gs-deltas],'-k')
title(['Lowpass Equiripple Filter using firpmord (order Mf=',num2str(Mf),')'])
ylabel('A(e^{j\omega})')
xlabel('\omega (radians/sample)')
grid
text(1.5,1,['{\rm measured }{\delta_p}=',num2str(max(Af)-1)]);
text(1.5,0.9,['{\rm measured }{\delta_s}=',num2str(-min(Af))]);
text(1.5,0.8,['The order must be increased to meet spec']);
%TLDR: doesnt meet spec, increase order