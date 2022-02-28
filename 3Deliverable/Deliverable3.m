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

%%
% review why rcosdesign requires an even order