%%Main script for WindTurbine Problem
%---System Init---%
close all
p=genpath('lib');addpath(p);p=genpath('status');addpath(p);


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
globaldata.ms.pos=1;
globaldata.flags.tiploss=true;
globaldata.flags.overrideLimits=false;
tic;

globaldata.maxiters=100;

paramStepSize=[4,3,2];
globaldata.ms.loops=prod(paramStepSize);
progressbar('Optimisation');

opts = optimset('fminsearch');
opts.Display = 'iter'; %What to display in command window
opts.TolX = 0.0001; %Tolerance on the variation in the parameters
opts.TolFun = 1000; %Tolerance on the error
opts.OutputFcn = @(x,optimValues,state)optMonitor(x,optimValues,state,globaldata); %Tolerance on the error
opts.MaxIter = globaldata.maxiters-1; %Max number of iterations

% Set iteration options.
UBs=[deg2rad(20) deg2rad(0.5) 0.099];
LBs=[deg2rad(2) deg2rad(-2) -0.1];
thetas=linspace(LBs(1),UBs(1),paramStepSize(1)+2);
thetas(1)=[]; thetas(end)=[];
theta_twists=linspace(LBs(2),UBs(2),paramStepSize(2)+2);
theta_twists(1)=[]; theta_twists(end)=[];
c_grads=linspace(LBs(3),UBs(3),paramStepSize(3)+2);
c_grads(1)=[]; c_grads(end)=[];

% Current best diff
curr_best_diff=1e11;
curr_best_x=[0 0 0];

for i=1:paramStepSize(1)
    for j=1:paramStepSize(2)
        for k=1:paramStepSize(3)
            globaldata.ms.pos=((i-1)*(paramStepSize(2)*paramStepSize(3)))+...
                           ((j-1)*paramStepSize(3))+k;
                       opts.OutputFcn = @(x,optimValues,state)optMonitor(x,optimValues,state,globaldata);
               curr_x_ins=[thetas(i) theta_twists(j) c_grads(k)]
[x, diff, exitflag] = fminsearchbnd(@(x)aepCost(x,globaldata), curr_x_ins, LBs, UBs, opts);
        if diff<curr_best_diff
            curr_best_diff=diff
            curr_best_x=x            
        end
        end
    end
end
xdeg=[rad2deg(curr_best_x(1)),rad2deg(curr_best_x(2)),curr_best_x(3)];
x=curr_best_x;
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