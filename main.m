%%Main script for WindTurbine Problem
%---System Init---%
close all
p=genpath('lib');addpath(p);p=genpath('status');addpath(p);
progressbar('Calculating Power', 'Solving Rotor', 'Finding Local Induced Flow', 'Optimisation');


%% Part B Optimisation
% Aim to minimise the difference returned by AEP S3 calcs
globaldata=[];
% Create Log File
[globaldata.logid, logpath]=createlog('Part B Optimiser');
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
globaldata.flags.tiploss=true;
globaldata.flags.overrideLimits=false;
tic;

globaldata.maxiters=250;
progressbar('Optimisation');

opts = optimset('fminsearch');
opts.Display = 'iter'; %What to display in command window
opts.TolX = 0.0001; %Tolerance on the variation in the parameters
opts.TolFun = 100; %Tolerance on the error
opts.OutputFcn = @(x,optimValues,state)optMonitor(x,optimValues,state,globaldata); %Tolerance on the error
opts.MaxIter = globaldata.maxiters-1; %Max number of iterations
[x, diff, exitflag] = fminsearchbnd(@(x)aepCost(x,globaldata), [deg2rad(12) deg2rad(-0.5) 0], [deg2rad(2) deg2rad(-2) -0.1], [deg2rad(20) deg2rad(-0.1) 0.099], opts);
xdeg=[rad2deg(x(1)),rad2deg(x(2)),x(3)];
if exitflag==1
    disp('Optimiser SOLVED.');
elseif exitflag==0
    disp(['Optimiser reached MAX iterations of ' num2str(globaldata.maxiters) '. Most recent solution:']);
elseif exitflag==-1
    disp('Optimiser has been stopped by an output function. Most recent solution;');
else
    disp('Optimiser has been stopped unexpectedly. See the command window for possible errors. Most recent solution:');
end

runtimer=toc;

progressbar(1);
statustablematrix(xdeg, {'Theta','Theta_Twist','c_grad'}, 'status/optSolSmall.png', 'Optimiser Results','print',1.2);
fprintf(globaldata.logid,'\r\nFINAL SOLUTION\r\n');
fprintf(globaldata.logid,'Theta: %f deg.  Theta tw: %f deg.  c_grad: %f\r\n',xdeg(1),xdeg(2),xdeg(3));
%Ask if final run of result wanted.
runSolutionInput=questdlg('Parse solution through S3?','Solution Viewer','Yes','No','No');
switch runSolutionInput
    case 'Yes'
       run('lastSolution');
        
        
end


%% Clean Up

fprintf(globaldata.logid,'\r\n> > > END < < <\r\n');
fprintf(globaldata.logid,'Tests Completed in %f seconds---\r\n',runtimer);
progressbar(1);
fclose(globaldata.logid);
disp(['Core Completed in ' num2str(runtimer) ' seconds']);
disp(['<a href = "../logs/' logpath '.log">Open Session Log</a>']);