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
clear

idx = 1;
for i = 0:200
    if ( rem((i-1)/4,1)==0 )
        validLen(idx) = i;
        idx = idx+1;
    end
end

% Constants are double-precision by default; N=85 found nothing
vec = [121 125];

% for im
    
% for i = vec(1):0.01:vec(1)
%     fprintf("i is %d coefficients\n",i);
% end
    
% for i = 0:2:10
%     fprintf("i SHOULD be EVEN and is %d\n",i);
% end

%coefficients have to be even and divisible by span w/no remainder LOOK
%INTO THIS
%beta MUST be greater than 0
[MER_out, betaTX_out, betaRCV_out, coeff_out] = MER_opt('Nsps',4,'numCoeffs',vec,'betaTX',[0.1 0.01 0.2],'betaRCV',[0.1 0.01 0.2],'MER',50);
% [MER_out, betaTX_out, betaRCV_out, coeff_out] = MER_opt('Nsps',4,'numCoeffs',[25 77],'betaTX',[.01 0.01 .16],'betaRCV',[0.12 0.01 0.34],'MER',40);

% last = find(~MER_out,1);
fileID = fopen('GSM_parameters.txt','w');
cBeta = char(hex2dec('03b2'));
fprintf(fileID,'%10s %10s %10s %10s\r\n','MER', 'betaTX', 'betaRCV', 'length');
% A = [MER_out(1:last-1); betaTX_out(1:last-1); betaRCV_out(1:last-1); coeff_out(1:last-1)];
A = [MER_out; betaTX_out; betaRCV_out; coeff_out];
fprintf(fileID,'%10.6f %10.6f %10.6f %8.0f\r\n',A);
fclose(fileID);

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
cBeta = char(hex2dec('03b2'));

format long
% window designer from 0 to pi
% load('KaisWin.mat');
% load('windowKais101.mat');

% fileID = fopen('GSM_parameters_89-121_B1-0.001-2.txt'); %89-121.txt
% fileID = fopen('GSM_parameters_73-81.txt'); %73-81.txt
% fileID = fopen('GSM_parameters_85-105_B1-0.0001-2.txt'); %85-105_B1-0.0001-2.txt
% fileID = fopen('GSM_parameters_97-121_B1-0.001-2.txt'); 
fileID = fopen('GSM_parameters.txt'); 
formatSpec = '%s';
N = 4;
C_text = textscan(fileID,formatSpec,N);
C_data0 = textscan(fileID,'%f %f %f %f');
fclose(fileID);


fileID = fopen('MOAP.txt','A');
cBeta = char(hex2dec('03b2'));
% ********************** Comment this out after first run ***********
% fprintf(fileID,'%10s %10s %10s %10s %10s %10s %10s %10s %10s %10s \r\n','MER', 'betaTX', 'betaRCV', 'length', 'idx TX & RCV', 'OB1', 'OB2', 'OB3','b Kaiser','weight');

vTX_B=C_data0{1,2}.'; vRCV_B=C_data0{1,3}.'; vLen=C_data0{1,4}.';
% idx_101=find(vLen==101); idx_105=find(vLen==105); idx_109=find(vLen==109); idx_113=find(vLen==113);  idx_117=find(vLen==117);%89-121.txt
% idx_73=find(vLen==73); idx_81=find(vLen==93); idx_97=find(vLen==97); idx_101=find(vLen==101); idx_109=find(vLen==109);  %73-81.txt
% idx_85=find(vLen==85); idx_89=find(vLen==89); idx_93=find(vLen==93); idx_97=find(vLen==97); idx_101=find(vLen==101); idx_105=find(vLen==105); idx_109=find(vLen==109);  %85-105_B1-0.0001-2.txt
idx_121=find(vLen==121); idx_125=find(vLen==125);  %

% #TX&RCV length; RCV rolloff here
% beta = 0.146600;  %trial 1
% N = 65;
% beta = 0.116400;    %trial 2
% N = 73;
% beta = 0.144400;   %trial 3
% N = 121;
% beta_Rcv = 0.188000;     %trial 18 i stop counting bruh
% N = 101;
% beta_Rcv = vRCV_B;     %trial 18 i stop counting bruh
% N = 93;


