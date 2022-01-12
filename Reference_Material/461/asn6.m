%% Q1
clear all
close all
% Design a lowpass filter using the window method. Assume a passband gain of 2, peak ripple of 0.01,
% passband corner frequency of ?/8 and stopband corner frequency of ?/4. Confirm your design meets
% specifications, by implementing it in MATLAB. What is peak ripple in your implementation? Why
% is the peak ripple much better than the specified peak ripple 0.01?

% see slide 128

%****** Define intial values (slide 105) ******
% filter design procedure for passband gain != 1 on slide 130

%passband gain is 2
    Gp = 2; 
%stopband gain
    Gs = 0; 

% corner frequency for passband & stopband respectively
    wp = pi/8;      %normalized: pi/8/2pi = 1/16 = 0.0625 cycles/sample
    ws = pi/4;      % <- 0.125 cycles/sample

% tolerance, delta
    delta_spec = 0.01;  %specified ripple
    delta = delta_spec/Gp;  %peak ripple

%****** Determine the window to use ******
% Kaiser Window method selection on slide 127; Window specifications on
% slide 123

% Find stopband Attenuation, A
    A=-20*log10(delta);     %A = 46.02 dB so from table on slide 123, pick Hamming window
    
%Find order, M, via transition width equation; ws - wp = 6.27pi/M
    M=6.27*pi/(ws-wp);  %M = 50
    M=round(M);
    
%****** Generate the Impulse Response ******  
%using the IRT technique as specified on slides 82-83
    n=0:M;  %sample indicies
    
% expression for f2 is the expression for the cutoff frequency (slide 128)
    f2 = ((wp+ws)/2)/(2*pi);
    f1 = 0;
    
% desired impulse response
    hd = 2*f2*sinc( 2*f2*(n-M/2)) - 2*f1*sinc(2*f1*n(M/2) );       %note that f1 is 0 so 2nd term inside sinc should disappear,however this line is good when you need to find the order via trial & error
    hd = Gp*hd;     %scale desired IR by passband-stopband gain? 
    
% create Hamming window using length N = M+1
    win=hamming(M+1);
    
