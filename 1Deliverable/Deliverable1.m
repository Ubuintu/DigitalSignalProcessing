%% Specification for Deliverable 1 p.102-103; p.126-127

% exam will test the following items:
%  The magnitude-frequency response of the TX filter.
%  The magnitude-frequency response of the RCV filter.
%  The MER of the TX and RCV filters connected in cascade.

% The list of deliverable are:
% 1. One RCV SRRC filter 
% 2. One TX SRRC filter that uses multipliers 
% 3. One TX SRRC filter that does not use multipliers 

% Three length 21 Square Root Raised Cosine (SRRC) filter are to be built: two alter-
% native implementations of a TX filter, which is the filter in the transmitter, and
% one implementation of an RCV filter, which is the filter in the receiver.

% **Questions**
% Requirement on signal format(i.e. 1s17 input)?
% Finding a value? idk what the input is?

clear
close all
clc
filepath = which('Deliverable1.m');
format longG

if isfolder('pics') == 0
    mkdir('pics')
end

%% Initial values
% **Specifications p.102-103**
% -The sampling rate for the filters is Nsps = 4 times the symbol rate. The subscript sps in Nsps signifies samples-per-symbol.
% -The coefficients in each filter must be scaled so that the maximum possible output of the filter fits into a 1s17 format.

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
w = [0:0.001:1000]/1000*pi;
% default safety factor
safety = 1-2^-17;

%% RCV filter
% -RCV filter is to have a roll-off factor of beta = 0.25.
% -The impulse response of the RCV filter is to be the infinite SRRC response truncated to a length of 21.
cBeta = char(hex2dec('03b2'));

if beta ~= 0.25
    fprintf('\t\tWARNING!\n\nwrong %s being used for RCV filter is: %.5f\n',cBeta,beta);
    return
end

% compute IR
h_rcv = rcosdesign(beta,span,Nsps);
% FR
H_rcv = freqz(h_rcv,1,w);

% find worst case for scaling
worse_case_RCV = zeros(length(h_rcv),1);

for i = 1:length(h_rcv)
    if (h_rcv(i) > 0)
%         worse_case_RCV(i) = 131071;
        worse_case_RCV(i) = 1;
%         worse_case_RCV(i) = -1; % WC neg value
    else
%         worse_case_RCV(i) = 131072;
        worse_case_RCV(i) = -1;
%         worse_case_RCV(i) = 1; % WC neg value
    end
end

h_RCV_wc = 0;

% Find the peak positive output
for i = 1:length(h_rcv)
    h_RCV_wc = h_RCV_wc + (worse_case_RCV(i)*h_rcv(i));
end

% Verify Magnitude Response %comment/uncomment this code when needed
MR = figure('Name','Magnitude Response of SRRC RCV filter');
plot(w/(2*pi),20*log10(abs(H_rcv)));
ylabel('20*log(|H_{rcv}(e^{j\omega})|)'); 
xlabel('\omega normalized to 2\pi');
title('SRRC RCV filter''s Magnitude Response');
grid;
datacursormode(MR,'on');
print -dpng ./pics/mag_response_of_SRRC_RCV_filter.png

% comment/uncomment below
close 'Magnitude Response of SRRC RCV filter'

% scale coeffs of RCV to be consistent w/TX (1s17)
% safety = 1-2^-15; % should default value not work
h_rcv_0s = h_rcv * safety/h_RCV_wc;
% compute FR of scaled RCV filter's IR
H_rcv_0s = freqz(h_rcv_0s,1,w);

if ( sum(abs(h_rcv_0s)) >= 1 )
    fprintf('Error! Worst case input for scaled RCV filter is greater than 1\n\th_rcv_1s output given worst case input: %1.17f\n',sum(abs(h_rcv_0s)) )
    return
end

% convert the theoretical scaled coefficients into a 18 bit signed number
% for verilog implementation
h_rcv_0s18 = round(h_rcv_0s * 2^18);
% compute FR
H_rcv_0s18 = freqz( (h_rcv_0s18/2^18),1,w);

