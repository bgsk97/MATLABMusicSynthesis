% [Brian Kim]
% [ECE280-07L]
% Matlab Code to Play A-Ha - Take on Me

%% Initialize workspace
clear;

%% Define starting variables
fs = 8000; % Sampling frequency
t = @(d) 0:1/fs:(d*0.5)-1/fs;   % Creates time vector of desired duration in seconds 
                                % Multiplies duration by 0.5 to define lengths in terms of beats

%% Generate Initial Set of Notes
R = NoteFreqGen(12,220); % Calls NoteFreqGen to create 220-440 Octave Notes
A = R(1);
AS = R(2);
B = R(3);
C = R(4);
CS = R(5);
D = R(6);
DS = R(7);
E = R(8);
F = R(9);
FS = R(10);
G = R(11);
GS = R(12);

nr = @(o,d,f) cos(2*pi*SetOctave(o)*f*t(d));  % o = octave, d = duration of note, f =note frequency 
                                              % to keep coding note durations simpler (not an enhancement)
                                              
%% Instrument Synthesis Enhancement    
Xyl = @(o,d,f) (1*exp(-t(d)/0.1)).*cos((2*pi*((SetOctave(o)*f)*1.4)*t(d))+... %% Frequency Modulation
    ((1*exp(-t(d)/0.1).*cos(2*pi*((SetOctave(o)*f)*0.7)*t(d)))));              % Xylophone sound (not used in final song)
nis = @(o,d,f) (1*exp(-t(d)/4)).*cos((2*pi*((SetOctave(o)*f)*1)*t(d))+... %% Frequency Modulation
    ((1*exp(-t(d)/4).*cos(2*pi*((SetOctave(o)*f)*0.5)*t(d)))));              % Regular note sound

%% Harmonics Enhancement
nh = @(o,d,f) (nis(o,d,f) + 0.8*nis(o,d,1.5*f) + 0.6*nis(o,d,2*f) + 0.3*nis(o,d,2.5*f))... % Added harmonics
    ./max(nis(o,d,f) + 0.8*nis(o,d,1.5*f) + 0.6*nis(o,d,2*f) + 0.3*nis(o,d,2.5*f));        % Normalize Amplitude
nh1 = @(o,d,f) (Xyl(o,d,f) + 0.8*Xyl(o,d,2*f) + 0.6*Xyl(o,d,3*f))...        % Harmonics using Xylophone tone (not used in final song)
    ./max((Xyl(o,d,f) + 0.8*Xyl(o,d,2*f) + 0.6*Xyl(o,d,3*f)));
nheven = @(o,d,f) (0.8*nis(o,d,2*f) + 0.6*nis(o,d,4*f))...                  % Even harmonics only
    ./max(0.8*nis(o,d,2*f) + 0.6*nis(o,d,4*f)); 
nhodd = @(o,d,f) (nis(o,d,f) + 0.8*nis(o,d,3*f) + 0.6*nis(o,d,5*f))...      % Odd harmonics only
    ./max(nis(o,d,f) + 0.8*nis(o,d,3*f) + 0.6*nis(o,d,5*f)); 

%% Create function for rests
r = @(r) zeros(1,r*(fs*2)); % r = 0.125 (eigth rest), 0.25 (quarter rest), 0.5 (half rest), 1 (whole rest)
                            % Multiply sampling freq by 2 to match the dimensions of vector
                            
%% Volume Variation Enhancement - ADSR
ta= 0.2;
td= 0.3;
ts= 0.7;
tr= 1;

gf = 5; % Exp growth factor (Attack Phase)
sl = -2; % Slope of Line (Decay Phase)
df = -3.24; % Exp decay factor (Release Phase) -3.24

at = @(d) exp(gf.*t(d)); % Attack Phase (exp growth)
dt = @(d) sl*(t(d)-(ta*max(t(d))))+exp(gf*(ta*max(t(d)))); % Delay Phase (linear decay)                                                       
st = @(d) sl*((td*max(t(d)))-(ta*max(t(d))))+exp(gf*(ta*max(t(d)))); % Sustain Phase (constant)
rt = @(d) (exp(df.*(t(d)-(ts*max(t(d)))))).*(sl*((td*max(t(d)))-(ta*max(t(d))))+exp(gf*(ta*max(t(d))))); % Release Phase (exp decay)
% Above functions include addition of y intercepts based on the previous phase point value and phase shifts in t(d)
% so that the piecewise functions are smoothly connected for ADSR

va = @(d) (t(d)>=0&t(d)<ta*max(t(d))).*at(d);
vd = @(d) (t(d)>=max(t(d))*ta&t(d)<td*max(t(d))).*dt(d);
vs = @(d) (t(d)>=max(t(d))*td&t(d)<ts*max(t(d))).*st(d);
vr = @(d) (t(d)>=max(t(d))*ts&t(d)<=tr*max(t(d))).*rt(d);

va1 = @(d) va(d)/max(va(d));
vd1 = @(d) vd(d)/max(va(d));
vs1 = @(d) vs(d)/max(va(d));
vr1 = @(d) vr(d)/max(va(d));
% Divide by max amp to normalize amplitude between -1 and 1

n = @(o,d,f) (va1(d) + vd1(d) + vs1(d) + vr1(d)).*(nh(o,d,f)/max(nh(o,d,f)));
n1 = @(o,d,f) (va1(d) + vd1(d) + vs1(d) + vr1(d)).*(nh1(o,d,f)/max(nh1(o,d,f)));

% Test ADSR
figure(1);
clf;
plot(t(2),va1(2)+vd1(2)+vs1(2)+vr1(2)) % Test ADSR Envelope
xlabel('Time (s)')         
ylabel('Amplitude')
title('ADSR Envelope')
figure(2);
clf;
subplot(1,2,1) 
plot(t(2),nh(1,2,A)) % Raw Note A Plot
xlabel('Time (s)')         
ylabel('Amplitude')
title('Note A Amplitude vs. Time')
subplot(1,2,2) 
plot(t(2),n(1,2,A))  % Note A with ADSR envelope
xlabel('Time (s)')         
ylabel('Amplitude')
title('ADSR Enveloped Note A Amplitude vs. Time')
figure(3); % Even and Odd only harmonics test
clf;
subplot(1,2,1) 
plot(t(2),nheven(1,2,A)) 
xlabel('Time (s)')         
ylabel('Amplitude')
title('Even Harmonics Only of Note A')
subplot(1,2,2) 
plot(t(2),nhodd(1,2,A)) 
xlabel('Time (s)')         
ylabel('Amplitude')
title('Odd Harmonics Only of Note A')
axis([0 1 -1 1]);

