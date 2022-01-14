%% Lect1 pt.3: 4 tap filter example
close all
clear
clc

h = [.5 .8 .4 .3];

% This function plots the frequency response 
freqz(h,1);

% Note the freq is normalized to 1 and mag is measured in dB. We are
% interested in finding the max magnitude in this mag resp, to scale the
% coeffs to make the mag resp = 1. @ DC, we can see that the magnitude is
% ~6 dB

% lets prove our previous theory
h2 = 2*h;

freqz(h2,1);

% From the plot, we can see that h2 has an identitcal magnitude response to
% h however notice that the gain is now 2.

% comparing the frequency response of h & h2, there is a difference of ~6
% dB; so we need to convert the scaling factor we applied into dB as well.
% Remember since the filter coeffs are a voltage value, we are going to
% need to multiple by 20:

diff = 20*log10(2);

% This is exactly the difference in magnitude between h & h2; when working
% thru the kickstarter deliverable, you can gen the coeffs for a SRRC
% filter, then plot the FR for that filter, find the max mag resp and based
% on that value, choose k so that you can scale the max value of the mag
% resp equal to 1. This will ensure that the input & output will both fit
% in a 1s17 format.

% rcosdesign is used for RC and SRRC impulse responses