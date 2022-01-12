%% LPF to HPF transformation demo
%
%
%% Generate a low pass filter
% Plot the amplitude response
M=30;
f1=0;
f2=.1;
n=0:M;
h=2*f2*sinc(2*f2*(n-M/2))-2*f1*sinc(2*f1*(n-M/2));      %IRT 
w=-pi:.01:pi;
[H,w]=freqz(h,1,w);
beta=0;
alpha=M/2;
W=exp(-j*(beta-alpha*w));
A=H.*W;
Alpf=real(A);
figure(1)
clf
plot(w/(2*pi),Alpf) %LPF fc=0.1 occurs @ 0.5 for AR
title('Lowpass Filter')
ylabel('A(e^{j\omega})')
xlabel('f (cycles/sample)')
%% Generate a highpass filter from the lowpass filter.

%generate difference between delta[n-M/2] & LP IR
h=-h;       %negate LP's IR
h(M/2+1)=1+h(M/2+1);    %take location of IR and add 1 to that location; h is now the IR for HPF
hLP=h;
w=-pi:.01:pi;
[H,w]=freqz(h,1,w);
beta=0;
alpha=M/2;
W=exp(-j*(beta-alpha*w));
A=H.*W;
Ahpf=real(A);
figure(2)
clf
plot(w/(2*pi),Ahpf)     %HPF 
title('Highpass Filter (Allpass Minus Lowpass)')
ylabel('A(e^{j\omega})')
xlabel('f (cycles/sample)')

%% Plot both amplitude responses on one plot
figure(2) 
clf 
plot(w/(2*pi) ,Alpf) 
hold on 
plot(w/(2*pi) ,Ahpf) 
legend( 'LPF', 'HPF')   %fc = ~0.1, occurs @ A=0.5
title('Original Lowpass and Generated Highpass Filters') 
ylabel('A(e^{j\omega}) ') 
xlabel('f (cycles/sample)') 