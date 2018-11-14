function [EI] = EIcalc(chord)
%EIcalc Calculate EI for axis 1
% Use approximation given in CW sheet.
EI=((chord.*((0.2*chord).^3))/12).*40e9;
end