%% Echo/Reverb Enhancement
ec = @(o,d,f) Echo(n(o,d,f)); % Calls Echo function to put time delays w/ volume attenuation over time
xy = @(o,d,f) Echo(n1(o,d,f));

%% Main Piano
M1 = [ec(1,0.5,FS) ec(1,0.5,FS) ec(1,0.5,D) ec(1,0.5,B) r(0.125) ec(1,0.5,B) r(0.125) ec(1,0.5,E)... % 0th octave set to 1
    r(0.125) ec(1,0.5,E) r(0.125) ec(1,0.5,E) ec(1,0.5,GS) ec(1,0.5,GS) ec(2,0.5,A) ec(2,0.5,B)...
    ec(2,0.5,A) ec(2,0.5,A) ec(2,0.5,A) ec(1,0.5,E) r(0.125) ec(1,0.5,D) r(0.125) ec(1,0.5,FS)...
    r(0.125) ec(1,0.5,FS) r(0.125) ec(1,0.5,FS) ec(1,0.5,E) ec(1,0.5,E) ec(1,0.5,FS) ec(1,0.5,E)];
M2 = [ec(1,1.5,D) ec(1,0.5,D) r(0.125) ec(1,0.5,CS) ec(1,1,B)...
    r(1)...
    ec(1,0.5,CS) ec(1,0.5,CS) r(0.125) ec(1,0.5,CS) r(0.125) ec(1,0.5,A) r(0.25)...
    r(0.125) ec(1,0.5,FS) r(0.125) ec(1,0.5,FS) ec(1,1,FS) ec(1,1,E)];
M3 = [ec(1,1.5,D) ec(1,0.5,D) ec(1,0.5,D) ec(1,0.5,CS) r(0.125) ec(1,0.5,B)...
    r(0.5) r(0.25) r(0.125) ec(1,0.5,B)...
    ec(1,1,CS) ec(1,0.5,D) ec(1,0.5,CS) r(0.125) ec(1,0.5,B) r(0.125) ec(1,0.5,A)...
    r(0.125) ec(1,0.5,B) r(0.125) ec(1,0.5,CS) ec(1,1,B) ec(1,1,A)];
M4 = [r(0.25) ec(1,1,D) ec(1,1,D) ec(1,0.5,D) ec(1,0.5,D)...
    r(1)...
    r(0.25) ec(1,0.5,A) ec(1,0.5,A) ec(1,0.5,A) ec(1,0.5,A) ec(1,0.5,A) ec(1,0.5,A)...
    ec(1,0.5,A) ec(0,0.5,GS) r(0.25) ec(0,0.5,GS) ec(0,0.5,FS) r(0.25)...
    (nh(0,4,CS)+nh(1,4,A))./max((nh(0,4,CS)+nh(1,4,A)))]; % Divide by max to normalize amplitude btw -1 and 1
M5 = [(nh(1,4,GS)+nh(1,4,E)+nh(1,4,B))/max((nh(1,4,GS)+nh(1,4,E)+nh(1,4,B)))...
    (nh(2,4,A)+nh(1,4,FS)+nh(1,4,CS))/max((nh(2,4,A)+nh(1,4,FS)+nh(1,4,CS)))...
    (ec(1,1,D)+ec(1,1,A)+ec(1,1,E))/max((ec(1,1,D)+ec(1,1,A)+ec(1,1,E))) r(0.125)...
    (ec(1,0.5,FS)+ec(1,0.5,D)+ec(1,0.5,A))/max((ec(1,0.5,FS)+ec(1,0.5,D)+ec(1,0.5,A))) r(0.25)...
    (ec(1,1,D)+ec(1,1,A)+ec(1,1,E))/max((ec(1,1,D)+ec(1,1,A)+ec(1,1,E)))...
    (nh(2,4,A)+nh(1,4,E)+nh(1,4,CS))/max((nh(2,4,A)+nh(1,4,E)+nh(1,4,CS)))...
    (nh(1,4,GS)+nh(2,4,B)+nh(2,4,E))/max((nh(1,4,GS)+nh(2,4,B)+nh(2,4,E)))];
M6 = [(nh(2,4,A)+nh(2,4,FS)+nh(2,4,CS))/max((nh(2,4,A)+nh(2,4,FS)+nh(2,4,CS)))...
    (ec(1,1,D)+ec(1,1,A)+ec(1,1,E))/max((ec(1,1,D)+ec(1,1,A)+ec(1,1,E))) r(0.125)...
    (ec(1,0.5,FS)+ec(1,0.5,D)+ec(1,0.5,A))/max((ec(1,0.5,FS)+ec(1,0.5,D)+ec(1,0.5,A))) r(0.25)...
    (ec(1,1,D)+ec(1,1,A)+ec(1,1,E))/max((ec(1,1,D)+ec(1,1,A)+ec(1,1,E)))...
    (nh(1,4,E)+nh(2,4,A)+nh(2,4,CS))/max((nh(1,4,E)+nh(2,4,A)+nh(2,4,CS)))...
    (nh(2,4,B)+nh(2,4,E)+nh(2,4,GS))/max((nh(2,4,B)+nh(2,4,E)+nh(2,4,GS)))];
M7 = [(nh(2,4,CS)+nh(2,4,FS)+nh(3,4,A))/max((nh(2,4,CS)+nh(2,4,FS)+nh(3,4,A)))...
    r(0.25) (ec(2,0.5,GS)+ec(3,0.5,B))./max((ec(2,0.5,GS)+ec(3,0.5,B)))...
    (ec(3,0.5,A)+ec(3,0.5,CS))./max((ec(3,0.5,A)+ec(3,0.5,CS)))...
    (ec(3,0.5,A)+ec(3,0.5,CS))./max((ec(3,0.5,A)+ec(3,0.5,CS)))...
    (ec(2,0.5,GS)+ec(3,0.5,B))./max((ec(2,0.5,GS)+ec(3,0.5,B)))...
    (ec(2,1,FS)+ec(3,1,A))./max((ec(2,1,FS)+ec(3,1,A))) r(0.25)...
    (nh(3,3,A)+nh(3,3,CS)+nh(3,3,E))/max((nh(3,3,A)+nh(3,3,CS)+nh(3,3,E)))...
    (nh(1,4,GS)+nh(1,4,E)+nh(1,4,B))/max((nh(1,4,GS)+nh(1,4,E)+nh(1,4,B)))...
    (nh(1,4,FS)+nh(1,4,D)+nh(1,4,A))/max((nh(1,4,FS)+nh(1,4,D)+nh(1,4,A)))];
