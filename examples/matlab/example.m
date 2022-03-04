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
[MER_out, betaTX_out, betaRCV_out, coeff_out] = MER_opt('Nsps',4,'numCoeffs',vec,'betaTX',[0 0.0001 1],'betaRCV',[0.12 0.01 0.12],'MER',50);
% [MER_out, betaTX_out, betaRCV_out, coeff_out] = MER_opt('Nsps',4,'numCoeffs',[25 77],'betaTX',[.01 0.01 .16],'betaRCV',[0.12 0.01 0.34],'MER',40);

last = find(~MER_out,1);
fileID = fopen('GSM_parameters.txt','w');
cBeta = char(hex2dec('03b2'));
fprintf(fileID,'%10s %10s %10s %10s\r\n','MER', 'betaTX', 'betaRCV', 'length');
A = [MER_out(1:last-1); betaTX_out(1:last-1); betaRCV_out(1:last-1); coeff_out(1:last-1)];
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

%% Testing stuff
close all
clc
clear

x=(-10:0.1:10);
xs=x(x>-4 & x<4);
slope = @(var) var+1;
figure;
hold on;
% area(xs,normpdf(xs,0,3));
% plot(x,normpdf(x,0,3));
plot(x,slope(x));
area(xs,slope(xs));
ar = integral(slope,-4,4);
hold off

samples = 100;
% length of filter
N = 21;
% Order of filter
M = N-1;
% Number of symbols per sample OR Nsps
Nsps = 4;
% length of the pulse
span = M/Nsps;
% beta or excess bandwidth
beta = 0.25;
% Frequency vector (radians/sample)
w = [0:1:samples]/samples*pi;
% stopband frequency (cycles/sample)
fs = 0.2;

% compute IR
h_rcv = rcosdesign(beta,span,Nsps);
% FR
H_rcv = freqz(h_rcv,1,w);
abs_H = real(20*log10(abs(H_rcv)));
fun = @(x) abs_H(x)-20*log10(min(abs(H_rcv))) ;
funw = @(x) w(x);
samp = find(w/2/pi >= fs);

figure(2);
hold on
plot( w/2/pi,20*log10(abs(H_rcv))-20*log10(min(abs(H_rcv))));
% plot( w/2/pi,20*log10(abs(H_rcv)));
% figure(2)
area( funw(samp)/2/pi, abs_H(samp(1):samp(end))-20*log10(min(abs(H_rcv))) );
hold off
% % stopband frequency (cycles/sample)
% fs = 0.2;
Xs = 0:pi/5:pi;
Ys = sin(Xs');
wuut = Xs';
% Q = cumtrapz(Xs,Ys)
% zeropad = zeros( 
% plot(funw(samp)/2/pi,fun)
% QQ = cumtrapz([0.2:0.5]*2*pi,abs_H-20*log10(min(abs(H_rcv))));
% QQ = cumtrapz([0.2:0.5]*2*pi,abs_H);

% convert to linear units; sum them; convert back to dB
sum( 10.^(0.1.*(20.*log10(abs(H_rcv(41:101)))) ))

%% Measuring OOB requirements
clear 
close all
clc

beta = 0.146600;
N = 65;
Nsps = 4;
span = (N-1)/4;
% digital angular frequency, w (rads/sample)
w = [0:0.001:1000]/1000*pi;

tx_prac = rcosdesign(beta,span,Nsps);
As = 63;
b = 0.1102*(As-8.7);
wn = kaiser(length(tx_prac), 12);
h = tx_prac.*wn.';
H = freqz(h,1,w);


TX_MR = superplot(w/2/pi,20*log10(abs(H)),'plotName',"Magnitude Response of PPS",'figureName',"PracticalPSResp",'yName',"Magnitude (dB)",...
    'xName',"Frequency (cycles/sample)",'yLegend',"Practical Pulse Shaping Response");

mag_H = 20*log10(abs(H));
baseband_ind = find( w/2/pi <= 0.14);
OB1_ind = find(w/2/pi > 0.14 & w/2/pi <= 0.1752);
OB2_ind = find(w/2/pi > 0.1752);

conv2mW = @(x) 10.^(x/20);
conv2dBm =  @(x) 20.*log10(x);

% For power, do i need to account for limits of SA
spec_mW = sum(conv2mW(mag_H));
bb_mW = sum(conv2mW(mag_H(baseband_ind(1):baseband_ind(end))));
OB1_mW = sum(conv2mW(mag_H(OB1_ind(1):OB1_ind(end))));
OB2_mW = sum(conv2mW(mag_H(OB2_ind(1):OB2_ind(end))));

spec_dBm = conv2dBm(spec_mW);
bb_dBm = conv2dBm(bb_mW);
OB1_dBm = conv2dBm(OB1_mW);
OB2_dBm = conv2dBm(OB2_mW);

OB1_58 = bb_dBm-OB1_dBm;
OB2_60 = bb_dBm-OB2_dBm;

if OB1_58 < 58
    fprintf("Power transmiteed in OB1 is %2.6f dB and off by %2.6f dB from 58 dB requirement\n", OB1_58, 58-OB1_58);
end

if OB2_60 < 60
    fprintf("Power transmiteed in OB2 is %2.6f dB and off by %2.6f dB from 60 dB requirement\n", OB2_60, 60-OB2_60);
end




%% Test cascade
clear 
close all
clc

coeff = 65;
Nsps = 4;
beta = 0.146600;

span = (coeff-1)/Nsps;
rcv = rcosdesign(beta, span, Nsps);

% SR Nyquist filter
bb = 0.2; spans = 25;
M = spans*Nsps;
fc = 1/(2*Nsps);fp=(1-beta)*fc; fs=(1+beta)*fc;
fb = [0 fp fc fc fs .5]*2;
a = [1 1 1/sqrt(2) 1/sqrt(2) 0 0];
wght = [2.4535 1 1];
h=firpm(M,fb,a,wght);

% Too much theory to figure out MER for LPF