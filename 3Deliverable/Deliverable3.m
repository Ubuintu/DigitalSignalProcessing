%% Deliverables Specifications p.106-108
% 1. A gold standard for the pulse shaping filter for a CATV 16-QAM modem. (Just need one - not building both I and Q.)
%     a) The pulse shaping filter must run at 4 times the symbol rate, i.e., 4 samples per symbol. The clock used to clock the filter is 
%        referred to as the sampling clock and is denoted sam_clk.
%     b) The sampling rate is 1/4 the rate of the system clock. The system clock, referred to as sys_clk, is to run at 25 Msamples/second 
%        and the sampling rate is to be 6.25 Msamples/second.
%     c) nominal roll-off factor for the pulse shaping is ? = 0.12
%     d) The channel bandwidth at RF is (1+?)samples/symbol×sampling rate = (1+0.12)/4 ×6.25 Msam/sec = 1.75 MHz. The channel bandwidth at 
%        baseband is 1/2 the RF bandwidth, which isBW_baseband = 1.75/2 = 0.875 MHz
 
% 2. A gold standard for the matched filter for a CATV 16-QAM modem. (Just need one - not building both I and Q.)
%     a) p.107-108 pt.7

% 3. A practical cost effective pulse shaping filter. (Just need one - not building both I and Q.)
%     a) NOTE: specifications in GSPS apply here as well; following specs
%     is for PPS ONLY
%     b) p.107 pt.6
%     c) p.108 pt.8-9

%% Deliverable Parameter's | idx TX & RCV: 474
clc; clear; close all; format longG
Nsps=4; 
% N=93; betaTx=0.173; betaRcv=0.198; betaK=0.5; % Not sure if too smoll; Best setting atm
% N=101; betaTx=0.167; betaRcv=0.178; betaK=1.5;
% N=101; betaTx=0.158; betaRcv=0.199; betaK=1.8;
% N=93; betaTx=0.174; betaRcv=0.197; betaK=0.5;

% line 1063 in MOAP
%        MER     betaTX    betaRCV     length idx TX & RCV        OB1        OB2        OB3 b Kaiser     weight 
%  42.017901   0.145500   0.182100        101     141106  60.037561  64.921997  64.304794   0.000000         20 
N=101; betaTx=0.145500; betaRcv=0.182100; betaK=0;  %Amplitude on SA might changed since coeffs are adjusted to 1s17 (2^18 before)


% *************MET SPEC*************************
% TX's β: 0.1430 | RCV's β: 0.1780 | idx TX & RCV: 1364
% OB1: 64.634703 | OB2: 64.497576 | OB3: 63.146043 | MER: 40.334376 | Bk: 1.6000 | Beta nominal: 0.1430 | 
% baseband bnd frequency: 0.1400 | OB1 bnd frequency: 0.1752 | OB2 bnd frequency: 0.4200 | OB3 bnd frequency: 0.7000 |
% N=101; betaTx=0.1480; betaRcv=0.1690; betaK=1.6;

M=N-1; span=M/Nsps; h_GSPS=rcosdesign(betaTx,span,Nsps); h_GSM=rcosdesign(betaRcv,span,Nsps); wn=kaiser(N,betaK);
fc=1/2/Nsps; fp=(1-betaTx)*fc; fs=(1+betaTx)*fc; fb=[0 fp fc fc fs .5]*2; a=[1 1 1/sqrt(2) 1/sqrt(2) 0 0]; 
% safety=1-2^-17; %best scaling atm 
safety=1-2^-16; 
wght=[2.4535 1 20]; 
h_PPS=firpm(M,fb,a,wght); 
h_PPS=h_PPS.*wn.'; 



% **scale coeffs to be 1s17 where scaling is based on wc input from mapper**
% wc_PPS=sum(abs(h_PPS));
% wc_PPS=sum(abs(h_PPS)*.75);  
wc_GSM=sum(abs(h_GSM));
% wc_GSM=sum(abs(h_GSM)*.75)*safety;
% wc_GSPS=sum(abs(h_GSPS)*.75); 

% ** worse case input upsampled **
wc_input=ones(1,ceil(N/4));
wc_input0=upsample(wc_input.*.75,Nsps);
% wc_input1=upsample(wc_input.*.75,Nsps,1);
% wc_input2=upsample(wc_input.*.75,Nsps,2);
% wc_input3=upsample(wc_input.*.75,Nsps,3);

wc_PPS0=abs(h_PPS).*wc_input0(1:101);
wc_PPS_0=sum(wc_PPS0);
% wc_PPS1=abs(h_PPS).*wc_input1(1:101);
% wc_PPS_1=sum(wc_PPS1);
% wc_PPS2=abs(h_PPS).*wc_input2(1:101);
% wc_PPS_2=sum(wc_PPS2);
% wc_PPS3=abs(h_PPS).*wc_input3(1:101);
% wc_PPS_3=sum(wc_PPS3);