M8 = [(ec(1,2,E)+ec(1,2,GS)+ec(1,2,B))/max((ec(1,2,E)+ec(1,2,GS)+ec(1,2,B))) r(0.125) ec(1,1.5,E)...
    ec(1,1.5,D) ec(1,0.5,D) r(0.125) ec(1,0.5,CS) ec(1,1,B)...
    r(0.5) r(0.25) r(0.125) ec(1,0.5,B)...
    ec(1,1,CS) ec(1,0.5,D) ec(1,0.5,CS) r(0.125) ec(1,0.5,B) ec(1,1,A)...
    r(0.125) ec(1,0.5,FS) ec(1,1,FS) ec(1,1,FS) ec(1,1,E)...
    ec(1,2,D) ec(1,0.5,D) ec(1,1,CS) ec(1,0.5,B)...
    r(1)...
    ec(1,1,CS) ec(1,0.5,D) ec(1,0.5,CS) ec(1,0.5,CS) ec(1,0.5,B) ec(1,0.5,A) ec(1,0.5,A)...
    ec(1,0.5,A) ec(1,0.5,B) ec(1,1,CS) ec(1,1,B) ec(1,1,A)...
    ec(1,1,D) ec(1,0.5,D) ec(1,0.5,D) ec(1,0.5,D) ec(1,0.5,D) ec(1,1,D)...
    ec(1,1,D) r(0.25) r(0.5)...
    r(0.25) ec(1,0.5,A) ec(1,0.5,A) ec(1,0.5,A) ec(1,0.5,A) ec(1,0.5,A) ec(1,0.5,A)...
    ec(1,1,A) ec(0,0.5,GS) ec(0,0.5,GS) ec(0,0.5,GS) ec(0,0.5,FS) r(0.25)...
    (nh(0,4,CS)+nh(1,4,A))./max((nh(0,4,CS)+nh(1,4,A)))... % line 52
    (nh(1,4,E)+nh(1,4,GS)+nh(1,4,B))/max((nh(1,4,E)+nh(1,4,GS)+nh(1,4,B)))...
    (nh(1,4,CS)+nh(1,4,FS)+nh(2,4,A))/max((nh(1,4,CS)+nh(1,4,FS)+nh(2,4,A)))...
    (ec(1,1,D)+ec(1,1,A)+ec(1,1,E))/max((ec(1,1,D)+ec(1,1,A)+ec(1,1,E))) r(0.125)...
    (ec(1,0.5,FS)+ec(1,0.5,D)+ec(1,0.5,A))/max((ec(1,0.5,FS)+ec(1,0.5,D)+ec(1,0.5,A))) r(0.25)...
    (ec(1,1,D)+ec(1,1,A)+ec(1,1,E))/max((ec(1,1,D)+ec(1,1,A)+ec(1,1,E)))...
    (nh(2,4,A)+nh(1,4,E)+nh(1,4,CS))/max((nh(2,4,A)+nh(1,4,E)+nh(1,4,CS)))...
    (nh(1,4,GS)+nh(2,4,B)+nh(2,4,E))/max((nh(1,4,GS)+nh(2,4,B)+nh(2,4,E)))...
    (nh(2,4,A)+nh(2,4,FS)+nh(2,4,CS))/max((nh(2,4,A)+nh(2,4,FS)+nh(2,4,CS)))...
    (ec(1,1,D)+ec(1,1,A)+ec(1,1,E))/max((ec(1,1,D)+ec(1,1,A)+ec(1,1,E))) r(0.125)...
    (ec(1,0.5,FS)+ec(1,0.5,D)+ec(1,0.5,A))/max((ec(1,0.5,FS)+ec(1,0.5,D)+ec(1,0.5,A))) r(0.25)...
    (ec(1,1,D)+ec(1,1,A)+ec(1,1,E))/max((ec(1,1,D)+ec(1,1,A)+ec(1,1,E)))...
    (nh(1,4,E)+nh(2,4,A)+nh(2,4,CS))/max((nh(1,4,E)+nh(2,4,A)+nh(2,4,CS)))];    