% calculate actual IR; note window is a column vector from kaiser() so we need to take
% its transpose (use syntax ' ) in order to take the product with our row vector desired IR
    h=hd.*win';
    
%****** Plot the Amplitude Response ****** 
    L = 1024;   %len of 1024 samples
    
%take IR and zero-pad it with the above len
    hz = [h,zeros(1,L-length(h))];
    
% Take Discrete Fourier Transform via Fast Fourier Transform, fft()
    H=fft(hz);
    
% k is a vector from 0 to 1023; L is 1024.
    k=0:L-1;
    
% M is even - thus this a type 1 filter with a linear phase response of 
% -(M/2)*2*pi*f, where f=k/L
    W=exp(-1i*(-M/2)*2*pi*k/L);
    
% Amplitude Response = IR * exp(phase_resp)
    A = H.*W;
    
% Remove minor IM components of A
    A=real(A);

% use ffshift since fft generates freq resp from 0 to L-1; need to generate 
% for cycles per sample so we need x-axis to be k/L shifted by 0.5 for a double sided spectrum
    AR = figure('Name','LPF Amplitude Response, A(e^{j\omega})');
    plot( (k/L-0.5) , fftshift(A) );
    ylabel('A(e^{j\omega})');
    title('LPF Amplitude Response using Hamming Window');
    xlabel('f (cycles/sample)');
    grid
    datacursormode(AR,'on'); 
    
%****** Calculate the Peak Ripple ****** 

%calculate peak ripple to see if passband meets spec
    Hamming_peak_ripple = max(abs(H));  %peak ripple is 2.0048; 2.0048-2 = 0.0048 < 0.01 thus it meets spec
    
% passband & stopband look like they meet spec as well; peak ripple in
% implementation is about 2.0048 which is less than .01 of our required
% peak ripple. Because a Hamming window is used which results in a 53 dB
% stopband attenuation (slide 123). Though the nominal passband gain is 2, which
% decreases the stopband attenuation by 6 dB

% Thus, since A-6 = 20log(delta) (A is 53 dB attenuation of a Hamming window), the expected delta = 10^(-47/20) = 0.0045
% which is close to the measured value of 0.0048

%% Q2
clear all
close all
clc
% Design a highpass filter using the Hann window method. Assume a passband gain of 1,
% stopband corner frequency of pi/8 and passband corner frequency of pi/4. 

% Confirm your design meets specifications, by implementing it in MATLAB. What is the calculated peak ripple and the peak ripple
% in your implementation? 
    
% **Note this question doesn't specify the passband or stopband ripple;



%****** Define intial values (slide 105) ******
    ws = pi/8;
    wp = pi/4;
    
% Assume stopband gain is 0
    Gp = 1;
    Gs = 0;
    
%****** Define parameters of Hann Window (slide 123) ******

% stopband Attenuation for a Hann Window, A <= 44 dB
    A = 44;
    
% order M for Hann; note when designing a HPF, the transition width is
% wp-ws
    M = 5.01*pi/(wp-ws);
    M = round(M);
    
% Sample indices 
    n=0:M;
    
% HPF's cutoff frequency using IRT method of slide 83
    %cutoff frequency is between the corner frequencies, thus: (wp+ws)/2
    f2 = ((wp+ws)/2)/2/pi;
    f1 = 0.5;
    
% desired IR slide 82
    hd = 2*f2*sinc( 2*f2*(n - M/2) ) - 2*f1*sinc( 2*f1*(n - M/2) );
    
% Create Hann Window of length N = M+1
    win = hann(M+1);
    
% Find actual IR; *note* when using window functions, you need to take the
% transpose of the vector since its a column vector and NOT a row vector
    h = hd.*win.';
    
% Compute the Frequency Response
    [H,w] = freqz(h,1,[0:.01:pi]);
    
% Plot Amplitude Response & confirm it meets spec
    AR = figure(1);
    clf
%     plot( w/(2*pi), 20*log10(abs(H)) ); % for dB
    plot( w/(2*pi), abs(H) ); % for linear units
    hold;
    
% plot horizontal line to see if fc has a magnitude of 0.5; it does
%     plot( [0 0.5] , [20*log10(0.5) 20*log10(0.5)], '-k');   % for dB
    plot( [0 0.5] , [0.5 0.5], '-k');   % for linear units of Amplitude
    title('High Pass Filters Amplitude Response in dB using Hann Window');
    xlabel('f (cycles/sample)');
    ylabel('20log(|H(e^{j\omega})|)|');
    grid;
    hold off;
    datacursormode(AR,'on'); 
    
% peak ripple
    measured_peak_ripple = max(abs(H))-1;

% using similar approach on slide 107 for passband ripple
% passband ripple in dB (peak-to-peak) 
    A_pM = 20*log10( ( max(abs(H)) )/( 1-measured_peak_ripple ) );
    
    delta_p = ( 1 - 10^(-A_pM/20) )/( 1 + 10^(-A_pM/20) );

% tolerance in ripple is calculated to be 0.1124 whereas measured tolerance ripple is
% 0.0065; not sure if A_pM approach is how I should calculate peak ripple

%% Q4e
close all 
clc
clear all;

% Initial Values
wp = 0.525*pi;
ws = 0.475*pi;

%first band AKA LP componet
% slide 83 for LP's f
    f11 = 0;
% fc of LPF
% f = ( (ws+wp)/2 )
    f21 = (0.3*pi + 0.2*pi)/(2*2*pi);

%second band AKA HP component
%f12 is fc for the HP component
    f12 = (0.525*pi+0.475*pi)/(2*2*pi);
%f22 is always 0.5 for HPF slide 83
    f22 = 0.5;

%transition width
    tw = wp-ws;   

%Gain in bands
    C1 = 1;
    C2 = 2;

%Don't use worst case tolerance; from HP & LP component, use the smallest
%tolerance, in this case its the HP tolerance/gain?
% delta = 0.1/2;
% 
% Rory says to use equation for tolerance on slide 107
    delta = (1 - 10^(-(1.1 - 0.9)/20) )/( 1 + 10^(-0.2/20) );

%stopband attenuation, A | slide 127
% Amplitude using slide 107 is ~39 dB
% Amplitude from reference is ~26 dB
    A = -20*log10( delta );

%order M, for kaiser design depends on A; use the smallest transition width
%to get larger order for more accurate filter: 
% HP transition width is wp = 0.525pi - ws = 0.475pi = 0.05pi
    M = ( A - 8 )/( 2.285*( wp - ws ) );
    M = round(M);

%sample indices
    n = 0:M;

%beta
    beta = 0.5842*(A-21)^0.4 + 0.07886*(A-21);   % A < 50

% Referring to two_band_filter.m for IR
%Generate and plot the impulse response, h | slide 83
    h1=2*f21*sinc(2*f21*(n-M/2))-2*f11*sinc(2*f11*(n-M/2)); %IR for first band LP component
    h2=2*f22*sinc(2*f22*(n-M/2))-2*f12*sinc(2*f12*(n-M/2)); %IR for 2nd band HP component

%IR for the 2 bands with gains are summed
    hd=C1*h1+C2*h2;

% Kaiser Window Calculation for length N = M+1 & beta of specified Amplitude
    win = kaiser(M+1,beta);

% Actual IR; note that win is a column vector, thus we need to take its
% transpose
    h = hd.*win.';

% Generate Frequency Response Plot
[H,w]=freqz(h,1,[0:.001:pi]);

FR = figure(1);
clf;

%generate dB plot
% plot(w/(2*pi),20*log10(abs(H)))
% ** Not sure why my Freq Response is raised by 1? MAKE SURE THAT INITIAL VALUES "f_x" ARE IN CORRECT UNITS**
plot(w/(2*pi),abs(H));

    hold;
% plot required passband ripple
    plot([0 (0.2*pi/2/pi)],[1.1 1.1], '-k');
    plot([0 (0.2*pi/2/pi)],[0.9 0.9], '-k');
    
% plot required stopband ripple
    plot([wp/2/pi pi/2/pi],[2.1 2.1], '-k');
    plot([wp/2/pi pi/2/pi],[1.9 1.9], '-k');

title('Lowpass filter using a Kaiser window')
xlabel('f (cycles/sample)')
ylabel('20log(|H(e^{j\omega})|)')
grid 
hold off;
datacursormode(FR,'on');


% a) Max value of tolerance for the worst case scenario, where peak ripples
% overlap is 0.1 + 0.1 = 0.2

% b) Transition width to calculate the filter order should be the smallest
% transition width between the HP component & LP component, in this case,
% the HP's transition width is 0.05pi

% c) Order of the filter is 86 from above

% d) Window shape, Beta is 3.249



%% Q5
clear all
close all
% Design a low pass filter using a Kaiser window, where ? = 0.001, ?p = 0.4? and ?s = 0.5?. Does
% the filter meet specs, check by implementing the filter in MATLAB. Write a MATLAB program that
% plots the impulse response on one figure window, the amplitude response in a second figure window
% and on a third figure window the magnitude response in dB. Use the MATLAB function fir1 to
% calculate the impulse response for the filter. Appropriately label the plots. Publish your m-file as a
% pdf document with suitable section headings.

%****** Define intial values (slide 105) ******

    wp = 0.4*pi;    %corner frequency for passband
    ws = 0.5*pi;    %corner frequency for stopband
    delta = 0.001;  %ripple tolerance
    A = -20*log10(delta);   %stopband attenuation; should be 60 dB
    