% find wc output w/convolution
% wc0_h_PPS = conv(h_PPS,wc_input0);
% wc_pk0=sum(abs(wc0_h_PPS));
% wc1_h_PPS = conv(h_PPS,wc_input1);
% wc_pk1=sum(abs(wc1_h_PPS));
% wc2_h_PPS = conv(h_PPS,wc_input2);
% wc_pk2=sum(abs(wc2_h_PPS));

% uncomment to scale to 1s17 WC/comment for noscale; NEED to scale for
% headroom    %scale headroom so that pk is less than 1s17
% h_PPS=safety.*h_PPS/wc_PPS_0;     %scale headroom so that peak of conv is ~1
% h_PPS=safety.*h_PPS/max(h_PPS)*.7;
% scale_PPS=sum(abs(h_PPS));

% out of alternatives
h_PPS=h_PPS.*2;

% Find wc scaling factor for GSM
% theo_GSM = conv(wc_PPS_0,h_GSM);
% scale_GSM = sum(abs(theo_GSM));

% h_GSPS=safety*h_GSPS/wc_GSPS;  %comment this to see if peak agrees
h_GSM=safety*h_GSM/wc_GSM;  % scaling down coeffs of GSM to wc 1s17 reduce MER by a decimal of a dB
% h_GSM=.85*h_GSM/scale_GSM;
% h_GSM=safety*h_GSM/max(abs(h_GSM));
% h_GSM=h_GSM.*.7;

% Change Coeff
% load('h_PPS.mat');
% h_PPS = h_pps/2^17;
scale_GSM=sum(abs(h_PPS));


h_GSMGSPS=conv(h_GSPS,h_GSM); 
h_GSMPPS=conv(h_PPS,h_GSM);
h_GSMGSM=conv(h_GSM,h_GSM); %for debugging GSM

%MER for GS & Practical conv
numGSPS = h_GSMGSPS(N); denGSPS = zeros(floor(length(h_GSMGSPS)/Nsps),1);   %Gold Standard Pulse Shaping
numGPPS = h_GSMPPS(N); denGPPS = zeros(floor(length(h_GSMPPS)/Nsps),1);     %Practical Pulse Shaping
numGSGS = h_GSMGSM(N); denGSGS = zeros(floor(length(h_GSMGSM)/Nsps),1);     %Practical Pulse Shaping

idx = 1;cnt = 0;
for i = 1:2*N-1
    if cnt == 0 && i ~= N
        denGSPS(idx)=h_GSMGSPS(i); denGPPS(idx)=h_GSMPPS(i);
        denGSGS(idx)=h_GSMGSM(i);
        cnt = cnt + 1;idx = idx + 1;
    elseif cnt >= Nsps-1
        cnt = 0;
    else
        cnt = cnt + 1;
    end
end

MER_GSPS=10*log10(numGSPS^2/sum(denGSPS.^2)); MER_PPS=10*log10(numGPPS^2/sum(denGPPS.^2));
MER_GSGS=10*log10(numGSGS^2/sum(denGSGS.^2));
% !!! COEFFS ARE SMALL ENOUGH FOR 0s18 BUT should be 1s17 for consistent
% format thruout
h_PPS_1s17=round(h_PPS.*2^17); 
h_GSPS_1s17=round(h_GSPS*2.^17);
% GSM w/o reduction
h_GSM_1s17=round(h_GSM*2.^17);
% GSM Time-Share
h_GSM_0s18=round(h_GSM*2.^18);

% values for LUT 4-ASK mapper; ensure output of 4-ASK mapper is a 1s17
% input to transmit filter
% a = safety/3;
a = safety/4;
% a = 1;    % to see possible inputs from LUT
ASK_out = [-3*a -a a 3*a];

