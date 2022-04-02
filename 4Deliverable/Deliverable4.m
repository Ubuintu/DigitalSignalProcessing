%% Halfband filter Design
% upsampling COMPRESSES freq spectrum; remember
% this for Fpk_stop

% consider Firpm for LPF design as well as
% polyphase from 461
close all; clear; clc; format longG

% call functions like superplot from other directories
Current_Folder=pwd; Function_folder='../examples/matlab'; addpath(genpath(Function_folder));

% digital angular frequency, w (rads/sample)
% w = [0:0.001:1000]/1000*pi; % half cycle
w = [0:0.001:200]/100*pi; %one whole cycle

% ------ Using FilterDesigner ------
% All frequency values are in MHz.
Fs = 12.5;  % Sampling Frequency

Fpass = 0.4375;          % Passband Frequency
% currently gives 5 coeffs; more if you decrease ripple
Dpass = 0.00000057501127785;  % Passband Ripple

% Calculate the coefficients using the FIRPM function.
H_halfband_filtDes  = firhalfband('minorder', Fpass/(Fs/2), Dpass);
% Hd = dsp.FIRFilter('Numerator', b);

H_halfband_1 = freqz(H_halfband_filtDes,1,w);

% ------ Using firpm ------
Fstop=4.46875;  % MHz
Fcutoff=0.25*Fs; % cyc/samp*samp/sec
tw=(Fstop-Fpass)/Fs; % transition width (cycles/sample)
% calculate the corner frequencies from fc & convert them into radians/sample
wp = (.25-tw/2)*2*pi; 
ws = (.25+tw/2)*2*pi; 
deltap = 0.001;
deltas = 0.00001;
Gp = 1;
Gs = 0;

% Generate filter order 
M_firpmord=firpmord([wp/pi,ws/pi],[1 0],[deltap,deltas]);
M=round(M_firpmord)+1; % M must be even

% Design the equiripple filter
fb=[0,wp/pi,ws/pi,1];   % frequency band vector
a=[Gp,Gp,Gs,Gs];        % gain vector
wght=[1,deltap/deltas]; % weight vector
% or could use wght=[1/deltap,1/deltas];
h_halfband_PM=firpm(M,fb,a,wght);   %calculate M+1 IR coefficients for vector b

H_halfband_PM = freqz(h_halfband_PM,1,w);

% hold on 
MR_halfband_pm_vs_Des=superplot(w/2/pi, 20*log10(abs(H_halfband_1)),'plotName',"Comparision between designer & FIRPM",'figureName',"Halfband_cmp",'yName',"Magnitude (dB)",...
    'xName',"frequency (cycles/sample)",'yLegend',"filtDesigner",'cmpY',20*log10(abs(H_halfband_PM)),'cmpYLegend',"FIRPM",...
    'plotAxis',[0 w(end)/2/pi -150 10]);
text(0.02,-10,['{\delta_p} of filter Design: ',num2str(Dpass)]);
% hold off
close(MR_halfband_pm_vs_Des);

% filterDesigner atm gives me 3 mults per LPF; center coeff can be a bit shift

%% Theoretical upconv/upsampling
clc

impulse = [0 0 1 0 0];


    