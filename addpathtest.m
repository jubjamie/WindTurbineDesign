%%Tests the addpath functionality of MATLAB
addpath('lib');
%Use example function provided in lib folder.
[Cl,Cd] = ForceCoefficient(0.2,12000);
%Print out.
disp([num2str(Cl) '-' num2str(Cd)]);