function [cost] = aepCost(INs)
%AEPCOST Summary of this function goes here
%   Detailed explanation goes here
global logid
Theta0=INs(1);
ThetaTwist=INs(2);
c_grad=INs(3);

fprintf(logid,'---New Cost Solve---\r\nTheta: %fdeg, Twist: %fdeg, c_grad: %f\r\n',rad2deg(Theta0), rad2deg(ThetaTwist), c_grad);

global Hhub dhub Rmin Rmax c_mean M_rootmax F_Ymax rho_blade EI_blade Vmin Vmax A k w
[cost, AEP, S3] = WTVelocityRange([Theta0,ThetaTwist,c_grad], A, k, w, c_mean, Rmax, Rmin, 3, Vmin, Vmax);

end

