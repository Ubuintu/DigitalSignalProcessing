function decimation_example(Nl,M,f1,f2);
%DECIMATION_EXAMPLE - Generates a sinusoid sequence 
%consisting of the sum of two sinusoids.  Then applies
%decimate to the sequence and plots the orginal and the
%decimated sequence in a single figure window.
%
%USAGE
%
%  decimation_example - uses an interactive interface
%
%  decimation_example(Nl,L,f1,f2) - uses a non-interactive interface
%
%  Variables:   Nl - Length of the input sequence 
%               M -  down-sampling factor
%               f1 - input signal frequency 1 in cycles/sample 
%               f2 - input signal frequency 2 in cycles/sample 
%
%  Example usage: decimation_example(96,2,1/24,3/24)

%Check the number of input and output argument
error(nargchk(0,4,nargin)); % Display error if incorrect number of inputs
error(nargoutchk(0,0,nargout));  % Display error if incorrect # of outputs

clf;
if nargin==0
Nl = input('Length of input signal = ');
M = input('Down-sampling factor = ');
f1 = input('Frequency of first sinusoid = ');
f2 = input('Frequency of second sinusoid = ');
end
n = 0:Nl-1;
% Generate the input sequence
x = sin(2*pi*f1*n) + sin(2*pi*f2*n);
% Generate the decimated output sequence. You can specify the typer of
% filter
y = decimate(x,M,'fir');
% Plot the input and the output sequences
subplot(2,1,1)
stem(n,x(1:Nl));
title('Input sequence');
xlabel('n (samples)');ylabel('Amplitude');
subplot(2,1,2)
m=0:Nl/M-1;
stem(m,y(1:length(m)));
title(['Output sequence decimated by ', num2str(M)]);
xlabel('n (samples)');ylabel('Amplitude');
subplot(2,1,2); ylabel('Amplitude');