M9 = [(nh(2,4,B)+nh(2,4,E)+nh(2,4,GS))/max((nh(2,4,B)+nh(2,4,E)+nh(2,4,GS)))...
    (nh(2,4,CS)+nh(2,4,FS)+nh(3,4,A))/max((nh(2,4,CS)+nh(2,4,FS)+nh(3,4,A)))...
    r(0.25) (ec(2,0.5,GS)+ec(3,0.5,B))./max((ec(2,0.5,GS)+ec(3,0.5,B)))...
    (ec(3,0.5,A)+ec(3,0.5,CS))./max((ec(3,0.5,A)+ec(3,0.5,CS)))...
    (ec(3,0.5,A)+ec(3,0.5,CS))./max((ec(3,0.5,A)+ec(3,0.5,CS)))...
    (ec(2,0.5,GS)+ec(3,0.5,B))./max((ec(2,0.5,GS)+ec(3,0.5,B)))...
    (ec(2,1,FS)+ec(3,1,A))./max((ec(2,1,FS)+ec(3,1,A))) r(0.25)...
    (nh(3,3,A)+nh(3,3,CS)+nh(3,3,E))/max((nh(3,3,A)+nh(3,3,CS)+nh(3,3,E)))...
    (nh(1,4,GS)+nh(1,4,E)+nh(1,4,B))/max((nh(1,4,GS)+nh(1,4,E)+nh(1,4,B)))...
    (nh(1,4,FS)+nh(1,4,D)+nh(1,4,A))/max((nh(1,4,FS)+nh(1,4,D)+nh(1,4,A)))...
    (nh(1,4,GS)+nh(1,4,E)+nh(1,4,B))/max((nh(1,4,GS)+nh(1,4,E)+nh(1,4,B)))...
    (nh(2,4,CS)+nh(2,4,E)+nh(2,4,GS))/max((nh(2,4,CS)+nh(2,4,E)+nh(2,4,GS)))...
    (nh(2,4,CS)+nh(2,4,E)+nh(2,4,GS))/max((nh(2,4,CS)+nh(2,4,E)+nh(2,4,GS)))...
    (nh(1,4,GS)+nh(2,4,B)+nh(1,4,D))/max((nh(1,4,GS)+nh(2,4,B)+nh(1,4,D)))...
    (nh(1,4,GS)+nh(2,4,B)+nh(1,4,D))/max((nh(1,4,GS)+nh(2,4,B)+nh(1,4,D)))...
    (nh(2,4,CS)+nh(2,4,E)+nh(2,4,GS))/max((nh(2,4,CS)+nh(2,4,E)+nh(2,4,GS)))...
    (nh(2,4,CS)+nh(2,4,E)+nh(2,4,GS))/max((nh(2,4,CS)+nh(2,4,E)+nh(2,4,GS)))...
    (nh(1,4,GS)+nh(2,4,B)+nh(1,4,D))/max((nh(1,4,GS)+nh(2,4,B)+nh(1,4,D)))...
    (ec(1,2,GS)+ec(2,2,B)+ec(1,2,D))/max((ec(1,2,GS)+ec(2,2,B)+ec(1,2,D)))...
    (ec(2,2,A)+ec(2,2,CS))/max((ec(2,2,A)+ec(2,2,CS)))...
    (ec(2,0.5,A)+ec(2,0.5,CS))/max((ec(2,0.5,A)+ec(2,0.5,CS)))... 
    (nh(2,3.5,B)+nh(2,3.5,D))/max((nh(2,3.5,B)+nh(2,3.5,D)))...
    (ec(2,2,B)+ec(2,2,D))/max((ec(2,2,B)+ec(2,2,D)))...
    (ec(1,2,FS)+ec(2,2,A))/max((ec(1,2,FS)+ec(2,2,A)))...
    (ec(1,0.5,FS)+ec(2,0.5,A))/max((ec(1,0.5,FS)+ec(2,0.5,A)))... % line 79
    (ec(1,1.5,GS)+ec(2,1.5,B))/max((ec(1,1.5,GS)+ec(2,1.5,B)))...
    (ec(1,2,GS)+ec(2,2,B))/max((ec(1,2,GS)+ec(2,2,B)))...
    (nh(1,4,GS)+nh(2,4,B))/max((nh(1,4,GS)+nh(2,4,B)))...
    ec(2,0.5,FS) ec(2,0.5,FS) ec(2,0.5,D) ec(2,0.5,B) r(0.125) ec(2,0.5,B) r(0.125) ec(2,0.5,E)...
    r(0.125) ec(2,0.5,E) r(0.125) ec(2,0.5,E) ec(2,0.5,GS) ec(2,0.5,GS) ec(3,0.5,A) ec(3,0.5,B)...
    ec(2,0.5,FS) ec(2,0.5,FS) ec(2,0.5,D) ec(2,0.5,B) r(0.125) ec(2,0.5,B) r(0.125) ec(2,0.5,E)...
    r(0.125) ec(2,0.5,E) r(0.125) ec(2,0.5,E) ec(2,0.5,GS) ec(2,0.5,GS) ec(3,0.5,A) ec(3,0.5,B)...
    ec(2,0.5,FS) ec(2,0.5,FS) ec(2,0.5,D) ec(2,0.5,B) r(0.125) ec(2,0.5,B) r(0.125) ec(2,0.5,E)...
    r(0.125) ec(2,0.5,E) r(0.125) ec(2,0.5,E) ec(2,0.5,GS) ec(2,0.5,GS) ec(3,0.5,A) ec(3,0.5,B)];
M10 = [ec(3,0.5,A) ec(3,0.5,A) ec(3,0.5,A) ec(2,0.5,E) r(0.125) ec(2,0.5,D) r(0.125) ec(2,0.5,FS)...
    r(0.125) ec(2,0.5,FS) r(0.125) ec(2,0.5,FS) ec(2,0.5,E) ec(2,0.5,E) ec(2,0.5,FS) ec(2,0.5,E)...
    ec(2,0.5,FS) ec(2,0.5,FS) ec(2,0.5,D) ec(2,0.5,B) r(0.125) ec(2,0.5,B) r(0.125) ec(2,0.5,E)...
    r(0.125) ec(2,0.5,E) r(0.125) ec(2,0.5,E) ec(2,0.5,GS) ec(2,0.5,GS) ec(3,0.5,A) ec(3,0.5,B)...
    ec(3,0.5,A) ec(3,0.5,A) ec(3,0.5,A) ec(2,0.5,E) r(0.125) ec(2,0.5,D) r(0.125) ec(2,0.5,FS)...
    r(0.125) ec(2,0.5,FS) r(0.125) ec(2,0.5,FS) ec(2,0.5,E) ec(2,0.5,E) ec(2,0.5,FS) ec(2,0.5,E)...
    ec(2,0.5,FS) ec(2,0.5,FS) ec(2,0.5,D) ec(2,0.5,B) r(0.125) ec(2,0.5,B) r(0.125) ec(2,0.5,E)...
    r(0.125) ec(2,0.5,E) r(0.125) ec(2,0.5,E) ec(2,0.5,GS) ec(2,0.5,GS) ec(3,0.5,A) ec(3,0.5,B)...
    ec(3,0.5,A) ec(3,0.5,A) ec(3,0.5,A) ec(2,0.5,FS) r(0.125) ec(2,0.5,D) r(0.125) ec(2,0.5,FS)...
    r(0.125) ec(2,0.5,FS) r(0.125) ec(2,0.5,FS) ec(2,1,E) r(0.25)...
    ec(1,1.5,D) ec(1,0.5,E) r(0.125) ec(1,0.5,FS) ec(1,1,E)...
    ec(1,2,E) ec(1,0.5,E) ec(1,1.5,D)...
    ec(1,1,CS) ec(1,0.5,D) ec(1,0.5,CS) r(0.125) ec(1,1.5,A)... % line 99
    r(0.125) ec(1,0.5,FS) r(0.125) ec(1,0.5,FS) ec(1,1,FS) ec(1,1,E)...
    ec(1,1.5,D) ec(1,0.5,D) ec(1,0.5,D) ec(1,0.5,CS) ec(1,1,B)...
    ec(1,2,B) r(0.25) r(0.125) ec(1,0.5,A)...
    ec(1,1,CS) ec(1,0.5,D) ec(1,0.5,CS) ec(1,0.5,CS) ec(1,0.5,B) r(0.125) ec(1,0.5,A)...
    ec(1,0.5,A) ec(1,0.5,B) r(0.125) ec(1,0.5,CS) ec(1,1,B) ec(1,1,A)...
    r(0.25) r(0.125) ec(1,0.5,D) ec(1,0.5,D) ec(1,0.5,D) ec(1,0.5,D) ec(1,0.5,D)...
    ec(1,1,D) r(0.25) r(0.5)...
    r(0.25) ec(1,0.5,A) ec(1,0.5,A) ec(1,0.5,A) ec(1,0.5,A) ec(1,0.5,A) ec(1,0.5,A)...
    ec(1,0.5,A) ec(0,0.5,GS) ec(0,0.5,GS) ec(0,0.5,GS) ec(0,0.5,GS) ec(0,1.5,FS)...
    (nh(0,4,CS)+nh(1,4,A))/max((nh(0,4,CS)+nh(1,4,A)))...
    (nh(1,4,E)+nh(1,4,GS)+nh(1,4,B))/max((nh(1,4,E)+nh(1,4,GS)+nh(1,4,B)))...
    (nh(1,4,FS)+nh(2,4,A)+nh(1,4,CS))/max((nh(1,4,FS)+nh(2,4,A)+nh(1,4,CS)))...
    (ec(1,1,D)+ec(1,1,A)+ec(1,1,E))/max((ec(1,1,D)+ec(1,1,A)+ec(1,1,E))) r(0.125)...
    (ec(1,0.5,FS)+ec(1,0.5,D)+ec(1,0.5,A))/max((ec(1,0.5,FS)+ec(1,0.5,D)+ec(1,0.5,A))) r(0.25)...
    (ec(1,1,D)+ec(1,1,A)+ec(1,1,E))/max((ec(1,1,D)+ec(1,1,A)+ec(1,1,E)))];
