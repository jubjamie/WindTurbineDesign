%%Main script for WindTurbine Problem
%---System Init---%
close all
% Add paths
p=genpath('lib');addpath(p);p=genpath('status');addpath(p);

%---Set Global Constants---%
%Define globals from cw sheets (see /docs)
%Dimensions (m)
global Hhub dhub Rmin Rmax c_mean
Hhub=35; dhub=3; Rmin=1; Rmax=20; c_mean=1;

%Forces
global M_rootmax F_Ymax;
M_rootmax=0.5e6; %Nm
F_Ymax=70000; %N

%Quantities
global rho_blade EI_blade Vmin Vmax A k w
rho_blade=2000; %kg/m3
EI_blade=40e9 * (c_mean*(0.2*c_mean)^3)/12; %TEMP - GPA
Vmin=5; Vmax=25; %m/s
A=7; k=1.8;
w=30*2*pi/60; %rad/s

%% Section 1 Testing
%Init a and adash for Section 1 function.
init_a=0;
init_adash=0;
init_V0=20;
init_theta=0.0733;
init_R=19.5;

[a, adash, phi, Cn, Ct, tol, i]=WTInducedCalcs(init_a,init_adash,init_V0,w,init_R,init_theta,1,3);
%s1singletable=table(a, adash, phi, Cn, Ct, tol, i);
statustablematrix([a, adash, phi, Cn, Ct, tol, i],{'a', 'adash', 'phi', 'Cn', 'Ct', 'tol', 'i'},'status/s1_singlevalidation.png','figure');


%% Section 2 Testing
% Test the multi S1 validation case.
[MT, MN, S1] = WTSingleVelocity(20, 0.209, -0.00698, 1, 0, 20 ,1, 3.1416, 3);
statustablematrix(S1,{'r', 'a', 'adash', 'phi', 'Cn', 'Ct', 'tol', 'i'},'status/s2_multivalidation.png','figure');

