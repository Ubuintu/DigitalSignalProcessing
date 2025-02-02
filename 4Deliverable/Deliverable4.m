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

% tried to account for BW of downsampled, didnt work
Fpass = 0.4375;          % Passband Frequency
% Fpass = 0.875;          % Passband Frequency
% currently gives 15 coeffs; more if you decrease ripple
Dpass = 0.057501127785;  % Passband Ripple

% Calculate the coefficients using the function.
h_halfband_filtDes  = firhalfband('minorder', Fpass/(Fs/2), Dpass).';
% h_halfband_filtDes  = firhalfband(14, Fpass/(Fs/2)).';
% h_halfband_filtDes  = h_halfband_filtDes/sum(abs(h_halfband_filtDes))*(1-2^-17); %to scale down

H_halfband_filtDes = freqz(h_halfband_filtDes,1,w).';

% hold on 
% MR_halfband_pm_vs_Des=superplot(w/2/pi, 20*log10(abs(H_halfband_filtDes)),'plotName',"Comparision between designer & FIRPM",'figureName',"Halfband_cmp",'yName',"Magnitude (dB)",...
%     'xName',"frequency (cycles/sample)",'yLegend',"filtDesigner",'cmpY',20*log10(abs(H_halfband_PM)),'cmpYLegend',"FIRPM",...
%     'plotAxis',[0 w(end)/2/pi -150 10]);
% text(0.02,-10,['{\delta_p} of filter Design: ',num2str(Dpass)]);
% hold off
% close(MR_halfband_pm_vs_Des);

% filterDesigner atm gives me 3 mults per LPF; center coeff can be a bit shift

% ------ Using FilterDesigner ------
% All frequency values are in MHz.
Fs = 25;  % Sampling Frequency
Fpass = 0.21875; % Passband Frequency; width of signal is compressed again by 2
% Fpass = 0.875; 
Dpass = 0.057501127785;  % Passband Ripple
% h_halfband_filtDes_2nd  = firhalfband('minorder', Fpass/(Fs/2), Dpass).';   %no bueno
h_halfband_filtDes_2nd  = firhalfband(14, Fpass/(Fs/2)).';

H_halfband_filtDes_2nd = freqz(h_halfband_filtDes_2nd,1,w).';

% MR2_halfband_pm_vs_Des=superplot(w/2/pi, 20*log10(abs(H_halfband_filtDes_2nd)),'plotName',"Comparision between designer & FIRPM",'figureName',"Halfband_cmp",'yName',"Magnitude (dB)",...
%     'xName',"frequency (cycles/sample)",'yLegend',"filtDesigner",'cmpY',20*log10(abs(H_halfband_PM)),'cmpYLegend',"FIRPM",...
%     'plotAxis',[0 w(end)/2/pi -150 10]);
% close(MR2_halfband_pm_vs_Des);

%% Theoretical upconv/upsampling
%------Clean up workspace-------
clc;
clear Current_Folder deltap deltas Dpass fb Fcutoff Fpass Fstop Function_folder Fs Gp Gs H_halfband_filtDes h_halfband_PM H_halfband_PM M M_firpmord MR_halfband_pm_vs_Des tw wght wp ws
clear w;

%------Upsample & filter-------
% impulse = [0 1 0].'; 
impulse = [0 1 0].'.*131071; 
up1=upsample(impulse,2);
LPF_out_1st=conv(up1,h_halfband_filtDes);
LPF_out_1st=round(LPF_out_1st); %1s17

% digital angular frequency, w (rads/sample)
% w = [0:0.001:1000]/1000*pi; % half cycle
w = [0:0.001:200]/100*pi; %one whole cycle

%------Upsample & filter-------
up2=upsample(LPF_out_1st,2);
LPF_out_2nd=conv(up2,h_halfband_filtDes_2nd);
LPF_out_2nd=round(LPF_out_2nd);