% digital angular frequency, w (rads/sample)
% w = [0:0.001:1000]/1000*pi; %0-0.5
w = [0:0.001:200]/100*pi; %one whole cycle

N = 121;
Nsps = 4;
span = (N-1)/4;
% for bk = 1.5:0.01:2
% for bk = 0.3:0.1:0.3
for bk = 0:0.1:10
% for bk = 0.0:0.1:0.0
% for bk = 1:1
% for bk = 2:0.1:2
%     for idx_TXnRCV = idx_101(639):(idx_101(639))
%     for idx_TXnRCV = idx_105(47):(idx_105(47))  %take matlab indx & open idx_N variable
%     for idx_TXnRCV = idx_101(1063):(idx_101(1063))
%     for idx_TXnRCV = idx_121(2053):(idx_121(2053))
%     for idx_TXnRCV = idx_93(4):(idx_93(5))
    for idx_TXnRCV = idx_121(1):idx_121(end)
%     for idx_TXnRCV = 505:513
        b_nom = vTX_B(idx_TXnRCV);
        beta_Rcv = vRCV_B(idx_TXnRCV);
        GSM = rcosdesign(beta_Rcv,span,Nsps);
        wn = kaiser(length(GSM), bk);
%         wn = WinKaiser;
%         h_TX = GSM.*wn.';
        h_TX = rcosdesign(b_nom,span,Nsps).*wn.';
        h_GSM = GSM;

        % SRRC is a square root nyquist filter; firpm also
        % creates a sqrt nyquist filter
        M=N-1; Nsps=4; span=M/Nsps;
        fc=1/2/Nsps; fp=(1-b_nom)*fc; fs=(1+b_nom)*fc;
        fb = [0 fp fc fc fs .5]*2;
        a = [1 1 1/sqrt(2) 1/sqrt(2) 0 0];
        % wght vector needs to 2.4535 for passband
        wght = [2.4535 1 1];   %10 for N=97; 20 for N=91-89; 40 for N>90
        h_pps = firpm(M,fb,a,wght);

        % window
        h_pps = h_pps.*wn.';
    %     h_pps = h_pps;
        sam_r8 = 6.25;

        % estimate order of SR Nyquist filter | ford=fb(2:end-1);aord=[1 1/sqrt(2) 0];sb=10^(-58/20);dev=[sb 0.02 sb];M_est=firpmord(ford,aord,dev);
        H_srrc = freqz(h_TX,1,w); H_pps = freqz(h_pps,1,w);
        
        mag_H = (abs(H_pps));
        % units of cycles/sample
        bnd_BB=(1+.12)/Nsps/2; 
        bnd_OB1=bnd_BB+(.22/sam_r8); 
        bnd_OB2=bnd_OB1+(1.53/sam_r8); 
        bnd_OB3=bnd_OB2+(1.75/sam_r8);
        ind_BB = find( w/2/pi <= bnd_BB);
        ind_OB1 = find(w/2/pi>=bnd_BB & w/2/pi<=bnd_OB1);
        ind_OB2 = find(w/2/pi>=bnd_OB1 & w/2/pi<=bnd_OB2);
        ind_OB3 = find(w/2/pi>=bnd_OB2 & w/2/pi<=bnd_OB3);

        conv2Lin = @(x) 10.^(x/20);
        conv2dB =  @(x) 10.*log10(x);
 
        % Power is the ratio of 2 power quantities and can be referred to
        % as gain in dB. Comparing power requires the integral, the
        % integral can also be thought as the sum of the area as well;
        % sum(magnitude in linear units^2) is integrating each power of each frequency
        
        pwr_BB=2*sum( mag_H(ind_BB(1):ind_BB(end)).^2 );
        pwr_OB1=sum(mag_H(ind_OB1(1):ind_OB1(end)).^2);
        pwr_OB2=sum(mag_H(ind_OB2(1):ind_OB2(end)).^2);
        pwr_OB3=sum(mag_H(ind_OB3(1):ind_OB3(end)).^2);

        % calculate power ratio to signal to OB channels\
        dB_OB1 = conv2dB(pwr_BB/pwr_OB1);
        dB_OB2 = conv2dB(pwr_BB/pwr_OB2);
        dB_OB3 = conv2dB(pwr_BB/pwr_OB3);

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
%         future considerations append to txtfile
        if dB_OB1 > 58 && dB_OB2 > 60 && dB_OB3 > 63 && MER_theo >= 40
            fprintf("\n*************MET SPEC*************************\n");
            fprintf("TX's %s: %1.4f | RCV's %s: %1.4f | idx TX & RCV: %d\n",cBeta,b_nom,cBeta,beta_Rcv,idx_TXnRCV);
            fprintf("OB1: %2.6f | OB2: %2.6f | OB3: %2.6f | MER: %2.6f | Bk: %2.4f | Beta nominal: %2.4f | \n",dB_OB1,dB_OB2,dB_OB3,MER_theo,bk, b_nom);
            fprintf("baseband bnd frequency: %2.4f | OB1 bnd frequency: %2.4f | OB2 bnd frequency: %2.4f | OB3 bnd frequency: %2.4f |\n", bnd_BB, bnd_OB1, bnd_OB2, bnd_OB3);
            fprintf("weight: ");disp(wght);
            %fprintf('MER', 'betaTX', 'betaRCV', 'length', 'idx TX & RCV', 'OB1', 'OB2', 'OB3','beta Kaiser','weight');
            A=[MER_theo, b_nom, beta_Rcv, N, idx_TXnRCV, dB_OB1, dB_OB2, dB_OB3, bk, wght(3)];
            fprintf(fileID,'%10.6f %10.6f %10.6f %10d %10d %10.6f %10.6f %10.6f %10.6f %10d \r\n',A);
        end
    end