if ( sum(abs(h_rcv_0s18/2^18)) > 1 )
    fprintf('Error! Worst case input for scaled 1s17 RCV filter is greater than 1\n\th_rcv_1s17 output given worst case input: %1.17f\n',sum(abs(h_rcv_0s18/2^17)) )
    return
end

% Plot and compare theoretical response with implemented response
RCV_CMP = figure('Name','Magnitude Response of theoretical and implemented SRRC RCV filter');
plot( w/2/pi,20*log10(abs(H_rcv_0s)),'--', w/2/pi,20*log10(abs(H_rcv_0s18)),':' );
ylabel('20*log(|H_{rcv}(e^{j\omega})|)'); 
xlabel('frequency (cycles/sample)');
title('SRRC RCV filter''s Magnitude Response');
legend('Theoretical scaled Magnitude Response','Implemented Scaled 1s17 Magnitude Response');
grid;
axis([0.0,0.5,-50,10]);
datacursormode(RCV_CMP,'on');
print -dpng ./pics/mag_response_of_cmp_SRRC_RCV_filter.png
% comment/uncomment below
close 'Magnitude Response of theoretical and implemented SRRC RCV filter'

% Coefficiencts for SRRC 1s17 Rcv filter
fprintf('0s18 Coefficients for SRRC RCV 1s17 filter:\n');
for i = 1:(length(h_rcv_0s18)/2)+1
    if (h_rcv_0s18(i) > 0)
        fprintf('\tb[%s] = 18''sd%s;\n',num2str(i-1),num2str( abs(h_rcv_0s18(i)) ) );
    else
        fprintf('\tb[%s] = -18''sd%s;\n',num2str(i-1),num2str( abs(h_rcv_0s18(i)) ) );
    end
end
fprintf('End of 0s18 Coefficients for SRRC RCV 1s17 filter\n\n');

%% *TX filter:
% -The TX filter is limited to a length of 21.
% -The stop band of the TX filter starts at 0.2 cycles/sample and runs to 0.5 cycles/sample.
% -The magnitude response at all frequencies in the stop band of the TX filter must be 40 dB below the DC response.
% Everything after 0.2 cycles/sample should be 40 dB
% -The coefficients in each filter must be scaled so that the maximum possible output of the filter fits into a 1s17 format.
% Both implementations of the TX filter can have the same coeffs
% -The first implementation of the TX filter may use up to 21 multipliers.
% -The second implementation of the TX filter MUST use 0 multipliers.

% a value in the mapper LUT can be chosen by us

% 461 notes p.117 (windowing), 167 (ideal SRRC)

% Parameters that can be adjusted
% % Number of symbols per sample OR Nsps !!WARNING not recommended to change
% Nsps = 4;
% % length of the pulse
% span = M/Nsps;
% % beta or excess bandwidth
% beta = 0.21; %beta prior to maximizing MER
% BEST MER: b: 0.42 | A: 27.1
% PRACTICAL MER: b: 0.42 | A: 27.1 | RBW 62 kHz
beta = 0.42;
% Stopband Attenuation
% A = 40;   %A prior to maximizing MER
A = 27.1;   %Had to adjust for SA
% beta for Kaiser window | 21 <= A <= 50
b = 0.5842*((A-21)^0.4)+0.07886*(A-21);
% stopband frequency (cycles/sample)
fs = 0.2;
% Kaiser window
wn = kaiser(N,b);

h_TX = rcosdesign(beta,span,Nsps);
% Freq resp of non-windowed design
H_TX = freqz(h_TX,1,w);


h_TX_wn = h_TX.*wn.';
% h_srrc = h_TX;  % Demo that find() verifies the stopband attenuation
H_TX_wn = freqz(h_TX_wn,1,w);

% DC value of magnitude response
DC = 20*log10(abs(H_TX_wn(1)));