M11 = [(nh(2,4,A)+nh(1,4,E)+nh(1,4,CS))/max((nh(2,4,A)+nh(1,4,E)+nh(1,4,CS)))...
    (nh(1,4,GS)+nh(2,4,B)+nh(2,4,E))/max((nh(1,4,GS)+nh(2,4,B)+nh(2,4,E)))...
    (nh(2,4,A)+nh(2,4,FS)+nh(2,4,CS))/max((nh(2,4,A)+nh(2,4,FS)+nh(2,4,CS)))...
    (ec(1,1,D)+ec(1,1,A)+ec(1,1,E))/max((ec(1,1,D)+ec(1,1,A)+ec(1,1,E))) r(0.125)...
    (ec(1,0.5,FS)+ec(1,0.5,D)+ec(1,0.5,A))/max((ec(1,0.5,FS)+ec(1,0.5,D)+ec(1,0.5,A))) r(0.25)...
    (ec(1,1,D)+ec(1,1,A)+ec(1,1,E))/max((ec(1,1,D)+ec(1,1,A)+ec(1,1,E)))...
    (nh(1,4,E)+nh(2,4,A)+nh(2,4,CS))/max((nh(1,4,E)+nh(2,4,A)+nh(2,4,CS)))...
    (nh(2,4,B)+nh(2,4,E)+nh(2,4,GS))/max((nh(2,4,B)+nh(2,4,E)+nh(2,4,GS)))...
    (nh(2,4,CS)+nh(2,4,FS)+nh(3,4,A))/max((nh(2,4,CS)+nh(2,4,FS)+nh(3,4,A)))...
    r(0.5) (ec(2,0.5,FS)+ec(2,0.5,D))/max((ec(2,0.5,FS)+ec(2,0.5,D)))...
    (ec(2,1.5,E)+ec(2,1.5,GS))/max((ec(2,1.5,E)+ec(2,1.5,GS)))...
    r(0.25) (nh(3,3,A)+nh(3,3,CS)+nh(3,3,E))/max((nh(3,3,A)+nh(3,3,CS)+nh(3,3,E)))...
    (nh(1,4,E)+nh(1,4,GS)+nh(1,4,B))/max((nh(1,4,E)+nh(1,4,GS)+nh(1,4,B)))...
    (nh(2,4,A)+nh(1,4,FS)+nh(1,4,CS))/max((nh(2,4,A)+nh(1,4,FS)+nh(1,4,CS)))... % line 123
    (ec(1,1,D)+ec(1,1,A)+ec(1,1,E))/max((ec(1,1,D)+ec(1,1,A)+ec(1,1,E))) r(0.125)...
    (ec(1,0.5,FS)+ec(1,0.5,D)+ec(1,0.5,A))/max((ec(1,0.5,FS)+ec(1,0.5,D)+ec(1,0.5,A))) r(0.25)...
    (ec(1,1,D)+ec(1,1,A)+ec(1,1,E))/max((ec(1,1,D)+ec(1,1,A)+ec(1,1,E)))...
    (nh(2,4,A)+nh(1,4,E)+nh(1,4,CS))/max((nh(2,4,A)+nh(1,4,E)+nh(1,4,CS)))...
    (nh(1,4,GS)+nh(2,4,B)+nh(2,4,E))/max((nh(1,4,GS)+nh(2,4,B)+nh(2,4,E)))...
    (nh(2,4,A)+nh(2,4,FS)+nh(2,4,CS))/max((nh(2,4,A)+nh(2,4,FS)+nh(2,4,CS)))...
    (ec(1,1,D)+ec(1,1,A)+ec(1,1,E))/max((ec(1,1,D)+ec(1,1,A)+ec(1,1,E))) r(0.125)...
    (ec(1,0.5,FS)+ec(1,0.5,D)+ec(1,0.5,A))/max((ec(1,0.5,FS)+ec(1,0.5,D)+ec(1,0.5,A))) r(0.25)...
    (ec(1,1,D)+ec(1,1,A)+ec(1,1,E))/max((ec(1,1,D)+ec(1,1,A)+ec(1,1,E)))...
    (nh(1,4,E)+nh(2,4,A)+nh(2,4,CS))/max((nh(1,4,E)+nh(2,4,A)+nh(2,4,CS)))...
    (nh(2,4,B)+nh(2,4,E)+nh(2,4,GS))/max((nh(2,4,B)+nh(2,4,E)+nh(2,4,GS)))...
    (nh(2,4,CS)+nh(2,4,FS)+nh(3,4,A))/max((nh(2,4,CS)+nh(2,4,FS)+nh(3,4,A)))...
    r(0.5) (ec(2,0.5,E)+ec(2,0.5,CS))/max((ec(2,0.5,E)+ec(2,0.5,CS)))...
    (ec(2,1.5,E)+ec(2,1.5,CS))/max((ec(2,1.5,E)+ec(2,1.5,CS)))...
    r(0.25) (nh(3,3,A)+nh(3,3,CS)+nh(3,3,E))/max((nh(3,3,A)+nh(3,3,CS)+nh(3,3,E)))...% line 133
    (nh(1,4,GS)+nh(2,4,B)+nh(2,4,E))/max((nh(1,4,GS)+nh(2,4,B)+nh(2,4,E)))...
    (nh(2,4,A)+nh(2,4,FS)+nh(2,4,CS))/max((nh(2,4,A)+nh(2,4,FS)+nh(2,4,CS)))...
    (ec(1,1,D)+ec(1,1,A)+ec(1,1,E))/max((ec(1,1,D)+ec(1,1,A)+ec(1,1,E))) r(0.125)...
    (ec(1,0.5,FS)+ec(1,0.5,D)+ec(1,0.5,A))/max((ec(1,0.5,FS)+ec(1,0.5,D)+ec(1,0.5,A))) r(0.25)...
    (ec(1,1,D)+ec(1,1,A)+ec(1,1,E))/max((ec(1,1,D)+ec(1,1,A)+ec(1,1,E)))...
    (ec(1,4,CS)+ec(1,4,A))/max((ec(1,4,CS)+ec(1,4,A)))];

