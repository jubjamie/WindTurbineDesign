function [cost] = aepCost(INs,globaldata)
%AEPCOST The cost function for the optimiser to minimise.
%   Returns the difference between AEP and IAEP from VelocityRange as a
%   single output (required cost form for optimiser.

% Convinience names for input array.
Theta0=INs(1);
ThetaTwist=INs(2);
c_grad=INs(3);

% Log attempt input blade configuration to file.
fprintf(globaldata.logid,...
    '\r\n---New Cost Solve---\r\nTheta: %fdeg, Twist: %fdeg, c_grad: %f\r\n'...
    ,rad2deg(Theta0), rad2deg(ThetaTwist), c_grad);

% Init the velocity range parallel processing loop to find AEP for the ranges
% and coefficients defined in globaldata below.
[cost, AEP, S3] = WTVelocityRange([Theta0,ThetaTwist,c_grad],...
    globaldata.A, globaldata.k, globaldata.w, globaldata.c_mean,...
    globaldata.Rmax, globaldata.Rmin, globaldata.B, globaldata.Vmin,...
    globaldata.Vmax, globaldata);

end

