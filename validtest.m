%---System Init---%
close all
p=genpath('lib');addpath(p);p=genpath('status');addpath(p);

[globaldata.logid,logpath]=createlog('Unit Validation Tests');
fprintf(globaldata.logid,'\r\n> > > Start < < <\r\n');

globaldata.etol=0.0001;
globaldata.A=7;
globaldata.k=1.8;
globaldata.w=30*2*pi/60;
globaldata.Vmin=5;
globaldata.Vmax=25;
globaldata.c_mean=1;
globaldata.Rmin=1;
globaldata.Rmax=20;
globaldata.B=3;
globaldata.M_rootmax=0.5e6;

tic;


%% Section 1 Testing
%Init a and adash for Section 1 function.
fprintf(globaldata.logid,'---Section 1 Single Test---\r\n');

init_a=0;
init_adash=0;
init_V0=20;
init_theta=0.0733;
init_R=19.5;

[a, adash, phi, Cn, Ct,Vrel, tol, i]=WTInducedCalcs(init_a,init_adash,init_V0,globaldata.w,init_R,init_theta,1,3,globaldata.logid,globaldata.etol,20);
%[a, adash, phi, Cn, Ct,Vrel, tol, i]=WTInducedCalcs(0, 0, 5.000000, 3.141593, 8.500000, 0.193245, 1.000000, 3.000000);
%s1singletable=table(a, adash, phi, Cn, Ct, tol, i);
statustablematrix([a, adash, phi, Cn, Ct,Vrel, tol, i],{'a', 'adash', 'phi', 'Cn', 'Ct','Vrel', 'tol', 'i'},'status/s1_singlevalidation.png','Section 1 Single Validation','figure',1);
validS1metric=(a/0.0783)*100;
if validS1metric>95 && validS1metric<105
    disp(['Single Radius Test Passed: ' num2str(validS1metric) '%']);
    fprintf(globaldata.logid,'Single Radius Passed: %f%%\r\n',validS1metric);
else
    warning(['Single Radius Test Failed: ' num2str(validS1metric) '%']);
    fprintf(globaldata.logid,'Single Radius Rotor Failed: %f%%\r\n',validS1metric);
end  

%% Section 2 Testing
% Test the multi S1 validation case.
fprintf(globaldata.logid,'\r\n---Section 2 Multi Node Rotor Test---\r\n');

[MT, MN, S2] = WTSingleVelocity(20, 0.209, -0.00698, 0, 20 ,1, 3,globaldata);
statustablematrix(S2,{'r', 'a', 'adash', 'phi', 'Cn', 'Ct', 'tol', 'i','Vrel','Mt','Mn','Pt','Pn'},'status/s2_multivalidation.png','Section 2 Multi Validation','figure',1);

validS2metric=(S2(3,2)/0.088501)*100;
if validS2metric>95 && validS2metric<105
    disp(['Full Rotor Test Passed: ' num2str(validS2metric) '%']);
    fprintf(globaldata.logid,'Full Rotor Passed: %f%%\r\n',validS2metric);
else
    warning(['Full Rotor Test Failed: ' num2str(validS2metric) '%']);
    fprintf(globaldata.logid,'Full Rotor Failed: %f%%\r\n',validS2metric);
end  

%% Section 3 Testing
% Test the AEP output for S3 Validation Case
fprintf(globaldata.logid,'\r\n---Section 3 AEP Test---\r\n');

defaultBlade=[deg2rad(12), deg2rad(-0.4), 0];
[total_diff, AEP, S3] = WTVelocityRange(defaultBlade, globaldata.A, globaldata.k, globaldata.w, globaldata.c_mean, 20, 1, 3, 5, 25,globaldata);
statustablematrix(S3,{'V0', 'Power', 'Probability', 'AEP', 'Ideal_AEP', 'Difference', 'Efficiency','Tip_Deflection'},'status/s3_multivalidation.png','Section 3 Multi AEP Validation','figure',1.3);

validS3metric=(AEP/812670179)*100;
if validS3metric>95 && validS3metric<105
    disp(['Final AEP Test Passed: ' num2str(validS3metric) '%']);
    fprintf(globaldata.logid,'AEP Test Passed: %f%%\r\n',validS3metric);
else
    warning(['Final AEP Test Failed: ' num2str(validS3metric) '%']);
    fprintf(globaldata.logid,'AEP Test Failed: %f%%\r\n',validS3metric);
end    
runtimer=toc;
fprintf(globaldata.logid,'\r\n> > > END < < <\r\n');
fprintf(globaldata.logid,'Tests Completed in %f seconds---\r\n',runtimer);
%% Clean Up
disp(['Tests Completed in ' num2str(runtimer) ' seconds']);
disp(['<a href = "../logs/' logpath '.log">Open Session Log</a>']);
fclose(globaldata.logid);