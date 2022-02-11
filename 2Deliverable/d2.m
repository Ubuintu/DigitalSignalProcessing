clear
close all
clc

format longG
%% For LFSR
% length of ML LFSR
n = 4;

% 1s17 output of SUT
dec_var = 2*rand( 1,(2^n)-1 )-1;
acc = sum(abs((dec_var)));

% number of bits required for accumulator
nbits = ceil(log2(acc));

avg = acc/length(dec_var);

% need to assume worse case, where dec_var is always max magnitude of 1s17;
% sum of that should be the number of runs in LFSR