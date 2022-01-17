%% Part A: Sinusoidal Input
% Design a length 21 Square-Root-Raised Cosine filter (an FIR filter with 21 coecients) that
% has 4 samples per symbol and roll-off factor of ? = 0.25.
% The filter must be designed so that a full scale 1s17 sinusoidal input produces a 1s17
% sinusoidal output. Furthermore the coeffcients must be scaled so that the maximum of the
% magnitude response is exactly 1.
clear
close all
clc

format long g

% Stage 1: Filter coefficients

% initial values
% length of filter
N = 21;
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

% Impulse Response of srrc filter
h = rcosdesign(beta, span, Nsps, shape);

% frequency response of srrc filter
[H,w] = freqz(h,1);

% Plot impulse response
fvtool(h,'impulse');

% Generate & plot the frequency response
FR = figure('Name','Frequency Response');
plot(w/(2*pi),20*log10(abs(H)));
ylabel('20*log(|H(e^{j\omega})|)'); %Amplitude Response
title('SRRC Magnitude Response');
grid;
datacursormode(FR,'on');
peak_1 = max(20*log10(abs(H)));

H_max_sine = max(abs(H));

% Now scale the coefficient to remove the headroom in the output
% safety_factor = 1-2^-17; % used to ensure peak gain is less than 1
safety_factor = 1-2^-16; % used to ensure peak gain is less than 1
h_sine_scaled= h * (1/H_max_sine) * safety_factor; 


% Find the magnitude response of the scaled truncated impulse response
w = [.5:1:1000]/1000*pi; % frequency vector in radians/sample
H_sine_scaled= freqz(h_sine_scaled, 1, w);
figure(2); 
plot (w/2/pi,20*log10(abs(H_sine_scaled))); % freq axis in cycles/sample
grid; axis([0.0,0.5,-50,10]);
xlabel('frequency in cycles'); 
ylabel('20  log ( | H_{hd rm removed}(e^{j 2 pi f}) | )');
title('magnitude response with headroom removed from the output')


% Convert h_sine_scaled ( which has 0 integer bit with matlab precision 
% number of fraction bits, say 1s"infinity" format ) to 18s0 format 
% ( which is an 18 bit signed decimal integer ). An 18 bit  signed decimal
% integer can be entered into a Verilog HDL as "18'sd number" if "number" 
%  is positive and  as "-18sd |number|" if "number" is negative
h_signed_integer = round(h_sine_scaled * 2^18);
disp(['coefficients for Sine input filter']);
fprintf('\n');
for i = 1:(length(h_signed_integer)/2)+1
    if (h_signed_integer(i) > 0)
        disp(['b[' num2str(i-1) '] = 18''sd' num2str(abs(h_signed_integer(i))) ';'])
    else
        disp(['b[' num2str(i-1) '] = -18''sd' num2str(abs(h_signed_integer(i))) ';'])
    end
end

% Convert the 18 bit signed integer to a 1s17 format so that the actual
% magnitude response (i.e. the magnitude response with coefficients
% that have only 18 bits of precision) can be calculated
h_final = h_signed_integer/2^18; 
% coefficients_in_18_bit_precision = h_final' % print h_final as a column  
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

if (H_final_max > 1)
    fprintf('\n\t\t\t!!!!ERROR!!!!\n\nMaximum magnitude response of the sine input SRRC filter is: %10.17f\n', H_final_max);
else
    fprintf('\n\t\t\tNo issues with Filter design\n\nMaximum magnitude response of the sine input SRRC filter is: %10.17f\n', H_final_max);
end

% write 1s17 FS sinusoid to text for modelsim
f = 0:0.001:1;
FS1s17 = 2.^17*sin(2*pi*f);
% FS1s17 = sin(2*pi*f);
format long
FS1s17 = round(FS1s17);
fileID = fopen('input_sine.txt','w');
fprintf(fileID,'%d\r\n',FS1s17);
fclose(fileID);


%% Part B Managing Headroom
% 1) Find 21 sample input sequence that produces largest possible peak value
% in output. This 21 sample sequence is referred to as the worst case input
worse_case = zeros(length(h),1);

% worse case input can be found when output of the filter is at the maximum
% positive value or maximum negative value. Since we want a 1s17 signal for
% the output, the max positive value is ~1 and the maximum negative value
% is -1.
for i = 1:length(h)
    if (h(i) > 0)
        worse_case(i) = 1;
    else
        worse_case(i) = -1;
    end
end

% 2) Determine the decimal worth of the peak output for the worse case
% input
peak_output = 0;

% Find the peak positive output
for i = 1:length(h)
    peak_output = peak_output + (worse_case(i)*h(i));
end

fileID = fopen('input_worst.txt','w');
fprintf(fileID,'%d\r\n',worse_case);
fclose(fileID);

fprintf('\ndecimal worth of the peak output given the worse case input: %10.17f\n\n',peak_output);

% 3) Scale the coefficients of the filter so that its 1s17 output has a a peak value of 18'H1FFFF, for the worst case input.
scaled_h = h * (1-2^-17)/peak_output;

% verify magnitude response of scaled impulse response is the same
[H_scaled, w] = freqz(scaled_h,1); 

sFR = figure('Name','Frequency Response of scaled');
plot(w/(2*pi),20*log10(abs(H_scaled)));
ylabel('20*log(|H(e^{j\omega})|)'); %Amplitude Response
title('scaled SRRC Magnitude Response');
grid;
datacursormode(sFR,'on');

% Peak of the magnitude response is
H_scaled_max = max(abs(H_scaled));


% convert the scaled IR to 18s0 format for Verilog
h_signed_integer = round(scaled_h * 2^18);
disp(['coefficients for filter given worse case input']);
fprintf('\n');
for i = 1:(length(h_signed_integer)/2)+1
    if (h_signed_integer(i) > 0)
        disp(['b[' num2str(i-1) '] = 18''sd' num2str(abs(h_signed_integer(i))) ';'])
    else
        disp(['b[' num2str(i-1) '] = -18''sd' num2str(abs(h_signed_integer(i))) ';'])
    end
end

% Convert 18 bit signed number to 1s17 so the actual magnitude response
% (i.e. the magnitude response with coefficients that only have 18 bits of
% precision can be calculated) can be calculated.
% disp(['coefficients for in 1s17 format']);
h_final = h_signed_integer/2^18; 
% coefficients_in_18_bit_precision = h_final'

% Find the frequency response of the final filter, which has coefficients
% with only 18 bits of precision
w = [.5:1:1000]/1000*pi; % frequency vector in radians/sample
H_final = freqz(h_final, 1, w);
H_final_max = max(abs(H_final));
format long
figure(3); 
plot (w/2/pi,20*log10(abs(H_final))); % freq axis in cycles/sample
grid; 
axis([0.0,0.5,-50,10]);
xlabel('frequency in cycles');
ylabel('20  log ( | H_{final}(e^{j 2 pi f}) | )');
title('Final filter');
print -deps mag_response_with_practical_coefficients.eps
peak_2 = max(20*log10(abs(H_final)));

comparison = 0;

for i = 1:length(h_final)
    comparison = comparison + (h_final(i)*worse_case(i));
end

% H_final was rounded up in its assignment
if (comparison > 1)
    fprintf('\n\t\t\t!!!!ERROR!!!!\n\nMagnitude response of the filter given the worse case input is: %10.17f\n', comparison);
else
    fprintf('\n\t\t\tNo issues with Filter design\n\nMagnitude response of the filter given the worse case input is: %10.17f\n', comparison);
end