% Verify that TX filter meets required stopband attenuation:
% "The stop band of the TX filter starts at 0.2 cycles/sample and runs to
% 0.5 cycles/sample."
col = find(w/2/pi >= fs);

% check to see if Mag Resp is meeting spec
diff = DC - 20*log10(abs(H_TX_wn(col(1))));

for i = 1:length(col)
    if ( DC-20*log10(abs(H_TX_wn(col(i)))) < 40 )
        fprintf('!!!ERROR IN TX FILTER!!!!\nindex: %d | Magnitude: %10.6f dB | %.6f cycles/sample\n', col(i), 20*log10(abs(H_TX_wn(col(i)))), w(col(i))/2/pi );
        fprintf('Difference from DC is: %.6f dB\n',DC-20*log10(abs(H_TX_wn(col(i)))) );
        fprintf('DC value: %.6f dB\n',DC);
        return
% For maximizing MER
%     break
    end
end

stop = find(w/2/pi == fs);
stoptxt = ['\leftarrow f_{s} = ',num2str(fs,'%1.2f'),' (cycles/sample) | Attenuation: ',num2str( 20*log10(abs(H_TX_wn(stop))),'%2.4f' )];
dctxt = ['DC = ',num2str(w(1),'%.2f'),' (cycles/sample) '];
TX_THEO = figure('Name','Magnitude Response of theoretical SRRC TX filter');
% Magnitude Response
plot( w/2/pi,20*log10(abs(H_TX_wn)), w/2/pi,20*log10(abs(H_TX)) );
hold on
plot([0.2 0.2],[-200 DC-40],'--k');
plot([0.2 0.5],[DC-40 DC-40],'--k');
plot( w/2/pi, 20*log10(abs(H_TX_wn)),'x','MarkerIndices',stop,'MarkerFaceColor','Red','MarkerSize',10 );
st = text( fs, 20*log10(abs(H_TX_wn(stop))), stoptxt);
plot( w/2/pi, 20*log10(abs(H_TX_wn)),'x','MarkerIndices',1,'MarkerFaceColor','Red','MarkerSize',10 );
dct = text( 0, 0, dctxt);
text( 0, -5, ['Attenuation: ',num2str( 20*log10(abs(H_TX_wn(1))),'%1.4f' )]);
st.Color = [102, 0, 102]/255;
st.FontSize = 10;
dct.Color = [102, 0, 102]/255;
dct.FontSize = 10;
hold off
axis([0 0.5 -100 10]);
ylabel('H_{hat}(\Omega) for RC and SRRC');
xlabel('f (cycles/sample)');
title('Magnitude response for finite-length SRRC TX filter');
legend('SRRC TX windowed','SRRC TX no window','Required stopband attenuation');
grid;
datacursormode(TX_THEO,'on');
TX_THEO.Position = [10 10 1000 900];
print -dpng ./pics/mag_response_of_theoretical_SRRC_TX_filter.png
% comment/uncomment below
close 'Magnitude Response of theoretical SRRC TX filter'

% "scale coefficients so that the maximum possible output of the filter fits
% into a 1s17 format"? Constraints of "a" value from 4-ASK output? If I
% choose a value of a now, would it impact my design choices in the future?
% Since theres only 4 outputs from LUT, do i just find the max possible
% input based on those values OR for the worst possible input?


% find worst case for scaling
worse_case_TX = zeros(length(h_TX_wn),1);

for i = 1:length(h_TX_wn)
    if (h_TX_wn(i) > 0)
%         worse_case_RCV(i) = 131071;
        worse_case_TX(i) = 1;
%         worse_case_RCV(i) = -1; % WC neg value
    else
%         worse_case_RCV(i) = 131072;
        worse_case_TX(i) = -1;
%         worse_case_RCV(i) = 1; % WC neg value
    end
end

% scale factor given wc input
h_TX_wc = 0;

