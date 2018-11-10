function [EI] = EI2calc(chord)
%EI2calc Summary of this function goes here
%   Detailed explanation goes here
EI=(((0.2*chord).*((chord).^3))/12).*40e9;
end

