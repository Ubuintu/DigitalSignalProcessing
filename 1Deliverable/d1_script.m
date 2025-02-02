%
% Revision History
% Aug 17, 2017: Changed ``(length(f2)-1))'' to ''(length(f2)+1))
% in assignment statement Hrc_f(f2)=...
% (Due to Brian Daku)
%
clear 
close all
clc
% parmeters for the filters
N_sps = 4; % number of samples per symbol; changing this will negatively impact the MER
beta = 0.25;  % original value
% beta = 0.5;  % This value makes theoretical response have a Fs = 0.2
% VIA trial and error managed to get a reasonable stopband corner frequency
% beta = 0.21; % roll off factor, script requires
             % beta be less than 1; nominal value is 0.25; can influence
             % stopband A and MER; could increase beta for TX filter;
             % increasing beta gives us better stopband attenuation BUT
             % increases transition bandwidth
N_rc = 41; % length of the impulse response
           % of the raised cosine filter; cascade of the TX and PS filter's
           % minus 1
N_srrc = 21; % length of the impulse response of the
             % square root raised cosine filter; tx and PS must be 21; cant
             % change this value
             
F_s = 1; % sampling rate in samples/second; scales x-axis in frequency graph

f_6db = 1/2/N_sps; % 6 dB down point in cycles/sample
F_6db = F_s * f_6db; % 6 dB down point in Hz


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% time and frequency vectors
%
df = 1/2000; % frequency increment in cycles/sample; 2000 points
f = [0:df:0.5-df/2]; % cycles/sample; 0 to almost 1/2
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% magnitude response for RC and SCCR filters
Hrc_f = zeros(1,length(f)); % reserve space for
% magnitude response of rc filter
Hsrrc_f = zeros(1,length(f)); % reserve space for
% magnitude response of srrc filter
f1 = find(f < f_6db*(1-beta)); % indices where frequency is less than this cutoff point
% H_f = 1
f2 = find( (f_6db*(1-beta)<= f) & ( f <=...
f_6db*(1+beta))); % indices where in the transition band
% H_f is in transition
f3 = find(f > f_6db*(1+beta)); % indices where
% H_f = 0
% Theoretical Frequency response vector; uses expression from chapter 9
% slide
Hrc_f(f1) = ones(1,length(f1));
Hrc_f(f2) = 0.5+0.5*cos(pi*(f2-f2(1))/(length(f2)-1));
Hrc_f(f3) = 0;
Hsrrc_f = sqrt(Hrc_f);
figure(1);
% Theoretical frequency response of rc and srrc
plot(f,(Hrc_f),'r', ...
f,(Hsrrc_f),'--b','LineWidth',2);
title('Theoretical Frequency response for SRRC and RC filter');
xlabel('frequency in cycles/sample')
ylabel('|H_{rc}(e^{2\pif})| and |H_{srrc}(e^{2\pif})|')
legend('raise cosine','SRRC');
grid
% 3 dB point for SRRC and 6 dB point for RC are always @ 0.125 cycles/sample
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% find and plot the impulse response
% generates 41 sample RC filter
h_rc=firrcos(N_rc-1,F_s/8,beta,F_s,'rolloff');
% impulse response of rc filter
% generates a 21 sample filter
h_srrc=firrcos(N_srrc-1,F_s/8,beta,F_s,'rolloff','sqrt');


% % Comment out lines 13,78-90 for original script
% % For D1; applying window
% % Stopband Attenuation
% A = 40;
% % beta for Kaiser window
% b = 0.5842*((A-21)^0.4)+0.07886*(A-21);
% wn = kaiser(N_srrc,b);
% 
% % Matlab cant do this; matrix dimensions not the same
% % h_srrc = ifft(Hsrrc_f).*wn.';
% 
% % Try this
% h_srrc = h_srrc.*wn.';


% impulse response of srrc filter
figure(2)
plot(0:N_rc-1,h_rc,'r*', 0:N_srrc-1,h_srrc,'bd', 'MarkerSize',8);
title('Impulse response for SRRC and RC filter');
ylabel('h_{rc}[n] and h_{srrc}[n]');
xlabel('n');
legend('raise cosine','SRRC');
grid;
% Note that every 4th sample in the RC's IR is zero. This property does not
% exist in the SRRC

% Find and plot the frequency repsonses of the
% finite length RC and SRRC filters
H_hat_rc = freqz(h_rc,1,2*pi*f);
H_hat_srrc = freqz(h_srrc,1,2*pi*f);

figure(3)
% Frequency Response
% plot(f,abs(H_hat_rc),'r', ...
%     f,abs(H_hat_srrc),'--b','LineWidth',2);
% Magnitude Response
plot(f,20*log10(abs(H_hat_rc)),'r', ...
f,20*log10(abs(H_hat_srrc)),'--b','LineWidth',2);
% 
ylabel('H_{hat}(\Omega) for RC and SRRC');
xlabel('\Omega');
% title('Frequency response for finite-length SRRC and RC filter');
title('Magnitude response for finite-length SRRC and RC filter');
legend('RC','SRRC');
grid;
% The finite-length filter has more ripples in passband & stopband; with
% minor distortions in the transition band

% See if the 21 sample SRRC filter can meet the stopband requirement by
% plotting the magnitude response

% we can see that the sidelobe's height violates the stopband attenuation