% Find the max possible output
for i = 1:length(h_TX_wn)
    h_TX_wc = h_TX_wc + (worse_case_TX(i)*h_TX_wn(i));
end

% scale coeffs of TX so max output is 1s17
h_TX_0s = h_TX_wn * safety/h_TX_wc;

% check if max possible output for filter is larger than 1
if (h_TX_0s * worse_case_TX) > 1
    fprintf('Error! Max possible output for scaled theoretical SRRC TX, h_TX_1s is: %1.17f\n',(h_TX_0s * worse_case_TX));
    return
end

% compute FR of scaled TX filter's FR
H_TX_1s = freqz(h_TX_0s,1,w);

% convert the theoretical scaled coefficients into a 18 bit signed number
% for verilog implementation
% NOTE: let TX's coeffs be 0s18 since after scaling for max possible
% output, coeffs are much smaller than 2^-1
h_TX_0s18 = round(h_TX_0s * 2^18);
% compute FR
H_TX_0s18 = freqz( (h_TX_0s18/2^18),1,w);

% check if max possible output via dot product for filter is larger than 1
if (h_TX_0s18/2^18 * worse_case_TX) >= 1
    fprintf('Error! Max possible output for scaled SRRC 1s17 TX, h_TX_1s17 is: %1.17f\n',(h_TX_0s18/2^18 * worse_case_TX));
    return;
end

% Plot and compare theoretical response with implemented response
stoptxt = ['\leftarrow f_{s} = ',num2str(fs,'%1.2f'),' (cycles/sample) | Attenuation: ',num2str( 20*log10(abs(H_TX_0s18(stop))),'%2.4f' )];
dctxt = ['DC = ',num2str(w(1),'%.2f'),' (cycles/sample) '];
TX_CMP = figure('Name','Magnitude Response of theoretical and implemented SRRC TX filter');
hold on
plot( w/2/pi,20*log10(abs(H_TX_1s)),'--', w/2/pi,20*log10(abs(H_TX_0s18)),':' );
plot([0.2 0.2],[-100 20*log10(abs(H_TX_0s18(1)))-40],'--k');
plot([0.2 0.5],[20*log10(abs(H_TX_0s18(1)))-40 20*log10(abs(H_TX_0s18(1)))-40],'--k');
plot( w/2/pi, 20*log10(abs(H_TX_0s18)),'x','MarkerIndices',stop,'MarkerFaceColor','Red','MarkerSize',15 );
plot( w/2/pi, 20*log10(abs(H_TX_0s18)),'x','MarkerIndices',1,'MarkerFaceColor','Red','MarkerSize',10 );
dct = text( 0, -5, dctxt);
text( 0, -10, ['Attenuation: ',num2str( 20*log10(abs(H_TX_0s18(1))),'%1.4f' )]);
hold off
ylabel('20*log(|H_{TX}(e^{j\omega})|)'); 
xlabel('frequency (cycles/sample)');
title('SRRC TX filter''s Magnitude Response');
legend('Theoretical scaled Magnitude Response','Implemented Scaled 1s17 Magnitude Response','Required stopband attenuation');
st = text( fs, 20*log10(abs(H_TX_0s18(stop))), stoptxt);
st.Color = [102, 0, 102]/255;
grid;
axis([0.0,0.5,-100,10]);
datacursormode(TX_CMP,'on');
TX_CMP.Position = [10 10 1000 900];
print -dpng ./pics/mag_response_of_cmp_SRRC_TX_filter.png
% comment/uncomment below
close 'Magnitude Response of theoretical and implemented SRRC TX filter'

%% MER (Modulation Error Ratio) Theoretical
% compute the MER BEFORE plotting and implementing the transmitter filter

% convolve TX and RCV filter
cascade = conv(h_TX_0s18/2^17, h_rcv_0s18/2^17);

% FR
% H_cascade = freqz(cascade, 1, w);
% figure()
% plot(w/2/pi, 20*log10(abs(H_cascade)));