end
fclose(fileID);

TX_MR = superplot(w/2/pi,20*log10(abs(H_pps)),'plotName',"Magnitude Response of PPS",'figureName',"PracticalPSResp",'yName',"Magnitude (dB)",...
    'xName',"f0, frequency (cycles/sample)",'yLegend',"SQRT FIRPM",'cmpY',20*log10(abs(H_srrc)),'cmpYLegend',"SRRC",...
    'plotAxis',[0 w(end)/2/pi -200 10]);

hold on
% OOB requirement 1
plot([bnd_BB bnd_BB],[-200 -58],'--k');
plot([bnd_BB bnd_OB1],[-58 -58],'--k');
plot([bnd_OB1 bnd_OB1],[-200 -58],'--k');
% OOB requirement 2
plot([bnd_OB1 bnd_OB1],[-200 -60],':R');
plot([bnd_OB1 bnd_OB2],[-60 -60],':R');
plot([bnd_OB2 bnd_OB2],[-200 -60],':R');
% OOB requirement 3
plot([bnd_OB2 bnd_OB2],[-200 -63],'g');
plot([bnd_OB2 bnd_OB3],[-63 -63],'g');
plot([bnd_OB3 bnd_OB3],[-200 -63],'g');
legend('Sqrt firpm','SRRC','OB1','OB1','OB1','OB2','OB2','OB2','OB3','OB3','OB3');
hold off
location = strcat('./pics/','PracticalPSResp','.png');
print(TX_MR, '-dpng', location);
% close(TX_MR);

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
beta_Rcv = 0.146600;

span = (coeff-1)/Nsps;
rcv = rcosdesign(beta_Rcv, span, Nsps);

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

beta_Rcv=0.12; N=21; Nsps=4; span=(N-1)/4;

% rcv = rcosdesign(beta,span, Nsps);
load('rcv.mat');
worse_case_output = sum(abs(rcv));
scaling = (1-2^-17)/worse_case_output;
rcv_1s17=round( rcv*scaling*2^17 );tx=rcv;

sym_mults=round(length(rcv)/2);
poly_mults=sym_mults/Nsps;

%% Testing roll off cascaded
clc; clear; close all;