%****** Define parameters for Kaiser Window design (slide 127) ******
    M = (A-8)/(2.285*(ws-wp));   %order
    M = round(M);    %M=72
    
% Kaiser window shape, beta, for Order > 50
    beta = 0.1102*(A-8.7);
    
if A <= 50
    display(['A=',num2str(A),', an incorrect value was used for beta']')
end

% cutoff frequency for a lowpass filter is in-between the corner passband & corner stopband frequency
    wc = (ws+wp)/2;
    
% Use the MATLAB function fir1() to calculate the impulse response for the
% filter; see doc fir1()**
    h=fir1(M,wc/pi,'low',kaiser(M+1,beta));
    
%****** Plot LPF via Kaiser Window ******

% Calculate frequency response
    [H,w] = freqz(h,1,[0:0.01:pi]);
    
% Phase response for a LPF type 2 filter
    W = exp(-1i*(-M/2)*w);
    
% Calculate Amplitude Response
    A = H.*W;
    A = real(A);    %remove minor IM components
    
% Plot IR
    IR = figure('Name','LPF Impulse Response, h[n]');
    stem([0:M],h);
    ylabel('h[n]');
    title('LPF Impulse Response using Kaiser Window');
    xlabel('f (cycles/sample)');
    grid
    datacursormode(IR,'on'); 
    
% Plot Amplitude Response
    AR = figure('Name','LPF Amplitude Response]');
    plot(w/(2*pi),A);
    ylabel('A(e^{j\omega})');
    title(['LPF Amplitude Response using Kaiser Window, M = ',num2str(M)]);
    xlabel('f (cycles/sample)');
    grid
    datacursormode(AR,'on'); 
    
% Plot Magnitude Response/Amplitude Response in dB
    AR_dB = figure('Name','LPF Amplitude Response in dB');
%     plot(w/(2*pi),20*log10(A));
    plot(w/(2*pi),20*log10(abs(H)));
    ylabel('20log(|H(e^{j\omega})|)');
    title(['LPF Amplitude Response in dB using Kaiser Window, M = ',num2str(M)]);
    xlabel('f (cycles/sample)');
    grid
    datacursormode(AR_dB,'on'); 
    
%****** Calculate the Peak Ripple ****** 

%calculate peak ripple to see if passband meets spec
    peak_ripple = max(abs(H)) - 1;  %peak ripple is 1.0011; 1.0011-1 = 0.0011 > 0.001 this filter design does not meet spec
    
if peak_ripple <= delta
    display(['peak ripple is ',num2str(peak_ripple),' dB, thus this filter meets spec.']);
else
    display(['peak ripple is ',num2str(peak_ripple),' dB BUT tolerance is ',num2str(delta),' dB, thus this filter meets spec.']);
end

%% Q6
clear all
close all
clc
% Design a high pass filter using a Kaiser window, where delta = 0.001, wp = 0.6pi and ws = 0.5pi. 
% 
% Implement the filter by converting the lowpas filter design in the previous question into a high pass filter (could use technique in IRT-ish?). 
% 
% If the order of the filter in the previous question is odd, will the filter designed in this question be a high
% pass filter? 
% 
% Write a MATLAB program that plots the impulse response on one figure window, the
% amplitude response in a second figure window and on a third figure window the magnitude response
% in dB. 
% 
% Use the MATLAB function fir1 to calculate the impulse response for the filter. Appropriately
% label the plots. Publish your m-file as a pdf document with suitable section headings.

% Ripple Tolerance
    delta = 0.001; %dB
    
% Corner Frequency for HPF
    wp = 0.6*pi;
    ws = 0.5*pi;

% Stopband Attenuation for Kaiser window:
    A = -20*log10( delta ); %A = 60 dB
    
% Order M for Kaiser
    M = ( A-8 )/( 2.285*(wp-ws) );
    M = round(M);
    
% Window Shape, beta for A > 50
    beta = 0.1102*( A-8.7 ); 

% cutoff frequency for a highpass filter is in between the corner passband & corner stopband frequency
    wc = (ws+wp)/2;
    
% Kaiser Window design with above order & beta:
    win = kaiser(M+1,beta);
    
% Use the MATLAB function fir1 to calculate the impulse response for the filter.
    h=fir1(M,wc/pi,'high',win);
    
% Sample indices
    n = 0:M;
    
% Plot impulse response
    ir = figure(1);
    stem(n,h);
    title('Impulse Response of a HPF');
    ylabel('h[n]');
    xlabel('f (cycles/sample)');
    grid;
    datacursormode(ir,'on');
    
% calculate frequency response:
    [H w] = freqz(h,1,[0:0.01:pi]);
    
% calculate amplitude response:
    A_r = H.*exp(-i*-M/2*w);
    A_r = real(A_r);
    
% Plot Amplitude Response
    ar = figure(2);
% Both of these plot the same Amplitude response
%     plot( w/2/pi, abs(H) );
    plot( w/2/pi, A_r );
    title('Amplitude Response of a HPF');
    ylabel('A(e^{j*\omega})');
    xlabel('f (cycles/sample)');
    grid;
    datacursormode(ar,'on');
    
% Plot Magnitude Response
    mr = figure(3);
% Both of these plot the same Amplitude response
    plot( w/2/pi, 20*log10(abs(H)) );
%     plot( w/2/pi, 20*log10(A_r) );
    title('Magnitude Response of a HPF');
    ylabel('|H(e^{j*\omega})|');
    xlabel('f (cycles/sample)');
    grid;
    datacursormode(mr,'on');
    
% If the order of the filter in the previous question is odd, will the 
% filter designed in this question be a high pass filter?

% No, using the FIR filter characteristics of slide 70, if the order was
% odd, it may change the filter type to that of a type 2 filter, which are
% mainly used to build LP or BP filters
%% Q7
clear all
close all
% A type I HPF is needed, where ws = 0.7pi, wp = 0.8pi, delta_s = 0.0004 and delta_p = 0.001. 
% 
% Design a filter that meets the above specifications using both, the windows design approach and the Kaiser window
% design approach. 
% 
% Select the best filter for the implementation, providing a justification for your choice. 
% 
% Write a MATLAB program that plots the magnitude response in dB of the first design
% approach in one figure window and the magnitude response in dB of the second design approach in
% a second figure window. Use the MATLAB function fir1 to calculate the impulse response for the
% filter. 
% 
% Appropriately label the plots. Publish your m-file as a pdf document with suitable section
% headings.

%****** Define intial values (slide 105) ******

%solution specifies corner frequency as passband being smaller, typo in
%question
%corner frequencies:
    ws = 0.8*pi;
    wp = 0.7*pi;

% tolerance
    delta_s = 0.0004;
    delta_p = 0.001;

% find stopband Attenuation, A, slide 127
    A = -20*log10( min(delta_s,delta_p) );      %find minimum tolerance between stopband & passband; note this is a con of kaiser
    
%****** FIR window design slide 118, 123  ******

% A was found to be ~68 dB, so choose a Blackman window that can support such a
% stopband attenuation

% From Blackman window chars, find our design parameters:
% order, M
    M = 9.19*pi/(ws-wp);
    Mb = round(M);  
% make sure order is positive; cant have a negative order
    
    
% fc is between the corner stopband & passband frequency:
    wc = (ws+wp)/2; 
    fc = wc/(2*pi);   % for HPF, we expect @ fc, the magnitude in dB is -6.02 dB = 20log(0.5) 
    
% Calculate IR using fir1()
    hb = fir1(Mb, wc/pi, 'high', blackman(Mb+1));   %length is M+1
    
% Blackman window IR plot 
% ** For reference **
% n=0:Mb;
% stem(n,hb);
    
% FIR window design plot  
    AR_b = figure('name','Blackman HPF magnitude response in dB');
    [Hb,w] = freqz(hb,1,[0:.01:pi]);
    plot( w/(2*pi), 20*log10(abs(Hb)) );
    title( ['Highpass filter using a Blackman window, M = ',num2str(Mb)] );
    xlabel('f (cycles/sample)');
    ylabel('20log(|H(e^{j\omega})|)');
    grid;
    datacursormode(AR_b,'on'); 
    
 %****** FIR kaiser window design plot (slide 127) ******
 % stopband Attenuation, A, is ~68 dB
 
 %order
    M = (A-8)/( 2.285*(ws-wp) );
    Mk = round(M);
    
% window shape for A > 50:
    beta = 0.1102*(A-8.7);
    
if A <= 50
    display(['A=',num2str(A),', an incorrect value was used for beta']')
end

% IR via fir1()
    hk=fir1(Mk, wc/pi, 'high', kaiser(Mk+1,beta) );
    
% Plot Kaiser filter's magnitude response in dB  
    AR_k = figure('name','Kaiser window HPF magnitude response in dB');
    [Hk,w] = freqz(hk,1,[0:.01:pi]);
    plot( w/(2*pi), 20*log10(abs(Hk)) );
%     plot( w/(2*pi), (abs(H)) );
    title( ['Highpass filter using a Kaiser window, M = ',num2str(Mb)] );
    xlabel('f (cycles/sample)');
    ylabel('20log(|H(e^{j\omega})|)');
    grid;
    datacursormode(AR_k,'on'); 
    
%****** Calculate the Peak Ripple ****** 

%calculate peak ripple to see if passband meets spec
    Kaiser_peak_ripple = max(abs(Hk)) - 1;
    Blackman_peak_ripple = max(abs(Hb)) - 1;    
    
% Since both window methods meet spec, we choose the design that has a
% smaller order, which in this case is the kaiser window method. One reason
% for choosing this filter is because it has less delay elements in the
% filter circuit BUT filter choice is subjective (or objective based on
% requirements).
    
%****** Explanation on order ****** 
   
% https://www.quora.com/What-does-order-of-a-filter-mean?share=1
% Order of the filter determines the max number of delay elements used in
% the filter circuit, which can be seen by observing the difference
% equation & determining @ which sample we need to have the max delay.

% if you are Z - Domain, then by observing the highest powers of ‘z’ you can tell the order of the filter. 
% So, what happens if order increases, simply the number of delay blocks increases making the filter more complex in design, 
% but making it more and more efficient filter.

% This happens because, the more the past values of signal you accumulate, more experience you have about the signal and it’s characteristics, 
% and it becomes easier for filter to predict or estimate or make some relevant output by taking large number of sampled input value delay versions. 
% So the performance of a second order filter will always be better than the first order. Remember , more delay of input means, more information we 
% have about the input and it becomes easier to produce output from such samples

%% Q8
close all
clc
clear all;
% A filter has the following specifications: a passband from 200 Hz to 500 Hz, a transition width of 50
% Hz, 0.1 dB pass band ripple, 60 dB stop band attuenuation and a sampling rate of 2 kHz. 
% 
% Design a filter that meets the above specifications using the Kaiser window design approach. 
% 
% Does the filter meet spec? If not, make the necessary modifications to meet spec. 
% 
% Write a MATLAB program that plots the magnitude response in dB of the filter as a function of frequency with units Hz. 
% 
% Use the MATLAB function fir1() to calculate the impulse response for the filter. Appropriately label the
% plots. Publish your m-file as a pdf document with suitable section headings.

% "a passband from 200 Hz to 500 Hz" sounds like its a BPF
    fs = 2000;  %sampling frequency of 2 kHz
    f1 = 200/fs;   %units of Hz; lower passband frequency; EE365 units conversion, assume sampling frequency has units samples/second
    f2 = 500/fs;    %upper passband frequency
    
% transition width
    tw = 50*2*pi/fs; % Hz; converted to rads/sec
    
% Calculate corner frequencies for passband; f_corner*2*pi + transition
% width

    %lower corners
%     ws1 = f1*2*pi - tw;
%     wp1 = f1*2*pi + tw;
% These values make more sense for me since trans width is from stopband to
% passband & vice versa
    ws1 = f1*2*pi - tw;
    wp1 = f1*2*pi;

    %upper corners; note polarity of transition width when summing to find
    %corner frequency; 
%     ws2 = f2*2*pi + tw; % for upper frequency, stopband should have a higher f than passband
%     wp2 = f2*2*pi - tw; 
    %
    ws2 = f2*2*pi + tw; 
    wp2 = f2*2*pi;
    
    %cutoff frequency
    wc1 = (ws1+wp1)/2;  %lower fc
    wc2 = (ws2+wp2)/2;  %upper fc

% stopband attenuation
    As = 60; % dB

% passband ripple
    Ap = 0.1; % linear units
    
% ** This step might not be needed; good to know **
% % find ripple tolerance, delta. Note windowing involves using the worst case ripple tolerance 
%     % stopband attenuation should be negative to represent a loss in gain
%     deltas = 10^(-As/20);
% 
%     % passband ripple should vary by +/-0.1 dB thus we need to subtract by
%     % a linear unit of 1 since gain in passband should be 1 and we want
%     % ONLY the tolerance; convert passband attenuation to linear unit, then
%     % sub 1; multiplying Ap by +/-1 doesn't matter
%     deltap = 10^(Ap/20) - 1;
    
    
% order of a kaiser window slide 127; Window method wants to use smallest
% tolerance for higher order & more accurate filter design
    M = (As-8)/( 2.285*tw );  
    M = round(M);
    
% window shape, beta
    beta = 0.1102*(As-8.7);
    
% create IR for this BPF w/kaiser via fir1(); parameters of fir1() are
% the same as firls; slide 138-140 for details
    h = fir1( M, [wc1/pi wc2/pi],'bandpass',kaiser(M+1,beta) );
    
    % Note that vector fb containing our corner frequencies has units
    % between 0 & 1 since Matlab normalizes analog frequencies by Fs/2
    % istead of Fs
    
% calculate frequency response of filter
    [H, w] = freqz(h,1,[0:0.01:pi]);
    
% Magnitude Response plot
    mr = figure(1);
%     plot( w/2/pi, 20*log10(abs(H)) );
    plot( w/2/pi, abs(H) );
    title('BPF Magnitude Response via kaiser window & fir1()');
    ylabel('20log( |H(e^{j\omega})| )');
    xlabel('f (samples/second)');
    grid;
    datacursormode(mr,'on');
    

    

%% Q9
close all
clear all;
clc
% Specifications for a lowpass filter includes a passband corner frequency of pi/4, 
% a stopband corner frequency of 3pi/8, a passband ripple of 0.172 dB and 
% a stopband attenuation of 40 dB.
% 
% (a) Design a linear phase equiripple FIR filter. 
% 
% Estimate the order of the filter by comparing the estimates from techniques proposed by Bellanger, Kaiser, and Harris with firpmord. 
% 
% In this part only use firpmord to estimate the order for comparison with the other techniques. Use
% MATLAB to confirm your filter meets specifications.

% 

%****** Define intial values (slide 105) ******

    wp = 0.25*pi;    %corner frequency for passband
    ws = 3*pi/8;    %corner frequency for stopband
    
% Note that the ripple is given in dB instead 
    deltap = 10^(0.172/20)-1;  %passband ripple; note values for delta are in terms of voltage and NOT dB
    deltas = 10^(-40/20);  %stopband ripple; note values for delta are in terms of voltage and NOT dB
    
% Gains for stopband & passband are assumed to be 0 & 1 respectively if not
% specified
    Gs = 0;
    Gp = 1;
    
    
%****** Define filter order, M, using  Parks-McClellan, Bellanger, Kaiser and Harris(slide 147-148) ******

% Parks-McClellan method for estimating filter order (slide 148)

    % M = firpmord(ford,aord,dev,Fsord); slides 138 - 140.
    % ford | s.138: vector of corner frequencies of stop/pass bands with the first and last elements removed. firpmord assumes they are 0 and 1.
    % aord | s.139: vector of desired gain @ frequencies defined by fb
    % dev  | s.148: peak ripple in linear units
    %Fsord | s.148: is the sampling frequency in Hz. If not included it has a default value of 2
    
% using firpmord(), we find the order for a passband (f=0.25pi/2pi) with a
% gain of 1, stopband (f=3*pi/8/2pi) with a
% gain of 0, with the last parameter being their tolerance.
    M_pm = firpmord( [wp/pi ws/pi], [1 0], [deltap deltas]);
    
% Bellanger, Kaiser and Harris (slide 147)
    M_Bellanger = 2/3*log10( 1/(10*deltap*deltas) )*( 2*pi/abs(ws-wp) );
    
    M_Kaiser = ( -20*log10( sqrt(deltap*deltas) )-13 )/( 2.324*abs(ws-wp) );
    
    M_Harris = ( -20*log10(deltas) )/( 22*abs( (ws-wp)/2/pi ) );
    
% From the 4 techniques, use the select the technique which results in the
% highest order, in this case its by the Harris technique
    M = round(M_Harris);

    
    
%****** Design equiripple filter ******

% using similar method as Least Squares FIR design on slide 139-140
    fb = [0 wp ws pi]/pi;   %fb specifies the required freq bands within our filter design
    
% Amplitude/gain vector for the freqs in fb
    a = [Gp Gp Gs Gs];      %traditional LPF's have a = [1 1 0 0];
    
% Weight vector consists of ripple terms in the above frequency bands
    wght=[deltap^-1 deltas^-1];
% wght=[1 deltap/deltas]; %this also works (ie wght is a relative

% b is a vector containing the M+1 calculated impulse response coefficients (slide 146, 138-140).
    b = firpm(M, fb, a, wght);
    
    
    
%****** Plot magnitude response and compare the estimates proposed by Bellanger, Kaiser, and Harris with firpmord ******

    MR = figure(1);
% compute frequency response
    [ H,w ] = freqz( b, 1, [0:.01:pi]);
    plot(w, abs(H));
    grid
    hold
% plot required passband ripple
    plot([0 wp],[Gp+deltap Gp+deltap], '-k');
    plot([0 wp],[Gp-deltap Gp-deltap], '-k');
    
% plot required stopband ripple
    plot([ws pi],[Gs+deltas Gs+deltas], '-k');
    plot([ws pi],[Gs-deltas Gs-deltas], '-k');

% Matlab plotting
    title( ['Lowpass Equiripple filter with order M = ',num2str(M)] );
    ylabel('|H(e^{j\omega})|');
    xlabel('\omega (radians/sample)');
    
% use text( x,y,msg ) to display a message; adjust y to write on a newline
    text( 1.5, 1, ['M_{Bellanger}=',num2str(M_Bellanger)] );
    text( 1.5, 0.9, ['M_{Kaiser}=',num2str(M_Kaiser)] );
    text( 1.5, 0.8, ['M_{Harris}=',num2str(M_Harris)] );
    text( 1.5, 0.7, ['M_{firpmord}=',num2str(M_pm)] );
    datacursormode(MR,'on');
    
    
%****** Plot Amplitude response for linear phase equiripple FIR filter ******

    AR = figure(2);
% compute Amplitude response for lienar phase equiripple FIR filter
    W=exp( -1i*(-M/2)*w );
    A=H.*W;
    A=real(A);
    plot(w, A);
    grid
    hold
% plot required passband ripple
    plot([0 wp],[Gp+deltap Gp+deltap], '-k');
    plot([0 wp],[Gp-deltap Gp-deltap], '-k');
    
% plot required stopband ripple
    plot([ws pi],[Gs+deltas Gs+deltas], '-k');
    plot([ws pi],[Gs-deltas Gs-deltas], '-k');

% Matlab plotting
    title( ['Lowpass Equiripple Filter with order M = ',num2str(M)] );
    ylabel('A(e^{j\omega})');
    xlabel('\omega (radians/sample)');
    
% use text( x,y,msg ) to display a message; adjust y to write on a newline
    text( 1.5, 1, ['{\rm measured}{\delta_p}=',num2str( max(A)-1 )] );
    text( 1.5, 0.9, ['{\rm measured}{\delta_s}=',num2str( abs(min(A)) )] );
    datacursormode(AR,'on');
    
    
    
%****** Plot passband of the Amplitude response for linear phase equiripple FIR filter ******
    PB = figure(3);
    plot(w,A);
    grid;
    hold;
    
% plot required passband ripple
    plot([0 wp],[Gp+deltap Gp+deltap], '-k');
    plot([0 wp],[Gp-deltap Gp-deltap], '-k');
    axis( [0, ws, Gp-2*deltap, Gp+2*deltap] );
    title( ['Passband of Lowpass Equiripple Filter with order M = ',num2str(M)] );
    ylabel('A(e^{j\omega})');
    xlabel('\omega (radians/sample)');
    hold off;
    datacursormode(PB,'on');
    
    
    
%****** Plot stopband of the Amplitude response for linear phase equiripple FIR filter ******
    PB = figure(3);
    plot(w,A);
    grid;
    hold;
    
% plot required passband ripple
    plot([0 wp],[Gp+deltap Gp+deltap], '-k');
    plot([0 wp],[Gp-deltap Gp-deltap], '-k');
    axis( [0, ws, Gp-2*deltap, Gp+2*deltap] );
    title( ['Passband of Lowpass Equiripple Filter with order M = ',num2str(M)] );
    ylabel('A(e^{j\omega})');
    xlabel('\omega (radians/sample)');
    hold off;
    datacursormode(PB,'on');
    
    
    
%****** Plot stopband of the Amplitude response for linear phase equiripple FIR filter ******
    SB = figure(4);
    plot(w,A);
    grid;
    hold;
    
% plot required passband ripple
    plot([ws pi],[Gs+deltas Gs+deltas], '-k');
    plot([ws pi],[Gs-deltas Gs-deltas], '-k');
    axis( [ws, pi, Gs-2*deltas, Gs+2*deltas] );
    title( ['Stopband of Lowpass Equiripple Filter with order M = ',num2str(M)] );
    ylabel('A(e^{j\omega})');
    xlabel('\omega (radians/sample)');
    hold off;
    datacursormode(SB,'on');
    
% ------------(b) Design a linear phase equiripple FIR filter. Use the full capabilities of firpmord() in the design of------------
% the filter

% slide 149: we can use firpmord to generate the desired filter by
% using firpmord() to estimate the desired parameters:
    %[M,fb,a,wght]=firpmord(ford,aord,dev,Fsord)
    %firpmord's parameters are defined on slide 148; note Fsord defaults to
    %2 Hz
    %M, fb, a, wght are defined on slides 138-139
    [Mf, fo, ao, wo] = firpmord( [wp ws]/2/pi, [Gp Gs], [deltap deltas] );
    
% slide 146: using Parks-McClellan algorithm, we can find the vector, B,
% which contains M+1 calculated IR coefficients;
    % b = firls(M,fb,a,wght) slide 139-139:
    % fb is a vector of corner frequency bands
    % wght specifies the relative ripple in the bands. 
    bf = firpm( Mf, fo, ao, wo );
    
% calculated frequency response
    [Hf, wf] = freqz( bf,1,[0:.01:pi] );
    
% phase response; note that its linear for 
    Wf = exp(-1i*(-Mf/2)*wf);
    Af = Hf.*Wf;
    Af = real(Af);
    AR_f = figure(5);
    plot(w,Af);
    hold;
% plot required passband ripple
    plot([0 wp],[Gp+deltap Gp+deltap], '-k');
    plot([0 wp],[Gp-deltap Gp-deltap], '-k');
    
% plot required stopband ripple
    plot([ws pi],[Gs+deltas Gs+deltas], '-k');
    plot([ws pi],[Gs-deltas Gs-deltas], '-k');
    title( ['Amplitude Response of Lowpass Equiripple Filter by utilizing firpmord() (order M = ',num2str(M),')'] );
    ylabel('A(e^{j\omega})');
    xlabel('\omega (radians/sample)');
    grid;
    text( 1.5, 1, ['{\rm measured} {\delta_p}=',num2str( max(A)-1 )] );
    text( 1.5, 0.9, ['{\rm measured} {\delta_s}=',num2str( abs(min(A)) )] );
    text( 1.5, 0.8, ['The order must be increased to meet spec'] );
    hold off;
    datacursormode(AR_f,'on');
    
% The reason the order increases is that: the number of delay blocks increases making the
% filter more complex in design, the more the past values of signal you accumulate, the more experience you have about the signal and 
% it’s characteristics, and it becomes easier for filter to predict or estimate or make some relevant output by taking large number 
% of the sampled input value delay versions.
%% Q10
close all
clc
clear all;
% Specifications for a digital filter are given by:
%  
%     |H(ejw)| = ±0.01, 0 < |w| < 0.25pi,
%     |H(ejw)| = 1 ± 0.004, 0.35pi < |w| < 0.7pi,
%     |H(ejw)| = ±0.01, 0.8pi < |w| < pi.
%     
% Design a linear phase equiripple FIR filter. 
% (looks like a BPF based on magnitude response)

% slide 143-149
% Using Equirirrple design approach AKA PM approach which minimizes max
% error in each band;An advantage of this approach, similar to the least squares design, is that the pass band
% ripple does not have to be the same as the stop band ripple.

% lower band of BP
    ws1 = 0.25*pi;
    wp1 = 0.35*pi;
    
% Upper band of BP
    ws2 = 0.8*pi;
    wp2 = 0.7*pi;
    
% Tolerance delta
    deltas = 0.01;
%     deltas = 0.02;    % changing stopband tolerance didnt work for me
    deltap = 0.004;
    
% Gains for stopband & passband are 0 & 1 based on given Magnitude Response
% in Question
    Gp = 1;
    Gs = 0;
    
% ***See onenote slide 151 for Multiband filter design*** should be in his
% multiband filter.m file but its not on canvas
% with multiband filter PM design, you can only use one tolerance and transission width for calculating the order
    delta = min( deltas, deltap);
%     delta = max( deltas, deltap);
    
% Note that calucate the order and transition width is based on Band Pass
% Filter design; note the sequence of transition width & order calculation 
    trans_width = min( (wp1-ws1), (ws2-wp2) ); 
%     trans_width = max( (wp1-ws1), (ws2-wp2) );

% Parks-McClellan method for estimating filter order (slide 148)
    M_pm = firpmord( [ws1 wp1 wp2 ws1]/pi, [Gs Gp Gs], [deltas deltap deltas]);
    
% Bellanger, Kaiser and Harris (slide 147)
    M_Bellanger = 2/3*log10( 1/(10*deltap*deltas) )*( 2*pi/abs(trans_width) );
    
    M_Kaiser = ( -20*log10( sqrt(deltap*deltas) )-13 )/( 2.324*abs(trans_width) );
    
    M_Harris = ( -20*log10(deltas) )/( 22*abs( (trans_width)/2/pi ) );

% The Bellanger and Kaiser approximiations result in a higher order
% since the both take the minimum peak ripple and transition width.
% Thus choose the firpmod order. (Bruh y tf we do those calcs then?)
%     M=M_pm;
    M=M_pm+15;      %had to increase order
%     M=round(M_Bellanger);
    
%****** Design equiripple filter ******

% **Note from q9b, using the firpmord made a filter that didn't meet the
% design specs, might have to do more manual calcs

% slide 149: we can use firpmord to generate the desired filter by
% using firpmord() to estimate the desired parameters:
    %[M,fb,a,wght]=firpmord(ford,aord,dev,Fsord)
    %firpmord's parameters are defined on slide 148; note Fsord defaults to
    %2 Hz
    %M, fb, a, wght are defined on slides 138-139
%     [M, fo, ao, wo] = firpmord( [ws1 wp1 wp2 ws2]/(pi), [Gs Gp Gs], [deltas deltap deltas] );

% Manual calculations
    fo = [0 ws1/pi wp1/pi wp2/pi ws2/pi 1];
    ao = [Gs Gs Gp Gp Gs Gs];
    wo = [deltas deltap deltas]/deltas;
% wo(2) = 2.5;


% slide 146: using Parks-McClellan algorithm, we can find the vector, B,
% which contains M+1 calculated IR coefficients;
    % b = firls(M,fb,a,wght) slide 139-139:
    % fb is a vector of corner frequency bands
    % wght specifies the relative ripple in the bands. 
    bf = firpm( M, fo, ao, wo );
    
% calculated frequency response
    [Hf, wf] = freqz( bf,1,[0:.01:pi] );
    
% phase response; note that its linear for 
    Wf = exp(-1i*(-M/2)*wf);
    Af = Hf.*Wf;
    Af = real(Af);
    AR_f = figure(5);
    plot(wf,Af);
    hold;
    grid;
% plot required passband ripple
    plot([wp1 wp2],[Gp+deltap Gp+deltap], '-k');
    plot([wp1 wp2],[Gp-deltap Gp-deltap], '-k');
    
% plot required stopband ripple
    plot([0 ws1],[Gs+deltas Gs+deltas], '-k');
    plot([0 ws1],[Gs-deltas Gs-deltas], '-k');
    plot([ws2 pi],[Gs+deltas Gs+deltas], '-k');
    plot([ws2 pi],[Gs-deltas Gs-deltas], '-k');
    title( ['Amplitude Response of Lowpass Equiripple Filter by utilizing firpmord() (order M = ',num2str(M),')'] );
    ylabel('A(e^{j\omega})');
    xlabel('\omega (radians/sample)');
    text( 1.5, 0.8, ['{\rm measured} {\delta_p}=',num2str( max(Af)-1 )] );
    text( 1.5, 0.7, ['{\rm measured} {\delta_s}=',num2str( abs(min(Af)) )] );   
    text( 1.5, 0.6, ['just dont use firpm'] );   
    text( 1.5, 0.5, ['{\rm measured} {\delta_s}=',num2str( abs(min(Af)) ),' < {\rm given} {\delta_s}=',num2str( abs(min(deltas)) )] );
    grid;
    hold off;
    datacursormode(AR_f,'on');
    
% Too lazy to make filter meet spec, changing order didn't help wtf;
% changing stopband tolerance didn't work either; using a larger tolerance
% didnt work;

% **Note from q9b, using the firpm made a filter that didn't meet the
% design specs, might have to do more manual calcs

% jk using manual calcs has right stopband tolerance but wrong passband
% using firpm has wrong stopband tolerance but right passband

% final update, use hand calculations to fix stopband and increase order to fix passband 

%% Q8 via fsord
close all
clc
clear all;
% A filter has the following specifications: a passband from 200 Hz to 500 Hz, a transition width of 50
% Hz, 0.1 dB pass band ripple, 60 dB stop band attuenuation and a sampling rate of 2 kHz. 
% 
% Design a filter that meets the above specifications using the Kaiser window design approach. 
% 
% Does the filter meet spec? If not, make the necessary modifications to meet spec. 
% 
% Write a MATLAB program that plots the magnitude response in dB of the filter as a function of frequency with units Hz. 
% 
% Use the MATLAB function fir1() to calculate the impulse response for the filter. Appropriately label the
% plots. Publish your m-file as a pdf document with suitable section headings.

% "a passband from 200 Hz to 500 Hz" sounds like its a BPF
    fs = 2000;  %sampling frequency of 2 kHz
    f1 = 200;   %units of Hz; lower passband frequency; EE365 units conversion, assume sampling frequency has units samples/second
    f2 = 500;    %upper passband frequency
    
% transition width
    tw = 50*2*pi; % Hz; converted to rads/sec
    
% Gain in bands
    Gs = 0;
    Gp = 1;
    
% Calculate corner frequencies for passband; f_corner*2*pi + transition
% width

    %lower corners
%     ws1 = f1*2*pi - tw;
%     wp1 = f1*2*pi + tw;
% These values make more sense for me since trans width is from stopband to
% passband & vice versa
    ws1 = f1*2*pi - tw;
    wp1 = f1*2*pi;

    %upper corners; note polarity of transition width when summing to find
    %corner frequency; 
%     ws2 = f2*2*pi + tw; % for upper frequency, stopband should have a higher f than passband
%     wp2 = f2*2*pi - tw; 
    %
    ws2 = f2*2*pi + tw; 
    wp2 = f2*2*pi;
    
    %cutoff frequency
    wc1 = (ws1+wp1)/2;  %lower fc
    wc2 = (ws2+wp2)/2;  %upper fc

% stopband attenuation
    As = 60; % dB

% passband ripple
    Ap = 0.1; % linear units
    
% ** This step might not be needed; good to know **
% % find ripple tolerance, delta. Note windowing involves using the worst case ripple tolerance 
%     % stopband attenuation should be negative to represent a loss in gain
    deltas = 10^(-As/20);
% 
%     % passband ripple should vary by +/-0.1 dB thus we need to subtract by
%     % a linear unit of 1 since gain in passband should be 1 and we want
%     % ONLY the tolerance; convert passband attenuation to linear unit, then
%     % sub 1; multiplying Ap by +/-1 doesn't matter
    deltap = 10^(Ap/20) - 1;
    
%convert deviation to linear units
%     dev = [(10^(rp/20)-1)/(10^(rp/20)+1)  10^(-rs/20)]; 
    dev = [deltas (deltap)/(deltap+2) (deltap)/(deltap+2)  deltas]; 
    
% Given fs = 2000;
    M = firpmord([0 ws1 wp1 ws2 wp2 pi]/2/pi, [Gs Gp Gp Gs],  dev, fs);
% window shape, beta
    beta = 0.1102*(As-8.7);
    
% create IR for this BPF w/kaiser via fir1(); parameters of fir1() are
% the same as firls; slide 138-140 for details
    h = fir1( M, [wc1/pi/fs wc2/pi/fs],'bandpass',kaiser(M+1,beta) );
    
    % Note that vector fb containing our corner frequencies has units
    % between 0 & 1 since Matlab normalizes analog frequencies by Fs/2
    % istead of Fs
    
% calculate frequency response of filter
    [H, w] = freqz(h,1,[0:0.01:pi]);
    
% Magnitude Response plot
    mr = figure(1);
%     plot( w/2/pi, 20*log10(abs(H)) );
    plot( w/2/pi, abs(H) );
    title('BPF Magnitude Response via kaiser window & fir1()');
    ylabel('20log( |H(e^{j\omega})| )');
    xlabel('f (samples/second)');
    grid;
    datacursormode(mr,'on');