% Computer MER; center coeff/sum of every 4th coeff except center; MER in
% dB
num = cascade(N);
den = zeros( floor(length(cascade)/4),1 );
cnt = 0;
idx = 1;

for i = 1:length(cascade)
    if cnt == 0 && i ~= N
        den(idx) = cascade(i);
        cnt = cnt + 1;
        idx = idx + 1;
    elseif cnt >= 3
        cnt = 0;
    else
        cnt = cnt + 1;
    end
end
    
MER_theo = 10*log10( num^2/sum(den.^2) );
% MER_theo = 20*log10( num/sum(den) );

fprintf('\n\nTheoretical MER is: %2.8f\n%s: %0.4f\nA: %2.2f\n',MER_theo,cBeta, beta, A);

% Cascaded MER (Practical w/multipliers)sim:/cascade_tb/y

% TX clocks in input as soon as it comes in, then outputs it on next CC;
% same behaviour in RCV
prac_coeffs = [0 6 18 16 -25 -105 -150 -37 312 808 1140 903 -96 -1560 -2648 -2285 230 4717 9976 14216 15838 ...
    14216 9976 4717 230 -2285 -2648 -1560 -96 903 1140 808 312 -37 -150 -105 -25 16 18 6 0];

if ( length(prac_coeffs) ~= 2*N-1 )
    fprintf('ERROR! Length of cascade output is %d\n',length(prac_coeffs) );
    return
end

for i = 1:ceil(length(prac_coeffs)/2)
    if prac_coeffs(i) ~= prac_coeffs( length(prac_coeffs)+1-i )
        fprintf('ERROR in practical coeffs!\n');
        fprintf('idx: %d | val: %d\nidx: %d | val: %d\n', i, prac_coeffs(i), (length(prac_coeffs)+1-i), prac_coeffs(length(prac_coeffs)+1-i) );
        return
    end
end

num_p = max(prac_coeffs);
den_p = zeros(floor(length(prac_coeffs)/4),1);
cnt = 0;
idx = 1;

for i = 1:length(prac_coeffs)
    if cnt == 0 && i ~= N
        den_p(idx) = prac_coeffs(i);
        cnt = cnt + 1;
        idx = idx + 1;
    elseif cnt >= 3
        cnt = 0;
    else
        cnt = cnt + 1;
    end
end
    
MER_prac = 10*log10( num_p^2/sum(den_p.^2) );

fprintf('Practical MER for TX w/Multipliers is: %2.8f\n',MER_prac);

% Cascaded MER (Practical w/MF)
prac_coeffs_MF = [0 14 38 36 -48 -205 -296 -71 628 1621 2286 1815 -185 -3116 -5288 -4563 466 9442 19960 28436 31684 ...
    28436 19960 9442 466 -4563 -5288 -3116 -185 1815 2286 1621 628 -71 -296 -205 -48 36 38 14 0];

if ( length(prac_coeffs_MF) ~= 2*N-1 )
    fprintf('ERROR! Length of cascade output is %d\n',length(prac_coeffs_MF) );
    return
end

for i = 1:ceil(length(prac_coeffs_MF)/2)
    if prac_coeffs_MF(i) ~= prac_coeffs_MF( length(prac_coeffs_MF)+1-i )
        fprintf('ERROR in practical coeffs!\n');
        fprintf('idx: %d | val: %d\nidx: %d | val: %d\n', i, prac_coeffs_MF(i), (length(prac_coeffs_MF)+1-i), prac_coeffs_MF(length(prac_coeffs_MF)+1-i) );
        return
    end
end

num_p_MF = max(prac_coeffs_MF);
den_p_MF = zeros(floor(length(prac_coeffs_MF)/4),1);
cnt = 0;
idx = 1;

for i = 1:length(prac_coeffs_MF)
    if cnt == 0 && i ~= N
        den_p_MF(idx) = prac_coeffs_MF(i);
        cnt = cnt + 1;
        idx = idx + 1;
    elseif cnt >= 3
        cnt = 0;
    else
        cnt = cnt + 1;
    end
