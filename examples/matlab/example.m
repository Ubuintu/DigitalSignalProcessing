clc
close all
clear

if isfolder('pics') == 0
    mkdir('pics')
end

x = 1:100;
y = rand(100,1);
idxmin = find(y == max(y));
idxmax = find(y == min(y));
txt = ['\leftarrow y = ',int2str(max(y))];
hold on
plot(x,y)
plot(x,y,'o','MarkerIndices',[idxmin idxmax],'MarkerFaceColor','red','MarkerSize',5)
t = text(idxmax,y(idxmax),txt);
t.Color = [153/255 153/255 255/255];
hold off
legend('random plot [0:1]');
print -dpng ./pics/test.png
close
%% testing plot function
clc

x = [0:0.01:2*pi];
y = sin(x);
yCmp = cos(x);
string = 'My test plot';
p_title = 'test_print';
t="";

% test = myplot(x,y,string,p_title);
test2 = superplot(x,y,'plotName',"My super plot",'figureName',"super_plot");
test3 = superplot(x,y,'cmpYLegend',"cos(x)",'figureName',"cosxVsSinx",'cmpY',yCmp,'yLegend',"sin(x)",'yName',"Amplitude",'xName',"Samples NOT normalized to 2\pi", ...
    'plotName',"Plotting cos(x) against sin(x)");
close(test2);
close(test3);
test4 = superplot(x,y);

testV = ones(1,1);
testV(2) = 5;

%% testing MER loop
% clear
clc
close all
% clear

idx = 1;
for i = 0:200
    if ( rem((i-1)/4,1)==0 )
        validLen(idx) = i;
        idx = idx+1;
    end
end

% Constants are double-precision by default
vec = [9 129];

% for i
    
% for i = vec(1):0.01:vec(1)
%     fprintf("i is %d coefficients\n",i);
% end
    
% for i = 0:2:10
%     fprintf("i SHOULD be EVEN and is %d\n",i);
% end

%coefficients have to be even and divisible by span w/no remainder LOOK
%INTO THIS
%beta MUST be greater than 0
% [MER_out, betaTX_out, betaRCV_out, coeff_out] = MER_opt('Nsps',4,'numCoeffs',vec,'betaTX',[0 0.001 0.2],'betaRCV',[0.12 0.01 0.12],'MER',50);
% [MER_out, betaTX_out, betaRCV_out, coeff_out] = MER_opt('Nsps',4,'numCoeffs',[25 77],'betaTX',[.01 0.01 .16],'betaRCV',[0.12 0.01 0.34],'MER',40);

% last = find(~MER_out,1);
% fileID = fopen('GSM_parameters.txt','w');
% cBeta = char(hex2dec('03b2'));
% fprintf(fileID,'%10s %10s %10s %10s\r\n','MER', 'betaTX', 'betaRCV', 'length');
% % A = [MER_out(1:last-1); betaTX_out(1:last-1); betaRCV_out(1:last-1); coeff_out(1:last-1)];
% A = [MER_out; betaTX_out; betaRCV_out; coeff_out];
% fprintf(fileID,'%10.6f %10.6f %10.6f %8.0f\r\n',A);
% fclose(fileID);

% c_idx = find(coeff_out==121);
% max_121 = max(MER_out(c_idx(1):c_idx(end)));
% desired_121 = find(MER_out>=54.0679);

DONE = ones(10,1);
finish = sum(DONE(1:5));

%% MER calc
% clc
% clear all
% close all
% den = [-0.001473028462308   0.005666223150735  -0.019416661964618  -0.041188246018261   0.083990599017613  -0.169565530125065   0.900837427479342 ...
%     0.311842632473442  -0.140969388867244   0.099871376920441  -0.088049305611010   0.023834632003521  -0.009447343197004   0.002953619390284]
% 
% pk = 0.99924965776672958;
% 
% 10*log10(pk^2/sum(den.^2));

%% Measuring OOB requirements
clear 
close all
clc

format long
% window designer from 0 to pi
% load('KaisWin.mat');

% beta = 0.146600;  %trial 1
% N = 65;
% beta = 0.116400;    %trial 2
% N = 73;
beta = 0.144400;   %trial 3
N = 121;

Nsps = 4;
span = (N-1)/4;
% digital angular frequency, w (rads/sample)
w = [0:0.001:1000]/1000*pi;

GSM = rcosdesign(beta,span,Nsps);
As = 60;
b = 0.1102*(As-8.7);

