function [prob] = windProb(A, k, Vi1, Vi2)
%WINDPROB Calculate the Weibull probability for wind speed occurance
%   Pass in location coefficients and the upper and lower velocities of
%   the band a probability is required for. Calculate using the 
%   Weibull distribution.

%Vi_1 prob
vi1prob=exp(-(Vi1./A).^k);
%Vi_2 prob
vi2prob=exp(-(Vi2./A).^k);

%Difference is probability for band.
prob=vi1prob-vi2prob;
end

