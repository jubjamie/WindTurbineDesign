function [prob] = windProb(A, k, Vi1, Vi2)
%WINDPROB Summary of this function goes here
%   Detailed explanation goes here

%Vi_1 prob
vi1prob=exp(-(Vi1./A).^k);
%Vi_2 prob
vi2prob=exp(-(Vi2./A).^k);

%Difference is probability for band.

prob=vi1prob-vi2prob;
end

