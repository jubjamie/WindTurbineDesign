function [EI] = EI2calc(chord)
%EI2calc Calculate EI for axis 2
% Use approximation given in CW sheet.
EI=(((0.2*chord).*((chord).^3))/12).*40e9;
end