N=41; Nsps=4; span=(N-1)/4;

rcv = rcosdesign(0.1,span, Nsps); tx = rcosdesign(0.08,span, Nsps);
cascade=conv(rcv,tx);

figure(1);
hold on
title('Different beta');
stem(1:N,rcv);
stem(1:N,tx)
stem(1:2*N-1,cascade);
legend('RCV','TX','Cascade'); grid;
hold off

figure(2);
hold on
title('Same beta');
stem(1:N,rcv);
stem(1:2*N-1,conv(rcv,rcv));
legend('RCV','Cascade'); grid;
hold off

% SRRC is a square root nyquist filter; firpm also
% creates a sqrt nyquist filter
M=N-1; Nsps=4; span=M/Nsps; b_nom=0.1;
fc=1/2/Nsps; fp=(1-b_nom)*fc; fs=(1+b_nom)*fc;
fb = [0 fp fc fc fs .5]*2;
a = [1 1 1/sqrt(2) 1/sqrt(2) 0 0];
% wght vector needs to 2.4535 for passband
wght = [2.4535 1 1];
tx_pm = firpm(M,fb,a,wght);
cascade_pm = conv(tx_pm,rcv);
cascade_rcv = conv(rcv,rcv);

figure(3);
subplot(2,1,1);
hold on
stem(1:N,tx_pm);
stem(1:2*N-1,cascade_pm);
title('firpm');
hold off
subplot(2,1,2);
hold on
stem(1:N,rcv);
stem(1:2*N-1,cascade_rcv);
title('traditional RC');
hold off
% legend('RCV','TX','Cascade'); grid;

figure(4)
stem(1:31,rcosdesign(0.25,(31-1)/4,4));

%% Polyphase Time-SHaring Decimator design
clear
clc
format longG
srrc = round(rcosdesign(0.2,(101-1)/4,4).'*2^17);

N=93;
a_sym_mults = round(N/2);
a_poly_mults = round(a_sym_mults/4);
a_time_share_mults = round(a_poly_mults/4); % use 4x faster clk to do operation

out_ds = zeros(N,N); out_ds(1,1)=1;

% let row=sample & col=y_ds
for row=1:N
    for col=1:N
%         fprintf("row: %d | col: %d | val: %d\n",row,col,row*col);
%         out_ds(row,col)=row*col;
        if row==col&&col==1
%             fprintf("row: %d | col: %d | val: %d\n",row,col,1);
            out_ds(row,col)=row*col;
        elseif col==1&&row~=1
%             fprintf("row: %d | col: %d | val: %d\n",row,col,out_ds(row-1,col)+1);
            out_ds(row,col)=out_ds(row-1,col)+1;
        else
%             fprintf("row: %d | col: %d | val: %d\n",row,col,out_ds(row,col-1)-1);
                if out_ds(row,col-1)-1>0
                    out_ds(row,col)=out_ds(row,col-1)-1;
                else
                    out_ds(row,col)=0;
                end
        end
    end
end

for row=1:N
    for col=1:N
        if out_ds(row,col)==0 || out_ds(row,col)>round(N/2)
            N=N;
        elseif out_ds(row,col)==1
            fprintf("y%dh%d\n",col,out_ds(row,col));
        else
            fprintf("y%dh%d ",col,out_ds(row,col));
        end
    end
end

%% Test append
fileID = fopen('append.txt','A');
cBeta = char(hex2dec('03b2'));
fprintf(fileID,'%10s %10s %10s %10s\r\n','MER', 'betaTX', 'betaRCV', 'length');
% A = [MER_out(1:last-1); betaTX_out(1:last-1); betaRCV_out(1:last-1); coeff_out(1:last-1)];
MER_out=[1 2 3 4]; betaTX_out=1:4; betaRCV_out=1:4; coeff_out=1:4;
A = [MER_out; betaTX_out; betaRCV_out; coeff_out];
for i=1:4
    fprintf(fileID,'%10.6f %10.6f %10.6f %8.0f\r\n',A(i,i));
end
fclose(fileID);