% 1s17 input is truncated to 2s16 sum_level_1 in filter
% coeffs of PPS are less
MF_PPS=round(ASK_out.'*h_PPS.*2^17*safety);
MF_GSPS=round(ASK_out.'*h_GSPS.*2^17*safety);

num_of_sumLvls=0; coeffs2reduce=N;
tapsPerlvl=zeros( ceil(log2(coeffs2reduce)),1 );
for i=1:N
    if coeffs2reduce<=1
        break
    else
        num_of_sumLvls=num_of_sumLvls+1;coeffs2reduce=ceil(coeffs2reduce/2);
        fprintf("sum level %d has %d registers\n",i,coeffs2reduce);
        tapsPerlvl(i,1)=coeffs2reduce;
    end
end
fprintf("num of sum lvls: %d | total # of regs: %d\n",num_of_sumLvls,sum(tapsPerlvl));

%% PPS coeffs
clc
[rows, cols] = size(MF_PPS);
% fprintf('0s18 Coefficients for PPS filter:\n\n');
fprintf("initial begin\n");
for i = 1:cols
    for j = 1:rows+1
        if j == rows+1 && h_PPS_1s17(i) >= 0
            fprintf('\tHsys[%d][%d] = 18''sd%s;\n',(j-1),(i-1),num2str( abs(h_PPS_1s17(i)) ) );
        elseif j == rows+1 && h_PPS_1s17(i) < 0
            fprintf('\tHsys[%d][%d] = -18''sd%s;\n',(j-1),(i-1),num2str( abs(h_PPS_1s17(i)) ) );
        elseif MF_PPS(j,i) > 0
            fprintf('\tHsys[%d][%d] = 18''sd%s;\n',(j-1),(i-1),num2str( abs(MF_PPS(j,i)) ) );
        elseif MF_PPS(j,i) < 0
            fprintf('\tHsys[%d][%d] = -18''sd%s;\n',(j-1),(i-1),num2str( abs(MF_PPS(j,i)) ) );
        else
            fprintf('\tHsys[%d][%d] = 18''sd%s;\n',(j-1),(i-1),num2str( abs(MF_PPS(j,i)) ) );
        end
    end
end
fprintf("end\n");
% fprintf('\nEnd of 0s18 Coefficients for PPS filter:\n\n');

%% Debug PPS coeff
clc
for i=1:round(length(h_PPS_1s17)/2)
    if (h_PPS_1s17(i)<0)
        fprintf("\tHsys[%d] = -18'sd%d;\n",(i-1),abs(h_PPS_1s17(i)) );
    else
        fprintf("\tHsys[%d] = 18'sd%d;\n",(i-1),abs(h_PPS_1s17(i)) );
    end
end

%% GSPS coeffs
clc
[rows, cols] = size(MF_GSPS);
% fprintf('0s18 Coefficients for GSPS filter:\n');
fprintf("\ninitial begin\n");
for i = 1:cols
    for j = 1:rows+1
        if j == rows+1 && h_GSPS_1s17(i) > 0
            fprintf('\tHsys[%d][%d] = 18''sd%s;\n',(j-1),(i-1),num2str( abs(h_GSPS_1s17(i)) ) );
        elseif j == rows+1 && h_GSPS_1s17(i) < 0
            fprintf('\tHsys[%d][%d] = -18''sd%s;\n',(j-1),(i-1),num2str( abs(h_GSPS_1s17(i)) ) );
        elseif MF_GSPS(j,i) > 0
            fprintf('\tHsys[%d][%d] = 18''sd%s;\n',(j-1),(i-1),num2str( abs(MF_GSPS(j,i)) ) );
        elseif MF_GSPS(j,i) < 0
            fprintf('\tHsys[%d][%d] = -18''sd%s;\n',(j-1),(i-1),num2str( abs(MF_GSPS(j,i)) ) );
        else
            fprintf('\tHsys[%d][%d] = 18''sd%s;\n',(j-1),(i-1),num2str( abs(MF_GSPS(j,i)) ) );
        end
    end
end
fprintf("end\n");
% fprintf('End of 0s18 Coefficients for GSPS filter:\n\n');

%% Debug GSPS coeff
clc
for i=1:round(length(h_GSPS_1s17)/2)
    if (h_PPS_1s17(i)<0)
        fprintf("\tHsys[%d] = -18'sd%d;\n",(i-1),abs(h_GSPS_1s17(i)) );
    else
        fprintf("\tHsys[%d] = 18'sd%d;\n",(i-1),abs(h_GSPS_1s17(i)) );
    end
end



%% GSM no reduction Coeff (1s17)
clc
fprintf("initial begin\n")
for i=1:round(length(h_GSM_1s17)/2)
    if (h_GSM_1s17(i)<0)
        fprintf("\tHsys[%d] = -18'sd%d;\n",(i-1),abs(h_GSM_1s17(i)) );
    else
        fprintf("\tHsys[%d] = 18'sd%d;\n",(i-1),abs(h_GSM_1s17(i)) );
    end
end
fprintf("end\n")

%% GSM Time-sharing structure
clc

% ceil to account for odd tap
numCoeffs=ceil(N/2);
numMults=ceil(numCoeffs/4);

num_of_sumLvls=0; coeffs2reduce=N;
tapsPerlvl=zeros( ceil(log2(coeffs2reduce)),1 );
for i=1:N
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



%% GSM Time-sharing Coeff (0s18)
clc
fprintf("initial begin\n")
for i=1:round(length(h_GSM_0s18)/2)
    if (h_GSM_0s18(i)<0)
        fprintf("\tHsys[%d] = -18'sd%d;\n",(i-1),abs(h_GSM_0s18(i)) );
    else
        fprintf("\tHsys[%d] = 18'sd%d;\n",(i-1),abs(h_GSM_0s18(i)) );
    end
end
fprintf("end\n")


%% MER calculation from circuit
clear
clc
% example; should give MER of 55 dB from D2
% mapOutPwr=5116;
% avgSqErr=4716353999;

% GSM to GSM no reduc
% mapOutPwr= 20491;
% avgSqErr= 35657948656;

% PPS to GSM % Reset is super jank; need to time it right; reset until
% map_out_pwr is ~1.5k & err_square is 36235604970566
mapOutPwr= 1658;
avgSqErr= 29455612887;

% GSPS to GSM % 
% mapOutPwr= 1653;
% avgSqErr= 4437263996;

MER=10*log10( (2.^38)*mapOutPwr/avgSqErr);