function [cost] = aepCost(Theta0,ThetaTwist,c_grad)
%AEPCOST Summary of this function goes here
%   Detailed explanation goes here

global Hhub dhub Rmin Rmax c_mean M_rootmax F_Ymax rho_blade EI_blade Vmin Vmax A k w

[cost, AEP, S3] = WTVelocityRange([Theta0,ThetaTwist,c_grad], A, k, w, c_mean, Rmax, Rmin, 3, Vmin, Vmax);

end