% for bk = 2.047:0.001:2.263
% for bk = 2.057:0.001:2.057
for bk = 2.202:0.001:2.202
    wn = kaiser(length(GSM), bk);
    h_TX = GSM.*wn.';
    h_GSM = GSM;

    % SRRC is a square root nyquist filter; firpm also
    % creates a sqrt nyquist filter
    M=N-1;
    beta = 0.12; Nsps=4; span=M/Nsps;
    fc=1/2/Nsps; fp=(1-beta)*fc; fs=(1+beta)*fc;
    fb = [0 fp fc fc fs .5]*2;
    a = [1 1 1/sqrt(2) 1/sqrt(2) 0 0];
    % wght vector needs to 2.4535 for passband
    wght = [2.4535 1 1];
    h_pps = firpm(M,fb,a,wght);

    % window
    h_pps = h_pps.*wn.';
%     h_pps = h_pps;

    % estimate order of SR Nyquist filter
%     ford=fb(2:end-1);
%     aord=[1 1/sqrt(2) 0];
%     sb=10^(-58/20);
%     dev=[sb 0.02 sb];
%     M_est=firpmord(ford,aord,dev);

    H_srrc = freqz(h_TX,1,w);
    H_pps = freqz(h_pps,1,w);

    % mag_H = 20*log10(abs(H));
    mag_H = 20*log10(abs(H_pps));
    baseband_ind = find( w/2/pi <= 0.14);
    OB1_ind = find(w/2/pi > 0.14 & w/2/pi <= 0.1752);
    OB2_ind = find(w/2/pi > 0.1752 & w/2/pi <= 0.42);
    OB3_ind = find(w/2/pi > 0.42);

    conv2mW = @(x) 10.^(x/20);
    conv2dBm =  @(x) 20.*log10(x);

    % For power, do i need to account for limits of SA
    spec_mW = sum(conv2mW(mag_H));
    bb_mW = sum(conv2mW(mag_H(baseband_ind(1):baseband_ind(end))));
    OB1_mW = sum(conv2mW(mag_H(OB1_ind(1):OB1_ind(end))));
    OB2_mW = sum(conv2mW(mag_H(OB2_ind(1):OB2_ind(end))));
    OB3_mW = sum(conv2mW(mag_H(OB3_ind(1):OB3_ind(end))));

    spec_dBm = conv2dBm(spec_mW);
    bb_dBm = conv2dBm(bb_mW);
    OB1_dBm = conv2dBm(OB1_mW);
    OB2_dBm = conv2dBm(OB2_mW);
    OB3_dBm = conv2dBm(OB3_mW);

    OB1_58 = bb_dBm-OB1_dBm;
    OB2_60 = bb_dBm-OB2_dBm;
    OB3_63 = bb_dBm-OB3_dBm;
    
    % can cascade firpm sqrt w/srrc, center coeff
    % isn't one BUT even symmetric
    cascade = conv(h_pps,GSM);
    cascade_SRRC = conv(GSM,GSM);
    
    num = cascade(N);
    den = zeros(floor(length(cascade)/Nsps),1);
    idx = 1;
    cnt = 0;
    for i = 1:length(cascade)
        if cnt == 0 && i ~= N
            den(idx) = cascade(i);
            cnt = cnt + 1;
            idx = idx + 1;
        elseif cnt >= Nsps-1
            cnt = 0;
        else
            cnt = cnt + 1;
        end
    end
    MER_theo = 10*log10( num^2/sum(den.^2) );
%     fprintf("Power transmitted in OB1 is %2.6f dB\n", OB1_58);
%     fprintf("Power transmitted in OB2 is %2.6f dB\n", OB2_60);
%     fprintf("Power transmitted in OB3 is %2.6f dB\n", OB3_63);
%     fprintf("MER is %2.6f | beta for kaiser: %2.6f\n",MER_theo,bk);
%     fprintf("OB1: %2.6f | OB2: %2.6f | OB3: %2.6f | MER: %2.6f | Bk: %2.4f\n",OB1_58,OB2_60,OB3_63,MER_theo,bk);
%     fprintf("Bk: %2.4f\n",bk);
    if OB1_58 > 58 && OB2_60 > 60 && OB3_63 > 63 && MER_theo >= 40
        fprintf("*************MET SPEC*************************\n");
        fprintf("Power transmitted in OB1 is %2.6f dB and greater by %2.6f dB from 58 dB requirement\n", OB1_58, OB1_58-58);
        fprintf("Power transmitted in OB2 is %2.6f dB and greater by %2.6f dB from 60 dB requirement\n", OB2_60, OB2_60-60);
        fprintf("Power transmitted in OB3 is %2.6f dB and greater by %2.6f dB from 63 dB requirement\n", OB3_63, OB3_63-63);
        fprintf("MER is %2.6f | beta for kaiser: %2.6f\n",MER_theo,bk);
    end
end