%% Bass (Overlapping Tones Enhancement)
M1S = [n(-1,1,B) n(0,1,B) r(0.125) n(-1,0.5,B) n(0,1,B)... % 0th octave set to -1
    n(-1,1,E) n(0,1,E) r(0.125) n(-1,0.5,E) n(0,1,E)...
    n(-1,1,A) n(0,1,A) r(0.125) n(-1,0.5,A) n(0,1,A)...
    n(-1,1,D) n(0,1,D) n(-1,1,D) n(0,1,D)];
M2S = [n(-1,1,B) n(0,1,B) r(0.125) n(-1,0.5,B) n(0,1,B)... % 0th octave set to -1
    n(-1,1,E) n(0,1,E) r(0.125) n(-1,0.5,E) n(0,1,E)...
    n(-1,1,B) n(0,1,B) r(0.125) n(-1,0.5,B) n(0,1,B)...
    n(-1,1,D) n(0,1,D) n(-1,1,D) n(0,1,D)];
M3S = [n(-1,1,B) n(0,1,B) r(0.125) n(-1,0.5,B) n(0,1,B)...
    n(-1,1,E) n(0,1,E) r(0.125) n(-1,0.5,E) n(0,1,E)...
    n(-1,1,FS) n(0,1,FS) r(0.125)  n(-1,0.5,FS) n(0,1,FS)...
    n(-1,1,D) n(0,1,D)  n(-1,1,D) n(0,1,D)...
    n(-1,1,A) n(0,1,A) n(-1,1,A) n(0,1,A)]; 
M4S = [n(-2,1,GS) n(-1,1,GS) n(-2,1,GS) n(-1,1,GS)...
    n(-2,1,FS) n(-1,1,FS) n(-2,1,FS) n(-1,1,FS)...
    n(0,1,D) n(-1,0.5,D) n(0,0.5,D) r(0.125) n(-1,0.5,D) n(0,1,D)...
    n(-1,1,A) n(0,1,A) n(-1,1,A) n(0,1,A)...
    n(-2,1,GS) n(-1,1,GS) n(-2,1,GS) n(-1,1,GS)];
M5S = [n(-2,1,FS) n(-1,1,FS) n(-2,1,FS) n(-1,1,FS)...
    n(0,1,D) n(-1,0.5,D) n(0,0.5,D) r(0.125) n(-1,0.5,D) n(0,1,D)...
    n(-1,0.5,A) n(-1,0.5,A) n(-1,0.5,A) r(0.125) n(0,1,A) r(0.125) n(-1,0.5,A)...
    n(-2,0.5,GS) n(-2,0.5,GS) n(-2,0.5,GS) r(0.125) n(-1,1,GS) r(0.125) n(-2,0.5,GS)];
M6S = [n(-2,0.5,FS) n(-2,0.5,FS) n(-2,0.5,FS) r(0.125) n(-1,1,FS) r(0.25)...
    (n(-2,4,D)+n(-1,4,D))./max((n(-2,4,D)+n(-1,4,D)))...
    n(-1,1,A) n(0,1,A) n(-1,1,A) n(0,1,A)...
    n(-2,1,GS) n(-1,1,GS) n(-2,1,GS) n(-1,1,GS)...
    n(-1,1,D) n(0,1,D)  n(-1,1,D) n(0,1,D)];
