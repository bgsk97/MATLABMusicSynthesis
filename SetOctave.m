function y = SetOctave(o)

if o >= 0
    y = 2.^o;
else
    y = 1/2.^(-o);
end