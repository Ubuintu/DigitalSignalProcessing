% calculation of filter coefficients and the magnitude response
% for an approximation to a brick wall low pass filter
clc
close all
clear
format long

% parameters
N = 21;   % Deliverable 1
% Order of filter
M = N-1;
% Number of symbols per sample OR Nsps
Nsps = 4;
% length of the pulse
span = M/Nsps;
% ? or excess bandwidth
beta = 0.25;
% shape of rcosdesign filter
shape = 'sqrt';

%derived parameters
% n = [0:N-1];

% Begin Computation
% Find coefficients (i.e. the impulse response) for a filter that
% approximates a SRRC filter with the above parameters.
h = rcosdesign(beta, span, Nsps, shape);  
  
% Find the magnitude response of the SRRC
w = [.5:1:1000]/1000*pi; % frequency vector in radians/sample
H= freqz(h, 1, w);
figure(1); plot (w/2/pi,20*log10(abs(H))); % freq axis in cycles/sample
grid; axis([0.0,0.5,-100,20]);
xlabel('frequency in cycles/samples'); ylabel('20  log ( | H(e^{j 2 pi f}) | )');
title('magnitude response');
print -deps mag_response_for_length_31
% The peak of the magnitude response is
H_max = max(abs(H));

% Choose output format
% Since H_max was observed to be 2.0928, the output format will require 
% 2 more integer bits than the input.  Since the format of the input 
% is 1s17 and output is to be 18 bits, the output must have format 3s15

% An output format of 3s15 can accommodate a peak value of nearly 4.
% However the peak output is 2.0928. However we are asked to design the filter
% such that a FS 1s17 sine input produces a 1s17 sine output. The head room in the output 
% can be managed by determining a scaling factor that will reduce 
% the peak gain of the filter to nearly 1. The gain can be reduced
% to nearly 1 by scaling all the coefficients by (1/2.0928)*safety_factor,
% where safety factor is slightly less than 1 to ensure the peak gain
% will be less than 1.

% For the first filter
% h_hd_rm_removed = h;

% Now scale the coefficient to ensure the output fits a 1s17 format
safety_factor = 1-2^-17; % used to ensure peak gain of 18'H1FFFF
h_hd_rm_removed = h * (1/H_max) * safety_factor;



% Find the magnitude response of the scaled truncated impulse response
w = [.5:1:1000]/1000*pi; % frequency vector in radians/sample
H_hd_rm_removed= freqz(h_hd_rm_removed, 1, w);
figure(2); 
plot (w/2/pi,20*log10(abs(H_hd_rm_removed))); % freq axis in cycles/sample
grid; axis([0.0,0.5,-100,20]);
xlabel('frequency in cycles'); 
ylabel('20  log ( | H_{hd rm removed}(e^{j 2 pi f}) | )');
title('Magnitude response with headroom removed from the output')


% Convert h_hd_rm_removed ( which has 1 integer bit with matlab precision 
% number of fraction bits, say 1s"infinity" format ) to 18s0 format 
% ( which is an 18 bit signed decimal integer ). An 18 bit  signed decimal
% integer can be entered into a Verilog HDL as "18'sd number" if "number" 
%  is positive and  as "-18sd |number|" if "number" is negative
h_signed_integer = round(h_hd_rm_removed * 2^17);
coefficients_for_Verilog_HDL = h_signed_integer' % print h_signed_integer 
                                                 % as a column vector in
                                                 % the command window

% Convert the 18 bit signed integer to a 1s17 format so that the actual
% magnitude response (i.e. the magnitude response with coefficients
% that have only 18 bits of precision) can be calculated
h_final = h_signed_integer/2^17; 
coefficients_in_18_bit_precision = h_final' % print h_final as a column  
                                            % vector in the command window

% Find the frequency response of the final filter, which has coefficients
% with only 18 bits of precision
w = [.5:1:1000]/1000*pi; % frequency vector in radians/sample
H_final = freqz(h_final, 1, w);
H_final_max = max(abs(H_final));
figure(3); 
plot (w/2/pi,20*log10(abs(H_final))); % freq axis in cycles/sample
grid; 
axis([0.0,0.5,-100,20]);
xlabel('frequency in cycles');
ylabel('20  log ( | H_{final}(e^{j 2 pi f}) | )');
title('Magnitude Response of final filter design');
print -deps mag_response_with_practical_coefficients.eps


% NB: FOR INTEREST ONLY - NOT NEEDED IN THE LAB
% the coefficient in 1s18 format, i.e.  h_signed_integer,
% can be converted to an 18 bit decimal integer in 2s complement format.
% 2s complemnent is suitable for entering into Veilog HDL. If the 2s  
% complement format number is in matlab variable h_2s_comp, then the 
% Verilog HDL entry could be ``assign b_k = 18'd h_2s_comp(k)'', where 
% the decimal number value of h_2s_comp(k) is typed in its place. 
% In this format all values of h_2s_comp(k) are positive.
for k = [1:N],
if (h_signed_integer(k) < 0) % need to take two's complement
    h_2s_comp(k) = 2^18+h_signed_integer(k);
else
    h_2s_comp(k) = h_signed_integer(k);
end 
end