M7S = [n(-1,1,E)  n(0,1,E)  n(-1,1,E)  n(0,1,E)...
    n(-1,1,B) n(0,1,B) r(0.125) n(-1,0.5,B) n(0,1,B)...
    n(-1,1,E)  n(0,1,E) r(0.125)  n(-1,0.5,E)  n(0,1,E)...
    n(-1,1,A)  n(0,1,A) r(0.125)  n(-1,0.5,A)  n(0,1,A)...
    n(-1,1,D)  n(0,1,D)  n(-1,1,CS)  n(0,1,CS)...
    n(-1,1,B)  n(0,1,B) r(0.125)  n(-1,0.5,B)  n(0,1,B)...
    n(-1,1,E)  n(0,1,E) r(0.125)  n(-1,0.5,E)  n(0,1,E)...
    n(-1,1,A)  n(0,1,A) r(0.125)  n(-1,0.5,A)  n(0,1,A)...
    n(-1,1,D)  n(0,1,D) n(-1,1,CS)  n(0,1,CS)...
    n(-1,1,B)  n(0,1,B) r(0.125)  n(-1,0.5,B)  n(0,1,B)...
    n(-1,1,E)  n(0,1,E) r(0.125)  n(-1,0.5,E)  n(0,1,E)...
    n(-1,1,FS)  n(0,1,FS) r(0.125)  n(-1,0.5,FS)  n(0,1,FS)...
    n(-1,1,D)  n(0,1,D) n(-1,1,D)  n(0,1,D)...
    n(-1,1,A)  n(0,1,A) n(-1,1,A)  n(0,1,A)...
    n(-2,1,GS)  n(-1,1,GS) n(-2,1,GS)  n(-1,1,GS)...
    n(-2,1,FS)  n(-1,1,FS) n(-2,1,FS)  n(-1,1,FS)...
    n(0,1,D) n(-1,0.5,D) n(0,0.5,D) r(0.125) n(-1,0.5,D) n(0,1,D)...
    n(-1,1,A) n(0,1,A) n(-1,1,A) n(0,1,A)...
    n(-2,1,GS) n(-1,1,GS) n(-2,1,GS) n(-1,1,GS)...
    n(-2,1,FS) n(-1,1,FS) n(-2,1,FS) n(-1,1,FS)...
    n(-1,1,D) n(-2,0.5,D) n(-1,0.5,D) r(0.125) n(-2,0.5,D) n(-1,1,D)...
    n(-1,0.5,A) n(-1,0.5,A) n(-1,0.5,A) r(0.125) n(0,1,A) r(0.125) n(-1,0.5,A)];
M8S = [n(-2,0.5,GS) n(-2,0.5,GS) n(-2,0.5,GS) r(0.125) n(-1,1,GS) r(0.125) n(-2,0.5,GS)...
    n(-2,0.5,FS) n(-2,0.5,FS) n(-2,0.5,FS) r(0.125) n(-1,1,FS) r(0.25)...
    (n(-2,4,D)+n(-1,4,D))./max((n(-2,4,D)+n(-1,4,D)))...
    n(-1,1,A) n(0,1,A) n(-1,1,A) n(0,1,A)...
    n(-2,1,GS) n(-1,1,GS) n(-2,1,GS) n(-1,1,GS)...
    n(-2,1,D) n(-1,1,D)  n(-2,1,D) n(-1,1,D)...
    n(-2,1,E) n(-1,1,E)  n(-2,1,E) n(-1,1,E)...
    n(-1,1,CS) n(0,1,CS) r(0.125) n(-1,0.5,CS) n(0,1,CS)...
    n(-1,1,CS) n(0,1,CS) r(0.125) n(-1,0.5,CS) n(0,1,CS)...
    n(-2,1,GS) n(-1,1,GS) r(0.125) n(-2,0.5,GS) n(-1,1,GS)...
    n(-2,1,GS) n(-1,1,GS) r(0.125) n(-2,0.5,GS) n(-1,1,GS)...
    n(-1,1,CS) n(0,1,CS) r(0.125) n(-1,0.5,CS) n(0,1,CS)...
    n(-1,1,CS) n(0,1,CS) r(0.125) n(-1,0.5,CS) n(0,1,CS)...
    n(-2,1,GS) n(-1,1,GS) r(0.125) n(-2,0.5,GS) n(-1,1,GS)...
    n(-2,1,GS) n(-1,1,GS) r(0.125) n(-2,0.5,GS) n(-1,1,GS)...
    n(-1,1,B) n(0,1,B) r(0.125) n(-1,0.5,B) n(0,1,B)...
    n(-1,1,B) n(0,1,B) r(0.125) n(-1,0.5,B) n(0,1,B)...
    n(-1,1,E) n(0,1,E) r(0.125) n(-1,0.5,E) n(0,1,E)...
    n(-1,1,E) n(0,1,E) n(-1,1,E) n(0,1,E)...
    r(1)...
    r(1)...
    r(1)...
    r(1)...
    n(-1,1,B) n(0,1,B) r(0.125) n(-1,0.5,B) n(0,1,B)...
    n(-1,1,E) n(0,1,E) r(0.125) n(-1,0.5,E) n(0,1,E)];
M9S = [n(-1,1,A) n(0,1,A) r(0.125) n(-1,0.5,A) n(0,1,A)...
    n(-1,1,D) n(0,1,D) n(-1,1,CS) n(0,1,CS)...
    n(-1,1,B) n(0,1,B) r(0.125) n(-1,0.5,B) n(0,1,B)...
    n(-1,1,E) n(0,1,E) r(0.125) n(-1,0.5,E) n(0,1,E)...
    n(-1,1,A) n(0,1,A) r(0.125) n(-1,0.5,A) n(0,1,A)...
    n(-1,1,D) n(0,1,D) n(-1,1,CS) n(0,1,CS)...
    n(-1,1,B) n(0,1,B) r(0.125) n(-1,0.5,B) n(0,1,B)...
    n(-1,1,E) n(0,1,E) r(0.125) n(-1,0.5,E) n(0,1,E)...
    n(-1,1,B) n(0,1,B) r(0.125) n(-1,0.5,B) n(0,1,B)...
    n(-1,1,E) n(0,1,E) n(-1,1,E) n(0,1,E)...
    n(-1,1,B) n(0,1,B) r(0.125) n(-1,0.5,B) n(0,1,B)...
    n(-1,1,E) n(0,1,E) r(0.125) n(-1,0.5,E) n(0,1,E)...
    n(-1,1,A) n(0,1,A) r(0.125) n(-1,0.5,A) n(0,1,A)...
    n(-1,1,D) n(0,1,D) n(-1,1,CS) n(0,1,CS)...
    n(-1,1,B) n(0,1,B) r(0.125) n(-1,0.5,B) n(0,1,B)...
    n(-1,1,E) n(0,1,E) r(0.125) n(-1,0.5,E) n(0,1,E)...
    n(-1,1,A) n(0,1,A) r(0.125) n(-1,0.5,A) n(0,1,A)...
    n(-1,1,D) n(0,1,D) n(-1,1,CS) n(0,1,CS)...
    n(-1,1,B) n(0,1,B) r(0.125) n(-1,0.5,B) n(0,1,B)...
    n(-1,1,E) n(0,1,E) r(0.125) n(-1,0.5,E) n(0,1,E)...
    n(-1,1,FS) n(0,1,FS) r(0.125) n(-1,0.5,FS) n(0,1,FS)...
    n(-1,1,D) n(0,1,D) r(0.125) n(-1,0.5,D) n(0,1,D)...
    n(-1,1,A) n(0,1,A) n(-1,1,A) n(0,1,A)...
    n(-2,1,GS) n(-1,1,GS) n(-2,1,GS) n(-1,1,GS)...
    n(-2,1,FS) n(-1,1,FS) n(-2,1,FS) n(-1,1,FS)...
    n(0,1,D) n(-1,0.5,D) n(0,0.5,D) r(0.125) n(-1,0.5,D) n(0,1,D)];
