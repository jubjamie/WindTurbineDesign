%%Tests the addpath functionality of MATLAB
p=genpath('lib');
addpath(p);
%Test using provided function in lib
[Cl,Cd] = ForceCoefficient(0.2,12000);
disp([num2str(Cl) '-' num2str(Cd)]);