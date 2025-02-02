% calculation of filter coefficients and the magnitude response
% for an approximation to a brick wall low pass filter
clear
% parameters
fp = 1/8;
N=31;
N_I = 2; % integer bits in filter output
N_F = 16; % fraction bits in filter output

%derived parameters
n = [0:N-1];

% Begin Computation
% Find coefficients (i.e. the impulse response) for a filter that
% approximates a brick wall filter with a pass-band gain of 1.
h = 2 * fp * sin ( 2*pi * fp * (n- (N-1)/2) +10^(-8)) ./ ...
               (2*pi * fp *(n- (N-1)/2)+10^(-8));  
% Find the magnitude response of the truncated impulse response
% when the infinite length response has a flat pass-band gain of 1.
% The truncated response will have ripple in the pass band.
w = [.5:1:1000]/1000*pi; % frequency vector in radians/sample
H= freqz(h, 1, w);
figure(1); plot (w/2/pi,20*log10(abs(H))); % freq axis in cycles/sample
grid; axis([0.0,0.5,-50,10]);
xlabel('frequency in cycles'); ylabel('20  log ( | H(e^{j 2 pi f}) | )');
print -deps mag_response_for_length_31
% The peak of the magnitude response is
H_max = max(abs(H));

% Choose output format
% Since H_max was observed to be 1.102, the output format will require s
% 1 more integer bit than the input.  Since the format of the input 
% is 1s17 and output is to be 18 bits, the output must have format 2s16

% An output format of 2s16 can accommodate a peak value of nearly 2.
% However the peak output is 1.102. This leaves considerable headroom
% in the output. The head room in the output can be removed by increasing
% the peak gain of the filter to nearly 2. The gain can be increased
% to nearly 2 by scaling all the coefficients by (2/1.102)*safety_factor,
% where safety factor is slightly less than 1 to ensure the peak gain
% will be less than 2.


% Now scale the coefficient to remove the headroom in the output
safety_factor = 0.999; % used to ensure peak gain is less than 2
h_hd_rm_removed = h * (2/1.102) * safety_factor; 


% Find the magnitude response of the scaled truncated impulse response
w = [.5:1:1000]/1000*pi; % frequency vector in radians/sample
H_hd_rm_removed= freqz(h_hd_rm_removed, 1, w);
figure(2); 
plot (w/2/pi,20*log10(abs(H_hd_rm_removed))); % freq axis in cycles/sample
grid; axis([0.0,0.5,-50,10]);
xlabel('frequency in cycles'); 
ylabel('20  log ( | H_{hd rm removed}(e^{j 2 pi f}) | )');
title('magnitude response with headroom removed from the output')


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
axis([0.0,0.5,-50,10]);
xlabel('frequency in cycles');
ylabel('20  log ( | H_{final}(e^{j 2 pi f}) | )');
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