M10S = [n(-1,1,A) n(0,1,A) n(-1,1,A) n(0,1,A)...
    n(-2,1,GS) n(-1,1,GS) n(-2,1,GS) n(-1,1,GS)...
    n(-2,1,FS) n(-1,1,FS) n(-2,1,FS) n(-1,1,FS)...
    n(0,1,D) n(-1,0.5,D) n(0,0.5,D) r(0.125) n(-1,0.5,D) n(0,1,D)...
    n(-1,0.5,A) n(-1,0.5,A) n(-1,0.5,A) r(0.125) n(0,1,A) r(0.125) n(-1,0.5,A)...
    n(-2,0.5,GS) n(-2,0.5,GS) n(-2,0.5,GS) r(0.125) n(-1,1,GS) r(0.125) n(-2,0.5,GS)...
    n(-2,0.5,FS) n(-2,0.5,FS) n(-2,0.5,FS) r(0.125) n(-1,1,FS) n(-2,1,FS)...
    (n(-2,4,D)+n(-1,4,D))./max((n(-2,4,D)+n(-1,4,D)))...
    n(-1,1,A) n(0,1,A) n(-1,1,A) n(0,1,A)...
    n(-2,1,GS) n(-1,1,GS) n(-2,1,GS) n(-1,1,GS)...
    n(-2,1,FS) n(-1,1,FS) n(-2,1,FS) n(-1,1,FS)... % line 123
    n(-1,1,D) n(-2,0.5,D) n(-1,0.5,D) r(0.125) n(-2,0.5,D) n(-1,1,D)...
    n(-1,1,A) n(0,1,A) n(-1,1,A) n(0,1,A)...
    n(-2,1,GS) n(-1,1,GS) n(-2,1,GS) n(-1,1,GS)...
    n(-2,1,FS) n(-1,1,FS) n(-2,1,FS) n(-1,1,FS)...
    n(-1,1,D) n(-2,0.5,D) n(-1,0.5,D) r(0.125) n(-2,0.5,D) n(-1,1,D)...
    n(-1,1,A) n(0,1,A) n(-1,1,A) n(0,1,A)...
    n(-2,1,GS) n(-1,1,GS) n(-2,1,GS) n(-1,1,GS)...
    n(-2,1,FS) n(-1,1,FS) n(-2,1,FS) n(-1,1,FS)...
    n(-2,1,D) n(-1,1,D) n(-2,1,D) n(-1,1,D)...
    n(-1,1,A) n(0,1,A) n(-1,1,A) n(0,1,A)...
    n(-2,1,GS) n(-1,1,GS) n(-2,1,GS) n(-1,1,GS)...
    n(-2,1,FS) n(-1,1,FS) n(-2,1,FS) n(-1,1,FS)...
    n(0,1,D) n(-1,0.5,D) n(0,0.5,D) r(0.125) n(-1,0.5,D) n(0,1,D)...
    (n(0,4,A)+n(-1,4,A))./max((n(0,4,A)+n(-1,4,A)))];

%% Even and Odd Harmonics Test
Even = [nheven(1,0.5,FS) nheven(1,0.5,FS) nheven(1,0.5,D) nheven(1,0.5,B) r(0.125) nheven(1,0.5,B) r(0.125) nheven(1,0.5,E)... % 0th octave set to 1
    r(0.125) nheven(1,0.5,E) r(0.125) nheven(1,0.5,E) nheven(1,0.5,GS) nheven(1,0.5,GS) nheven(2,0.5,A) nheven(2,0.5,B)...
    nheven(2,0.5,A) nheven(2,0.5,A) nheven(2,0.5,A) nheven(1,0.5,E) r(0.125) nheven(1,0.5,D) r(0.125) nheven(1,0.5,FS)...
    r(0.125) nheven(1,0.5,FS) r(0.125) nheven(1,0.5,FS) nheven(1,0.5,E) nheven(1,0.5,E) nheven(1,0.5,FS) nheven(1,0.5,E)];
Odd = [nhodd(1,0.5,FS) nhodd(1,0.5,FS) nhodd(1,0.5,D) nhodd(1,0.5,B) r(0.125) nhodd(1,0.5,B) r(0.125) nhodd(1,0.5,E)... % 0th octave set to 1
    r(0.125) nhodd(1,0.5,E) r(0.125) nhodd(1,0.5,E) nhodd(1,0.5,GS) nhodd(1,0.5,GS) nhodd(2,0.5,A) nhodd(2,0.5,B)...
    nhodd(2,0.5,A) nhodd(2,0.5,A) nhodd(2,0.5,A) nhodd(1,0.5,E) r(0.125) nhodd(1,0.5,D) r(0.125) nhodd(1,0.5,FS)...
    r(0.125) nhodd(1,0.5,FS) r(0.125) nhodd(1,0.5,FS) nhodd(1,0.5,E) nhodd(1,0.5,E) nhodd(1,0.5,FS) nhodd(1,0.5,E)];
    
%% Play song
%TOM = [Even Odd]; % Test Even and Odd Harmonics only
TOM = [M1S M1+M1S M1+M2S M2+M1S M3+M1S M4+M3S M5+M4S M6+M5S M7+M6S M8+M7S M9+M8S M10+M9S M11+M10S];
%soundsc(TOM,10500);
filename='Kim_TakeOnMe.wav';
y=TOM./max(TOM);
fs=10500;
audiowrite(filename,y,fs)
clear y fs