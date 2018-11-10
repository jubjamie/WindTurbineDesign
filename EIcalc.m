function [EI] = EIcalc(chord)
%EIcalc Summary of this function goes here
%   Detailed explanation goes here
EI=((chord*((0.2*chord)^3))/12)*40e9;
end

