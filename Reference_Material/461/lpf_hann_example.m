M=40;
fc=3/32;    %cycles/sample
n=0:M;  %index vector
% desired IR with sinc
hd=2*fc*sinc(2*fc*(n-M/2));
% window is calculated using expression on prevs slide
wn=[0.5-.5*cos(2*pi*n/M)].'; % or could use wn=hann(M+1); only reason for transpose syntax (') is that hann generates a column vector so when u calcuate impulse h
% we take row vector multiple by transpose of column vector to do element
% by element multiplication
h=hd.*wn.';
% Generate freq response for h
[H1,w]=freqz(h,1,[-pi:.0001:pi]);
figure
% Linear plot
plot(w/(2*pi),abs(H1)),grid
figure
% dB plot
plot(w/(2*pi),20*log10(abs(H1))), grid

% Alternative commands to generate IR

% fir1
mfc = 2*fc; % Note difference in MATLAB; 2 times cutoff since the values in frequency f in cycles/sample assume nyquist frequency is 1 and NOT one-half as assumed in
%literature; so we sub this into mfc
b = fir1(M,mfc,hann(M+1));
[H,w]=freqz(b,1,[-pi:.0001:pi]);
figure
% Linear plot
plot(w/(2*pi),abs(H)), grid