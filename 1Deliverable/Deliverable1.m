%% Specification for Deliverable 1

% The list of deliverable are:
% 1. One RCV SRRC filter 
% 2. One TX SRRC filter that uses multipliers 
% 3. One TX SRRC filter that does not use multipliers 

% Three length 21 Square Root Raised Cosine (SRRC) filter are to be built: two alter-
% native implementations of a TX lter, which is the filter in the transmitter, and
% one implementation of an RCV lter, which is the filter in the receiver.

% **Questions**
% Requirement on signal format(i.e. 1s17 input)?
% Finding a value? idk what the input is?

clear
close all
clc
format long
filepath = which('Deliverable1.m');

%% Initial values
% **Specifications**
% -The sampling rate for the filters is Nsps = 4 times the symbol rate. The subscript sps in Nsps signifies samples-per-symbol.

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
w = [.5:1:1000]/1000*pi;
% default safety factor
safety = 1-2^-17;

%% RCV filter
% -RCV filter is to have a roll-off factor of beta = 0.25.
% -The impulse response of the RCV filter is to be the infinite SRRC response truncated to a length of 21.
clc

% compute IR
h_rcv = rcosdesign(beta,span,Nsps);
% FR
H_rcv = freqz(h_rcv,1,w);
% find peak response for scaling
H_rcv_peak = max(abs(H_rcv));

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
safety = 1-2^-15; % should default value not work
h_rcv_1s = h_rcv * safety/H_rcv_peak;
% compute FR of scaled RCV filter's IR
H_rcv_1s = freqz(h_rcv_1s,1,w);

if ( max(abs(H_rcv_1s)) > 1 )
    fprintf('Error! scaled frequency response does not fit 1s17 format! H_rcv_1s peak: %1.17f\n',max(abs(H_rcv_1s)) )
    return
end

% convert the theoretical scaled coefficients into a 18 bit signed number
% for verilog implementation
h_rcv_1s17 = round(h_rcv_1s * 2^17);
% compute FR
H_rcv_1s17 = freqz( (h_rcv_1s17/2^17),1,w);

if ( max(abs(H_rcv_1s17)) > 1 )
    fprintf('Error! scaled frequency response does not fit 1s17 format! H_rcv_1s17 peak: %1.17f\n',max(abs(H_rcv_1s17)) )
    return
end

% Plot and compare theoretical response with implemented response
RCV_CMP = figure('Name','Magnitude Response of theoretical and implemented SRRC RCV filter');
plot( w/2/pi,20*log10(abs(H_rcv_1s)),'--', w/2/pi,20*log10(abs(H_rcv_1s17)),':' );
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

%% *TX filter:
% -The TX filter is limited to a length of 21.
% -The stop band of the TX filter starts at 0.2 cycles/sample and runs to 0.5 cycles/sample.
% -The magnitude response at all frequencies in the stop band of the TX filter must be 40 dB below the DC response.
% -The coefficients in each filter must be scaled so that the maximum possible output of the filter fits into a 1s17 format.
% Both implementations of the TX filter can have the same coeffs
% -The first implementation of the TX filter may use up to 21 multipliers.
% -The second implementation of the TX filter MUST use 0 multipliers.
clc

% 461 notes p.117 (windowing), 167 (ideal SRRC)

% Parameters that can be adjusted
% % Number of symbols per sample OR Nsps !!WARNING not recommended to change
Nsps = 4;
% % length of the pulse
span = M/Nsps;
% % beta or excess bandwidth
beta = 0.21;
% Stopband Attenuation
A = 40;
% beta for Kaiser window
b = 0.5842*((A-21)^0.4)+0.07886*(A-21);
% corner stopband frequency (cycles/sample)
fs = 0.25;
% Kaiser window
wn = kaiser(N,b);

h_TX = rcosdesign(beta,span,Nsps);


h_srrc = h_TX.*wn.';
% h_srrc = h_TX;  % Demo that find() verifies the stopband attenuation
H_hat_srrc = freqz(h_srrc,1,w);


TX_THEO = figure('Name','Magnitude Response of theoretical SRRC TX filter');
% Magnitude Response
plot( w/2/pi,20*log10(abs(H_hat_srrc)) );
% 
ylabel('H_{hat}(\Omega) for RC and SRRC');
xlabel('f (cycles/sample)');
% title('Frequency response for finite-length SRRC and RC filter');
title('Magnitude response for finite-length SRRC and RC filter');
grid;
datacursormode(TX_THEO,'on');
print -dpng ./pics/mag_response_of_theoretical_SRRC_TX_filter.png
% comment/uncomment below
close 'Magnitude Response of theoretical SRRC TX filter'

DC = 20*log10(abs(H_hat_srrc(1)));

% Verify that TX filter meets required stopband attenuation
col = find(w/2/pi > 0.2);
for i = 1:length(col)
    if ( abs(DC-20*log10(abs(H_hat_srrc(col(i))))) < 40 )
        fprintf('!!!ERROR IN TX FILTER!!!!\nindex: %d | Magnitude: %10.6f dB | %.6f cycles/sample\n', col(i), 20*log10(abs(H_hat_srrc(col(i)))), w(col(i))/2/pi );
        return
    end
end