addpath('lib');
[Cl,Cd] = ForceCoefficient(0.2,12000);
disp([num2str(Cl) '-' num2str(Cd)]);