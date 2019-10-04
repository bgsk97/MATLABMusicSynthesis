function [y] = Echo(note)
 delay1 = 0.2; % multiplier for time delay of echo
 delay2 = 0.4;
 delay3 = 0.7;
 delay4 = 0.8;
 delay5 = 0.85;
 alpha1 = 0.3; % echo amplitude 
 alpha2 = 0.15;
 alpha3 = 0;
 alpha4 = 0;
 alpha5 = 0;
 y1 = zeros(size(note));  % creates vector of size equivalent to note called
 y2 = zeros(size(note)); 
 y3 = zeros(size(note)); 
 y4 = zeros(size(note)); 
 y5 = zeros(size(note));
 D1 = delay1*length(note); % specifies time delay in vector
 D2 = delay2*length(note);
 D3 = delay3*length(note);
 D4 = delay4*length(note);
 D5 = delay5*length(note);
 y1(1:D1) = note(1:D1);
   
 for i=D1+1:length(note)  
   y1(i) = note(i) + alpha1*note(i-D1);  % original note + 1 echo
 end 
 for i=D2+1:length(note)  
   y2(i) = alpha2*note(i-D2);  % 2nd echo ...
  end 
 for i=D3+1:length(note)  
   y3(i) = alpha3*note(i-D3);  
 end 
 for i=D4+1:length(note)  
   y4(i) = alpha4*note(i-D4);  
  end 
 for i=D5+1:length(note)  
   y5(i) = alpha5*note(i-D5);  
 end 
 y = (y1+y2+y3+y4+y5)./max((y1+y2+y3+y4+y5)); % adds original note and 4 separate echos of different time delays