end
    
MER_prac_MF = 10*log10( num_p_MF^2/sum(den_p_MF.^2) );

fprintf('Practical MER for TX w/o Multipliers is: %2.8f\n\n',MER_prac_MF);

num_of_sumLvls=1;

%% TX filter coefficient implementation
% Use filter coefficients based on their MER

% Coefficiencts for SRRC 1s17 Rcv filter
fprintf('0s18 Coefficients for SRRC TX 1s17 filter:\n');
for i = 1:(length(h_TX_0s18)/2)+1
    if (h_TX_0s18(i) > 0)
        fprintf('\tb[%s] = 18''sd%s;\n',num2str(i-1),num2str( abs(h_TX_0s18(i)) ) );
    else
        fprintf('\tb[%s] = -18''sd%s;\n',num2str(i-1),num2str( abs(h_TX_0s18(i)) ) );
    end
end
fprintf('End of 0s18 Coefficients for SRRC TX 1s17 filter\n\n');

% For maximizing MER
% return

%% TX Multipler Free

% values for LUT 4-ASK mapper; ensure output of 4-ASK mapper is a 1s17
% input to transmit filter
a = 1/4;
% a = 1;    % to see possible inputs from LUT
ASK_out = [-3*a -a a 3*a];

in1 = ASK_out;
in2 = ASK_out;

% add row and column vectors to see possible combinations
possible_inputs = in1 + in2';
possible_inputs = uniquetol(possible_inputs);
% 1s17 input is truncated to 2s16 sum_level_1 in filter
possible_inputs_verilog = round(possible_inputs*2^16);

% MF_coeff(row,col); same indexing in verilog
% MF_LUT = possible_inputs * h_TX_0s18/2^18;
% MF_LUT = round(possible_inputs * h_TX_0s18);

% [rows, cols] = size(MF_LUT);
% fprintf('0s18 Coefficients for SRRC Multiplier-Free Transmitter filter:\n');
% for i = 1:ceil(cols/2)
%     for j = 1:rows+1
%         if j == rows+1 && h_TX_0s18(i) > 0
%             fprintf('\tb[%d][%d] = 18''sd%s;\n',(j-1),(i-1),num2str( abs(h_TX_0s18(i)) ) );
%         elseif j == rows+1 && h_TX_0s18(i) < 0
%             fprintf('\tb[%d][%d] = -18''sd%s;\n',(j-1),(i-1),num2str( abs(h_TX_0s18(i)) ) );
%         elseif MF_LUT(j,i) > 0
%             fprintf('\tb[%d][%d] = 18''sd%s;\n',(j-1),(i-1),num2str( abs(MF_LUT(j,i)) ) );
%         elseif MF_LUT(j,i) < 0
%             fprintf('\tb[%d][%d] = -18''sd%s;\n',(j-1),(i-1),num2str( abs(MF_LUT(j,i)) ) );
%         else
%             fprintf('\tb[%d][%d] = 18''sd%s;\n',(j-1),(i-1),num2str( abs(MF_LUT(j,i)) ) );
%         end
%     end
% end
% fprintf('End of 0s18 Coefficients for SRRC Multiplier-Free Transmitter filter:\n\n');



%% Textfiles

IR = zeros(1,2*N);
% *** For regular TX
IR(5) = 131071;
% *** For MF
% IR(5) = 13100;

fileID = fopen('impulse_response.txt','w');
fprintf(fileID,'%d\r\n',IR);
fclose(fileID);

% write 1s17 FS sinusoid to text for modelsim
f = 0:0.001:2;
FS1s17 = 2.^17*(0.999)*sin(2*pi*f);
% FS1s17 = sin(2*pi*f);
format long
FS1s17 = round(FS1s17);
fileID = fopen('input_sine.txt','w');
fprintf(fileID,'%d\r\n',FS1s17);
fclose(fileID);