%------Print if needed-------
% fprintf("Expected impulse response of upsample then filt block\n");
% fprintf('\t%1.6f\n',LPF_out_1st);
% fprintf("End of  impulse response of upsample then filt block\n\n");
% fprintf("Expected impulse response of conversion block\n");
% expected_ir_out = LPF_out_2nd;
% fprintf('\t%1.6f\n',expected_ir_out);

%% First halfband coeff in 1s17
clc

% Find coeffs
safety=(2^0)-(2^-17);  %1s17
h_halfband_filtDes_1s17=round(h_halfband_filtDes*2^17*safety);

idx=0;
% halfband coeffs are 0s18 to account for sum_lvls being 2s16
fprintf("initial begin\n");
for i=1:round(length(h_halfband_filtDes_1s17)/2)  %for sym
% for i=1:round(length(h_halfband_filtDes_0s18))  %no reduc
    if (h_halfband_filtDes_1s17(i)<0)
        fprintf("\tHsys[%d] = -18'sd%d;\n",(idx),abs(h_halfband_filtDes_1s17(i)) );
        idx=idx+1;
    else
        fprintf("\tHsys[%d] = 18'sd%d;\n",(idx),abs(h_halfband_filtDes_1s17(i)) );
        idx=idx+1;
    end
end
fprintf("end\n");

%% halfband Time-sharing structure
clc

% ceil to account for odd tap
numCoeffs=ceil(length(h_halfband_filtDes_1s17)/2);
numMults=ceil(numCoeffs/4);

num_of_sumLvls=0; coeffs2reduce=length(h_halfband_filtDes_1s17);
tapsPerlvl=zeros( ceil(log2(coeffs2reduce)),1 );
for i=1:length(h_halfband_filtDes_1s17)
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

%% sym structure
clc


% ceil to account for odd tap
% numCoeffs=ceil(length(h_halfband_filtDes_1s17)/2);
% numMults=ceil(numCoeffs/4);

% lenny=zeros(1,121);

% num_of_sumLvls=0; coeffs2reduce=length(h_halfband_filtDes_1s17);
num_of_sumLvls=0; 
coeffs2reduce=15;
tapsPerlvl=zeros( ceil(log2(coeffs2reduce)),1 );
% for i=1:length(h_halfband_filtDes_1s17)
for i=1:coeffs2reduce
    if coeffs2reduce<=1
        break
    else
        num_of_sumLvls=num_of_sumLvls+1;coeffs2reduce=ceil(coeffs2reduce/2);
        fprintf("sum level %d has %d registers\n",i,coeffs2reduce);
        tapsPerlvl(i,1)=coeffs2reduce;
    end
end
fprintf("num of sum lvls: %d | total # of regs: %d\n",num_of_sumLvls,sum(tapsPerlvl));

%% Second halfband coeff in 1s17
clc

% Find coeffs
safety=(2^0)-(2^-17);  %1s17
h_halfband_filtDes_2nd_1s17=round(h_halfband_filtDes_2nd*2^17*safety);

idx=0;
% halfband coeffs are 0s18 to account for sum_lvls being 2s16
fprintf("initial begin\n");
for i=1:round(length(h_halfband_filtDes_2nd_1s17)/2)  %for sym
% for i=1:round(length(h_halfband_filtDes_0s18))  %no reduc
    if (h_halfband_filtDes_2nd_1s17(i)<0)
        fprintf("\tHsys[%d] = -18'sd%d;\n",(idx),abs(h_halfband_filtDes_2nd_1s17(i)) );
        idx=idx+1;
    else
        fprintf("\tHsys[%d] = 18'sd%d;\n",(idx),abs(h_halfband_filtDes_2nd_1s17(i)) );
        idx=idx+1;
    end
end
fprintf("end\n");

%% MER calculation from circuit
clear
clc
mapOutPwr= 16;
avgSqErr= 787342840896;

MER=10*log10( (2.^38)*mapOutPwr/avgSqErr);