TX_MR = superplot(w/2/pi,20*log10(abs(H_pps)),'plotName',"Magnitude Response of PPS",'figureName',"PracticalPSResp",'yName',"Magnitude (dB)",...
    'xName',"Frequency (cycles/sample)",'yLegend',"SQRT FIRPM",'cmpY',20*log10(abs(H_srrc)),'cmpYLegend',"SRRC",...
    'plotAxis',[0 0.5 -100 20]);
hold on
% OOB requirement 1
plot([0.14 0.14],[-200 -58],'--k');
plot([0.14 0.1752],[-58 -58],'--k');
plot([0.1752 0.1752],[-200 -58],'--k');
% OOB requirement 2
plot([0.1752 0.1752],[-200 -60],':R');
plot([0.1752 0.42],[-60 -60],':R');
plot([0.42 0.42],[-200 -60],':R');
% OOB requirement 3
plot([0.42 0.42],[-200 -63],'g');
plot([0.42 0.5],[-63 -63],'g');
plot([0.5 0.5],[-200 -63],'g');
legend('Sqrt firpm','SRRC','OB1','OB1','OB1','OB2','OB2','OB2','OB3','OB3','OB3');
hold off
location = strcat('./pics/','PracticalPSResp','.png');
print(TX_MR, '-dpng', location);
close(TX_MR);

% scale desired coefficients
maxi = sum(abs(h_pps));
scaling = (1-2^-17)/maxi;

h_pps_1s17= round(h_pps*scaling*2^17);
if sum(abs(h_pps_1s17/2^17) > 1-2^-17)
    fprintf("Error need to scaled down h_pps more\n");
    return
end

h_pps_coeffs = unique(h_pps_1s17,'stable');


%% Test cascade
clear 
% close all
clc

coeff = 65;
Nsps = 4;
beta = 0.146600;

span = (coeff-1)/Nsps;
rcv = rcosdesign(beta, span, Nsps);

% SR Nyquist filter
bb = 2.0; spans = 25;
M = coeff-1;
fc = 1/(2*Nsps);fp=(1-.12)*fc; fs=(1+.12)*fc;
fb = [0 fp fc fc fs .5]*2;
a = [1 1 1/sqrt(2) 1/sqrt(2) 0 0];
wght = [2.4535 1 1];
h_pps=firpm(M,fb,a,wght);
w = [0:0.001:1000]/1000*pi;
wnNorm=kaiser(coeff,2.0);
wnGr=kaiser(coeff,3);
wnLT=kaiser(coeff,1);

H_pps = freqz(h_pps,1,w);
H_ppsGrBk=freqz( conv(h_pps,wnGr),1,w );
H_ppsNormBk=freqz( conv(h_pps,wnNorm),1,w );
H_ppsLTBk=freqz( conv(h_pps,wnLT),1,w );

figName="PPS_with_65coeffs";
pps_plot = superplot(w/2/pi,20*log10(abs(H_pps)),'cmpY',20*log10(H_ppsNormBk),'figureName',figName,...
    'plotAxis',[0 0.5 -100 40]);
hold on
plot(w/2/pi,20*log10(abs(H_ppsGrBk)),"-.g");
plot(w/2/pi,20*log10(abs(H_ppsLTBk)),"--m");
legend('beta=0','beta=2.0','beta=3','beta=1');
hold off
location = strcat('./pics/',figName,'.png');
print(pps_plot, '-dpng', location);

% Too much theory to figure out MER for LPF

%% Test PPS_opt
% clc
% clear 
% close all
% 
% % Constants are double-precision by default
% vec = [65 129];
% 
% [MER_out, betaTX_out, betaRCV_out, coeff_out, betaKais_out] = PPS_opt('Nsps',4,...
%     'numCoeffs',vec,'betaTX',[0 0.001 0.2],'betaRCV',[0.12 0.01 0.12],'MER',40,'betaKais',[0 0.01 10]);

%% File IO
clear all
close all
clc

fileID = fopen('GSM_parameters_SRRC.txt');
formatSpec = '%s';
N = 4;
C_text = textscan(fileID,formatSpec,N);
C_data0 = textscan(fileID,'%f %f %f %f');
fclose(fileID);

%% Designing polyphase filter
clear;close all;clc; load('validLen.mat');

beta=0.12; N=21; Nsps=4; span=(N-1)/4;

% rcv = rcosdesign(beta,span, Nsps);
load('rcv.mat');
worse_case_output = sum(abs(rcv));
scaling = (1-2^-17)/worse_case_output;
rcv_1s17=round( rcv*scaling*2^17 );tx=rcv;

sym_mults=round(length(rcv)/2);
poly_mults=sym_mults/Nsps;