toWrite = zeros( length(worse_case_RCV),1 );
% z = zeros( 10,1);
% 
% for i = 1:length(worse_case_RCV)
%     if worse_case_RCV(i)== 1
%         toWrite(i) = 131071;
%     else
%         toWrite(i) = 131072;
%     end
% end
% 
% fileID = fopen('worse_case_RCV.txt','w');
% fprintf(fileID,'%d\r\n',toWrite);
% fprintf(fileID,'%d\r\n',z);
% fclose(fileID);
% 
% % worse case input sequence for TX
% 
% for i = 1:length(worse_case_TX)
%     if worse_case_TX(i)== 1
%         toWrite(i) = 131071;
%     else
%         toWrite(i) = 131072;
%     end
% end
% 
% fileID = fopen('worse_case_TX.txt','w');
% fprintf(fileID,'%d\r\n',toWrite);
% fprintf(fileID,'%d\r\n',z);
% fclose(fileID);
% 
%%
% 4-ASK input is 1s17
toWrite = zeros(3*N,1);
for i = 1:length(toWrite)
    %randsample(n,k) will returns k random values from n
%     toWrite(i) = round(randsample(ASK_out,1)*2^17);
    toWrite(i) = round(ASK_out(rem(i,4)+1)*2^17);
end

fileID = fopen('../3Deliverable/D3_ASK_in.txt','w');
fprintf(fileID,'%d\r\n',toWrite);
fclose(fileID);
return
%%
% 
% 
% count = 0;
% % delay has to be 19 since cascade delays output by 2 cc 
% delay = 19;
% 
% for i = 1:delay*length(toWrite)
%     if count == 0 
%         toWrite(i) = 0;
%         count = count + 1;
%     else
%         if count >= delay
%             count = 0;
%             toWrite(i) = round(randsample(ASK_out,1)*2^17);
%         else
%             count = count + 1;
%             toWrite(i) = 0;
%         end
%     end
% end
% 
% fileID = fopen('ASK_in_x0&20.txt','w');
% fprintf(fileID,'%d\r\n',toWrite);
% fclose(fileID);
% 
% % verify x1 & 19
% count = 0;
% delay = 17;
% 
% for i = 1:delay*length(toWrite)
%     if count == 0 
%         toWrite(i) = 0;
%         count = count + 1;
%     else
%         if count >= delay
%             count = 0;
%             toWrite(i) = round(randsample(ASK_out,1)*2^17);
%         else
%             count = count + 1;
%             toWrite(i) = 0;
%         end
%     end
% end
% 
% fileID = fopen('ASK_in_x1&19.txt','w');
% fprintf(fileID,'%d\r\n',toWrite);
% fclose(fileID);
% 
% % verify x9 & 11
% count = 0;
% delay = 21;
% 
% for i = 1:delay*length(toWrite)
%     if count == 0 | count == 2
%         toWrite(i) = round(randsample(ASK_out,1)*2^17);
%         count = count + 1;
%     else
%         if count >= delay
%             count = 0;
%             toWrite(i) = 0;
%         else
%             count = count + 1;
%             toWrite(i) = 0;
%         end
%     end
% end
% 
% fileID = fopen('ASK_in_x11&9.txt','w');
% fprintf(fileID,'%d\r\n',toWrite);
% fclose(fileID);

% verify x10
% count = 0;
% delay = 21;
% 
% for i = 1:delay*length(toWrite)
%     if count == 0 
%         toWrite(i) = round(randsample(ASK_out,1)*2^17);
%         count = count + 1;
%     else
%         if count >= delay
%             count = 0;
%             toWrite(i) = 0;
%         else
%             count = count + 1;
%             toWrite(i) = 0;
%         end
%     end
% end
% 
% fileID = fopen('ASK_in_x10.txt','w');
% fprintf(fileID,'%d\r\n',toWrite);
% fclose(fileID);


