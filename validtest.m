%---System Init---%
close all
p=genpath('lib');addpath(p);p=genpath('status');addpath(p);
progressbar('Calculating Power', 'Solving Rotor', 'Finding Local Induced Flow', 'Optimisation');


%---Set Global Constants---%
%Define globals from cw sheets (see /docs)
%Dimensions (m)
global Hhub dhub Rmin Rmax c_mean;
Hhub=35; dhub=3; Rmin=1; Rmax=20; c_mean=1;

%Forces
global M_rootmax F_Ymax;
M_rootmax=0.5e6; %Nm
F_Ymax=70000; %N

%Quantities
global rho_blade EI_blade Vmin Vmax A k w;
rho_blade=2000; %kg/m3
EI_blade=40e9 * (c_mean*(0.2*c_mean)^3)/12; %TEMP - GPA
Vmin=5; Vmax=25; %m/s
A=7; k=1.8;
w=30*2*pi/60; %rad/s

%System Globals
global maxiters logid

logid=createlog('Unit Validation Tests');
fprintf(logid,'> > > Start < < <\r\n');
tic;


%% Section 1 Testing
%Init a and adash for Section 1 function.
fprintf(logid,'---Section 1 Single Test---\r\n');
progressbar('Calculating Power', 'Solving Rotor', 'Finding Local Induced Flow', 'Optimisation');

init_a=0;
init_adash=0;
init_V0=20;
init_theta=0.0733;
init_R=19.5;

[a, adash, phi, Cn, Ct,Vrel, tol, i]=WTInducedCalcs(init_a,init_adash,init_V0,w,init_R,init_theta,1,3);
%[a, adash, phi, Cn, Ct,Vrel, tol, i]=WTInducedCalcs(0, 0, 5.000000, 3.141593, 8.500000, 0.193245, 1.000000, 3.000000);
%s1singletable=table(a, adash, phi, Cn, Ct, tol, i);
statustablematrix([a, adash, phi, Cn, Ct,Vrel, tol, i],{'a', 'adash', 'phi', 'Cn', 'Ct','Vrel', 'tol', 'i'},'status/s1_singlevalidation.png','Section 1 Single Validation','None',1);


%% Section 2 Testing
% Test the multi S1 validation case.
fprintf(logid,'---Section 2 Multi Node Rotor Test---\r\n');
progressbar('Calculating Power', 'Solving Rotor', 'Finding Local Induced Flow', 'Optimisation');

[MT, MN, S2] = WTSingleVelocity(20, 0.209, -0.00698, 0, 20 ,1, 3);
statustablematrix(S2,{'r', 'a', 'adash', 'phi', 'Cn', 'Ct', 'tol', 'i','Vrel','Mt','Mn'},'status/s2_multivalidation.png','Section 2 Multi Validation','None',1);


%% Section 3 Testing
% Test the AEP output for S3 Validation Case
fprintf(logid,'---Section 3 AEP Test---\r\n');
progressbar('Calculating Power', 'Solving Rotor', 'Finding Local Induced Flow', 'Optimisation');

defaultBlade=[deg2rad(12), deg2rad(-0.4), 0];
[total_diff, AEP, S3] = WTVelocityRange(defaultBlade, A, k, w, c_mean, 20, 1, 3, 5, 25);
statustablematrix(S3,{'V0', 'Power', 'Probability', 'AEP', 'Ideal_AEP', 'Difference', 'Efficiency'},'status/s3_multivalidation.png','Section 3 Multi AEP Validation','None',1.3);

validS3metric=(AEP/812670179)*100;
if validS3metric>95 && validS3metric<105
    disp(['Final AEP Test Passed: ' num2str(validS3metric) '%']);
    fprintf(logid,'AEP Test Passed: %f%%\r\n',validS3metric);
else
    warning(['Final AEP Test Failed: ' num2str(validS3metric) '%']);
    fprintf(logid,'AEP Test Failed: %f%%\r\n',validS3metric);
end    
runtimer=toc;
fprintf(logid,'> > > END < < <\r\n');
fprintf(logid,'Tests Completed in %f seconds---\r\n',runtimer);
%% Clean Up
disp(['Tests Completed in ' num2str(runtimer) ' seconds']);
progressbar(1,1,1,1);
fclose(logid);