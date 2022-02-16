clear
close all
clc

format longG
%% For LFSR
% length of ML LFSR
n = 22;
c_mag = char(hex2dec('00b1'));

% 1s17 output of SUT
dec_var = 2*rand( 1,(2^n)-1 )-1;
acc = sum(abs((dec_var)));

% number of bits required for accumulator
nbits = round(log2(acc))+1;

% nbits-1+1 since we concatenate w/1s17

fprintf("Number of bits required: %d\nmagnitude = [(-2^(%d)):(2^(%d)-2^-17)]\n\t= [(-%d):(%d)]\n", nbits+18, nbits, nbits, (2^nbits), (2^nbits-2^-17) );

avg = acc/length(dec_var);

% need to assume worse case, where dec_var is always max magnitude of 1s17;
% sum of that should be the number of runs in LFSR

% verify magnitude of signed numbers
% sum = 0;
% for i = 1:nbits+1
%     if i == 1
%         sum = -(2^nbits);
%         fprintf('sum = %5.5f | val = %d | index: -2^%d\n',sum, -(2^nbits),nbits);
%     elseif i == nbits+1
%         sum = sum + 2^(0);
%         fprintf('sum = %5.5f | val = %d | index: 2^%d\n',sum, (2^0),nbits-nbits);
%     else
%         sum = sum + 2^(i-1);
%         fprintf('sum = %5.5f | val = %d | index: 2^%d\n',sum, 2^(i-1),(i-1));
%     end
% end

%% D2 Hand calculation
% for 4-bit LFSR
clear
clc
format longG

sum = 16384 + 16384 + 49152 + 81920;
% acc_out is also ref_lvl
acc_out = sum/4;
acc_out1s17 = acc_out/2^17;

%map_out
square = acc_out^2;
square1s17 = square/2^34;

%map out power is mult_2
mult_out_2_2s16 = square1s17*1.25;
mult_out_2 = mult_out_2_2s16 * 2^16;

%% Mapper
clear clc; format longG

a = 1/3;
mapper = round([-3*a -a a 3*a]*2^17);

%% isi power calculation
clear
clc
MER = 20; % dB
DATA_WIDTH = 22; % length of LFSR
N = 5; % # of digits

format longG
% isi_pwr = round( sqrt(0.5/(10^(MER/10))) ,N)*2^(DATA_WIDTH-1);
isi_pwr = round( sqrt(0.5/(10^(MER/10)))*2^(DATA_WIDTH-1) );