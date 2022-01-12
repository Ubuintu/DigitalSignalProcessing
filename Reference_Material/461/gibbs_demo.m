%% Example - Gibbs Phenomonon
% Compare the amplitude responses for two impulse response truncation
% lowpass filters. One with the order M=10 and the other with M=40.
% Set the cutoff to be 0.25 cycles/sample.
% 
% Use the MATLAB function fft in the process of generating the amplitude 
% response. Plot both responses on one plot as a function of
% frequency in cycles/samples for the range -0.5 to 0.5.
%% Define intial values
%
f2=1/4;
f1=0;
beta=0;
M1=10;
alpha1=M1/2;
M2=40;
alpha2=M2/2;
%% Generate the impulse responses, h1 and h2
n=0:M1;
h1=2*f2*sinc(2*f2*(n-M1/2))-2*f1*sinc(2*f1*(n-M1/2));   %using complete IR function for both
n=0:M2;
h2=2*f2*sinc(2*f2*(n-M2/2))-2*f1*sinc(2*f1*(n-M2/2));
%% Generate the amplitude responses, A1 and A2
L=256;
h1z=[h1 zeros(1,L-length(h1))];
h2z=[h2 zeros(1,L-length(h2))];
H2=fft(h2z);    %calculat fft
H1=fft(h1z);
k=0:L-1;
W1=exp(-j*(beta-alpha1*2*pi*k/L));  %complex exp
W2=exp(-j*(beta-alpha2*2*pi*k/L));
A1=H1.*W1;  %AR = IR * phase resp
A1=real(A1);    %remove smoll imaginary error
A2=H2.*W2;
A2=real(A2);
%% Plot the amplitude responses
figure(1)
clf
plot(k/L-0.5,fftshift(A1))
hold
plot(k/L-0.5,fftshift(A2),'r')  %increasing order from 10 to 40 doesn't reduce ripple; ripple is issue for IRT & is a result of Gibb's phenonmon
legend('A(e^{j\omega}), M=10', 'A(e^{j\omega}), M=40')
xlabel('f (cycles/sample)')
grid
