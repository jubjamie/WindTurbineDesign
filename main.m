%%Main script for WindTurbine Problem
%---System Init---%
close all
progressbar('Calculating Power', 'Solving Rotor', 'Finding Local Induced Flow', 'Optimisation');
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

%System Globals
global maxiters

%{

%% Section 1 Testing
%Init a and adash for Section 1 function.
progressbar('Calculating Power', 'Solving Rotor', 'Finding Local Induced Flow', 'Optimisation');

init_a=0;
init_adash=0;
init_V0=20;
init_theta=0.0733;
init_R=19.5;

[a, adash, phi, Cn, Ct,Vrel, tol, i]=WTInducedCalcs(init_a,init_adash,init_V0,w,init_R,init_theta,1,3);
%s1singletable=table(a, adash, phi, Cn, Ct, tol, i);
statustablematrix([a, adash, phi, Cn, Ct,Vrel, tol, i],{'a', 'adash', 'phi', 'Cn', 'Ct','Vrel', 'tol', 'i'},'status/s1_singlevalidation.png','Section 1 Single Validation','print',1);


%% Section 2 Testing
% Test the multi S1 validation case.
progressbar('Calculating Power', 'Solving Rotor', 'Finding Local Induced Flow', 'Optimisation');

[MT, MN, S2] = WTSingleVelocity(20, 0.209, -0.00698, 0, 20 ,1, 3);
statustablematrix(S2,{'r', 'a', 'adash', 'phi', 'Cn', 'Ct', 'tol', 'i','Vrel','Mt','Mn'},'status/s2_multivalidation.png','Section 2 Multi Validation','print',1);

%% Section 3 Testing
% Test the AEP output for S3 Validation Case
progressbar('Calculating Power', 'Solving Rotor', 'Finding Local Induced Flow', 'Optimisation');

defaultBlade=[deg2rad(12), deg2rad(-0.4), 0];
[total_diff, AEP, S3] = WTVelocityRange(defaultBlade, A, k, w, c_mean, 20, 1, 3, 5, 25);
statustablematrix(S3,{'V0', 'Power', 'Probability', 'AEP', 'Ideal_AEP', 'Difference', 'Efficiency'},'status/s3_multivalidation.png','Section 3 Multi AEP Validation','figure',1.3);
%}

%% Part B Optimisation
% Aim to minimise the difference returned by AEP S3 calcs
%WIP
% Create Log File
logid=createlog('Part B Optimiser');

maxiters=5;
progressbar('Calculating Power', 'Solving Rotor', 'Finding Local Induced Flow', 'Optimisation');
%progressbar([],[],[], (1/maxiters));
opts = optimset('fminsearch');
opts.Display = 'iter'; %What to display in command window
opts.TolX = 0.0001; %Tolerance on the variation in the parameters
opts.TolFun = 0.001; %Tolerance on the error
opts.OutputFcn = @optMonitor; %Tolerance on the error
opts.MaxIter = maxiters-1; %Max number of iterations
[x, diff, exitflag] = fminsearchbnd(@aepCost, [deg2rad(12) deg2rad(-0.4) 0], [deg2rad(0) deg2rad(-2) 0], [deg2rad(20) deg2rad(2) 0.9], opts);
xdeg=[rad2deg(x(1)),rad2deg(x(2)),x(3)];
if exitflag==1
    disp('Optimiser SOLVED.');
elseif exitflag==0
    disp(['Optimiser reached MAX iterations of ' num2str(maxiters) '. Most recent solution:']);
elseif exitflag==-1
    disp('Optimiser has been stopped by an output function. Most recent solution;');
else
    disp('Optimiser has been stopped unexpectedly. See the command window for possible errors. Most recent solution:');
end

statustablematrix(xdeg, {'Theta','Theta_Twist','c_grad'}, 'status/optSolSmall.png', 'Optimiser Results','print',1.5);

runSolutionInput=questdlg('Parse solution through S3?','Yes','No');
switch runSolutionInput
    case 'Yes'
       run('lastSolution');
        
        
end

%% Clean Up
progressbar(1,1,1,1);
fclose(logid);