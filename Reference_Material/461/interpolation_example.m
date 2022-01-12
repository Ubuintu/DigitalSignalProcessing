function interpolation_example(Nl,L,f1,f2);
%INTERPOLATION_EXAMPLE - Generates a sinusoid sequence 
%consisting of the sum of two sinusoids.  Then applies
%interp to the sequence and plots the orginal and the
%interpolated sequence in a single figure window.
%
%USAGE
%
%  interpolation_example - uses an interactive interface
%
%  interpolation_example(Nl,L,f1,f2) - uses a non-interactive interface
%
%  Variables:   Nl - Length of the input sequence 
%               L - up-sampling factor
%               f1 - input signal frequency 1 in cycles/sample for sine 1
%               f2 - input signal frequency 2 in cycles/sample for sine 2
%
%  Example values: Nl=50, L=3, f1=0.03, f2=0.04
%  interpolation_example(50,3,0.03,0.04)

%Check the number of input and output argument
error(nargchk(0,4,nargin)); % Display error if incorrect number of inputs
error(nargoutchk(0,0,nargout));  % Display error if incorrect # of outputs

% If you don't have any arguments, then Matlab will ask you to input the
% parameters
clf;
if nargin==0
Nl = input('Length of input signal = ');
L = input('Up-sampling factor = ');
f1 = input('Frequency of first sinusoid = ');
f2 = input('Frequency of second sinusoid = ');
end

% Generate the input sequence
n = 0:Nl-1;
x = sin(2*pi*f1*n) + sin(2*pi*f2*n);
% Generate the interpolated output sequence by a factor of L; we don't need
% to generate the filter, interp does the upsampling & interpolates using
% a FIR filter
y = interp(x,L);
% Plot the input and the output sequences
subplot(2,1,1)
stem(n,x(1:Nl));
title('Input sequence');
xlabel('Time index n'); ylabel('Amplitude');
subplot(2,1,2)
m=0:Nl*L-1;
stem(m,y(1:Nl*L));
title(['Output sequence up-sampled by ', num2str(L)]);
xlabel('Time index n'); ylabel('Amplitude');
