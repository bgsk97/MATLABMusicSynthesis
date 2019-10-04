function [A] = NoteFreqGen(n,octave)      % Takes inputs of number of
                                            % notes needed, octave starting
                                            % frequency
                                            % and outputs variety of notes
A=[]; % Array of notes
for i=1:n
    note=octave*2^((i-1)./12); % Create a note
    A(:,i)=note; % Insert each note into the output vector
end