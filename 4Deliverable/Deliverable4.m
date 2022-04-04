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
% currently gives 15 coeffs; more if you decrease ripple
Dpass = 0.00000057501127785;  % Passband Ripple

% Calculate the coefficients using the function.
h_halfband_filtDes  = firhalfband('minorder', Fpass/(Fs/2), Dpass).';
% Hd = dsp.FIRFilter('Numerator', b);

H_halfband_filtDes = freqz(h_halfband_filtDes,1,w).';

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
h_halfband_PM=firpm(M,fb,a,wght).';   %calculate M+1 IR coefficients for vector b

H_halfband_PM = freqz(h_halfband_PM,1,w).';

% hold on 
MR_halfband_pm_vs_Des=superplot(w/2/pi, 20*log10(abs(H_halfband_filtDes)),'plotName',"Comparision between designer & FIRPM",'figureName',"Halfband_cmp",'yName',"Magnitude (dB)",...
    'xName',"frequency (cycles/sample)",'yLegend',"filtDesigner",'cmpY',20*log10(abs(H_halfband_PM)),'cmpYLegend',"FIRPM",...
    'plotAxis',[0 w(end)/2/pi -150 10]);
text(0.02,-10,['{\delta_p} of filter Design: ',num2str(Dpass)]);
% hold off
close(MR_halfband_pm_vs_Des);

% filterDesigner atm gives me 3 mults per LPF; center coeff can be a bit shift

%% Theoretical upconv/upsampling
%------Clean up workspace-------
clc;
clear Current_Folder deltap deltas Dpass fb Fcutoff Fpass Fstop Function_folder Fs Gp Gs H_halfband_filtDes h_halfband_PM H_halfband_PM M M_firpmord MR_halfband_pm_vs_Des tw wght wp ws
clear w;

%------Upsample & filter-------
impulse = [0 0 1 0 0].'; up1=upsample(impulse,2);
LPF_out_1st=conv(up1,h_halfband_filtDes);

% digital angular frequency, w (rads/sample)
% w = [0:0.001:1000]/1000*pi; % half cycle
w = [0:0.001:200]/100*pi; %one whole cycle

%------Upsample & filter-------
up2=upsample(LPF_out_1st,2);

% ------ Using FilterDesigner ------
% All frequency values are in MHz.
Fs = 25;  % Sampling Frequency
Fpass = 0.21875; % Passband Frequency; width of signal is compressed again by 2
Dpass = 0.00000057501127785;  % Passband Ripple
h_halfband_filtDes_2nd  = firhalfband('minorder', Fpass/(Fs/2), Dpass).';

LPF_out_2nd=conv(up2,h_halfband_filtDes_2nd);

%% First halfband coeff in 0s18
clc

% Find coeffs
safety=(2^-1)-(2^-18);  %0s18
h_halfband_filtDes_0s18=round(h_halfband_filtDes*2^18);

idx=0;
% halfband coeffs are 0s18 to account for sum_lvls being 2s16
fprintf("initial begin\n");
for i=1:round(length(h_halfband_filtDes_0s18)/2)  %for sym
% for i=1:round(length(h_halfband_filtDes_0s18))  %no reduc
    if (h_halfband_filtDes_0s18(i)<0)
        fprintf("\tHsys[%d] = -18'sd%d;\n",(idx),abs(h_halfband_filtDes_0s18(i)) );
        idx=idx+1;
    else
        fprintf("\tHsys[%d] = 18'sd%d;\n",(idx),abs(h_halfband_filtDes_0s18(i)) );
        idx=idx+1;
    end
end
fprintf("end\n");

%% halfband Time-sharing structure
clc

% ceil to account for odd tap
numCoeffs=ceil(length(h_halfband_filtDes_0s18)/2);
numMults=ceil(numCoeffs/4);

num_of_sumLvls=0; coeffs2reduce=length(h_halfband_filtDes_0s18);
tapsPerlvl=zeros( ceil(log2(coeffs2reduce)),1 );
for i=1:length(h_halfband_filtDes_0s18)
    if coeffs2reduce<=1
        break
    elseif i==2
        num_of_sumLvls=num_of_sumLvls+1;coeffs2reduce=ceil(coeffs2reduce/4);
        fprintf("\tMixer required: %d \n",coeffs2reduce);
        coeffs2reduce=ceil(coeffs2reduce/2);
        fprintf("sum level %d has %d registers\n",i,coeffs2reduce);
        tapsPerlvl(i,1)=coeffs2reduce;
    else
        num_of_sumLvls=num_of_sumLvls+1;coeffs2reduce=ceil(coeffs2reduce/2);
        fprintf("sum level %d has %d registers\n",i,coeffs2reduce);
        tapsPerlvl(i,1)=coeffs2reduce;
    end
end
fprintf("num of sum lvls: %d | total # of regs: %d\n",num_of_sumLvls,sum(tapsPerlvl));

%% Second halfband coeff in 0s18
clc

% Find coeffs
safety=(2^-1)-(2^-18);  %0s18
h_halfband_filtDes_2nd_0s18=round(h_halfband_filtDes_2nd*2^18);

idx=0;
% halfband coeffs are 0s18 to account for sum_lvls being 2s16
fprintf("initial begin\n");
for i=1:round(length(h_halfband_filtDes_2nd_0s18)/2)  %for sym
% for i=1:round(length(h_halfband_filtDes_0s18))  %no reduc
    if (h_halfband_filtDes_2nd_0s18(i)<0)
        fprintf("\tHsys[%d] = -18'sd%d;\n",(idx),abs(h_halfband_filtDes_2nd_0s18(i)) );
        idx=idx+1;
    else
        fprintf("\tHsys[%d] = 18'sd%d;\n",(idx),abs(h_halfband_filtDes_2nd_0s18(i)) );
        idx=idx+1;
    end
end
fprintf("end\n");
    