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

clc
clear
close all
format longG
%% Deliverable Parameter's | idx TX & RCV: 474
clc; close all;
Nsps=4; 
% N=93; betaTx=0.173; betaRcv=0.198; betaK=0.5; % Not sure if too smoll; Best setting atm
% N=101; betaTx=0.167; betaRcv=0.178; betaK=1.5;
% N=101; betaTx=0.158; betaRcv=0.199; betaK=1.8;
% N=93; betaTx=0.174; betaRcv=0.197; betaK=0.5;

%        MER     betaTX    betaRCV     length idx TX & RCV        OB1        OB2        OB3 b Kaiser     weight 
%  42.017901   0.145500   0.182100        101     141106  60.037561  64.921997  64.304794   0.000000         20 
N=101; betaTx=0.145500; betaRcv=0.182100; betaK=0;


% *************MET SPEC*************************
% TX's β: 0.1430 | RCV's β: 0.1780 | idx TX & RCV: 1364
% OB1: 64.634703 | OB2: 64.497576 | OB3: 63.146043 | MER: 40.334376 | Bk: 1.6000 | Beta nominal: 0.1430 | 
% baseband bnd frequency: 0.1400 | OB1 bnd frequency: 0.1752 | OB2 bnd frequency: 0.4200 | OB3 bnd frequency: 0.7000 |
% N=101; betaTx=0.1480; betaRcv=0.1690; betaK=1.6;

M=N-1; span=M/Nsps; h_GSPS=rcosdesign(betaTx,span,Nsps); h_GSM=rcosdesign(betaRcv,span,Nsps); wn=kaiser(N,betaK);
fc=1/2/Nsps; fp=(1-betaTx)*fc; fs=(1+betaTx)*fc; fb=[0 fp fc fc fs .5]*2; a=[1 1 1/sqrt(2) 1/sqrt(2) 0 0]; 
% safety=1-2^-17; %best scaling atm 
safety=1-2^-17; 
wght=[2.4535 1 20]; 
h_PPS=firpm(M,fb,a,wght); 
h_PPS=h_PPS.*wn.'; 
wc_PPS=sum(abs(h_PPS)); 
wc_GSPS=sum(abs(h_GSPS)); 
wc_GSM=sum(abs(h_GSM));
% h_PPS=safety*h_PPS/wc_PPS; h_GSPS=safety*h_GSPS/wc_GSPS; h_GSM=safety*h_GSM/wc_GSM; %comment this to see if peak agrees
h_GSMGSPS=conv(h_GSPS,h_GSM); h_GSMPPS=conv(h_PPS,h_GSM);

numGSPS = h_GSMGSPS(N); denGSPS = zeros(floor(length(h_GSMGSPS)/Nsps),1);   %Gold Standard Pulse Shaping
numGPPS = h_GSMPPS(N); denGPPS = zeros(floor(length(h_GSMPPS)/Nsps),1);     %Practical Pulse Shaping

idx = 1;cnt = 0;
for i = 1:2*N-1
    if cnt == 0 && i ~= N
        denGSPS(idx)=h_GSMGSPS(i); denGPPS(idx)=h_GSMPPS(i);
        cnt = cnt + 1;idx = idx + 1;
    elseif cnt >= Nsps-1
        cnt = 0;
    else
        cnt = cnt + 1;
    end
end

MER_GSPS=10*log10(numGSPS^2/sum(denGSPS.^2)); MER_GPPS=10*log10(numGPPS^2/sum(denGPPS.^2));
h_PPS_0s18=round(h_PPS.*2^18); h_GSPS_0s18=round(h_GSPS*2.^18); h_GSM_0s18=round(h_GSM*2.^18);

% values for LUT 4-ASK mapper; ensure output of 4-ASK mapper is a 1s17
% input to transmit filter
% a = safety/3;
a = safety/4;
% a = 1;    % to see possible inputs from LUT
ASK_out = [-3*a -a a 3*a];

in1 = ASK_out;
in2 = ASK_out;

% add row and column vectors to see possible combinations
possible_inputs = in1 + in2';
possible_inputs = uniquetol(possible_inputs);
POSSINPUT= combine(possible_inputs, ASK_out.'); 
POSS_IN=round(POSSINPUT.*2^16);
% 1s17 input is truncated to 2s16 sum_level_1 in filter
possible_inputs_verilog = round(possible_inputs*2^16); 
MF_PPS=round(ASK_out.'*h_PPS.*2^17*safety);    % 0s18 gives me smoothest stp; idk y
% MF_PPS=round(POSSINPUT*h_PPS.*2^16);    
MF_GSPS=round(ASK_out.'*h_GSPS_0s18);

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
        if j == rows+1 && h_PPS_0s18(i) >= 0
            fprintf('\tHsys[%d][%d] = 18''sd%s;\n',(j-1),(i-1),num2str( abs(h_PPS_0s18(i)) ) );
        elseif j == rows+1 && h_PPS_0s18(i) < 0
            fprintf('\tHsys[%d][%d] = -18''sd%s;\n',(j-1),(i-1),num2str( abs(h_PPS_0s18(i)) ) );
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
%% GSPS coeffs
clc
[rows, cols] = size(MF_GSPS);
% fprintf('0s18 Coefficients for GSPS filter:\n');
fprintf("\ninitial begin\n");
for i = 1:ceil(cols/2)
    for j = 1:rows+1
        if j == rows+1 && h_GSPS_0s18(i) > 0
            fprintf('\tHsys[%d][%d] = 18''sd%s;\n',(j-1),(i-1),num2str( abs(h_GSPS_0s18(i)) ) );
        elseif j == rows+1 && h_GSPS_0s18(i) < 0
            fprintf('\tHsys[%d][%d] = -18''sd%s;\n',(j-1),(i-1),num2str( abs(h_GSPS_0s18(i)) ) );
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

%% GSM
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