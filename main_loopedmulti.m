%%Main script for WindTurbine Problem
close all

%% Part B Optimisation
% Aim to minimise the difference returned by AEP S3 calcs

%% Setup
% Set global data structure to pass around global variables.
globaldata=[];
% Create Log File
[globaldata.logid, logpath]=createlog('Part B Multi-Optimiser');

globaldata.etol=0.0001; % Set WTInducedCalcs initial tolerance
globaldata.A=7; % Set Weibull Constant
globaldata.k=1.8; % Set Weibull Constant
globaldata.w=30*2*pi/60; % Set rpm
globaldata.Vmin=5; % Set minimum wind speed
globaldata.Vmax=25; % Set maximum wind speed
globaldata.c_mean=1; % Set mean chord.
globaldata.Rmin=1; % Set hub radius
globaldata.Rmax=20; % Set maximum blade radius
globaldata.B=3; % Set number of blades
globaldata.M_rootmax=0.5e6; % Set max root bending moment.

% System/Settings
globaldata.ms.pos=1; % Count multistarting position.
globaldata.flags.tiploss=true; % Flag to enable tip losses
globaldata.flags.overrideLimits=false; % Flag to abide by bending limits

tic; % Start timing run (for bench marking)

% Set up optimiser
paramStepSize=[4,3,2]; % Set intervals for multistart to evaluate
globaldata.ms.loops=prod(paramStepSize); % Count number of permutations
progressbar('Optimisation'); % Initialise progress bar.

globaldata.maxiters=100; % Set max number of simplex iterations/input

opts = optimset('fminsearch'); % Set options default.
opts.Display = 'iter'; %Display progress in command window
opts.TolX = 0.0001; %Tolerance on the variation in the parameters
opts.TolFun = 1000; %Tolerance on cost. Large as Diff is of large order.
% Define initial output function for optimiser as anonymous function.
opts.OutputFcn = @(x,optimValues,state)optMonitor(x,optimValues,state,globaldata);
opts.MaxIter = globaldata.maxiters-1; % Set number of iterations.

% Set multistart bounds.
UBs=[deg2rad(20) deg2rad(0.5) 0.099]; % Upper bounds
LBs=[deg2rad(2) deg2rad(-2) -0.1]; % Lower bounds

% Create linear space of thetas and remove the bound values.
thetas=linspace(LBs(1),UBs(1),paramStepSize(1)+2); 
thetas(1)=[]; thetas(end)=[];
% Create linear space of theta twists and remove the bound values.
theta_twists=linspace(LBs(2),UBs(2),paramStepSize(2)+2);
theta_twists(1)=[]; theta_twists(end)=[];
% Create linear space of chord cradients and remove the bound values.
c_grads=linspace(LBs(3),UBs(3),paramStepSize(3)+2);
c_grads(1)=[]; c_grads(end)=[];

%% Optimiser
% Dummy values for Current best diff/bladeConfig (aka x-input values)
curr_best_diff=1e11;
curr_best_x=[0 0 0];

% Permutate through initial values
for i=1:paramStepSize(1)
    for j=1:paramStepSize(2)
        for k=1:paramStepSize(3)
            % Calculate permutation number for progress calculation
            globaldata.ms.pos=((i-1)*(paramStepSize(2)*paramStepSize(3)))+...
                           ((j-1)*paramStepSize(3))+k;
               % Update output fcn definition with updated globaldata.      
               opts.OutputFcn = @(x,optimValues,state)optMonitor(x,...
                   optimValues,state,globaldata);
               % Set Balde Config
               curr_x_ins=[thetas(i) theta_twists(j) c_grads(k)];
               %Run optimiser on input permutation
               [x, diff, exitflag] = fminsearchbnd(@(x)aepCost(x,...
                   globaldata), curr_x_ins, LBs, UBs, opts);
               % If solution is better than previous, update current bests.
               if diff<curr_best_diff
                    curr_best_diff=diff;
                    curr_best_x=x;          
               end
        end
    end
end

%% Outputs
% Place input values into workspace as more accessible variables.
xdeg=[rad2deg(curr_best_x(1)),rad2deg(curr_best_x(2)),curr_best_x(3)];
x=curr_best_x;

disp('Optimiser Finished');

runtimer=toc; % Stop timing core code

progressbar(1); % Close progress bar

%Save results as status images for Github and into the log file.
statustablematrix(xdeg, {'Theta','Theta_Twist','c_grad'},...
    'status/optSolSmall.png', 'Optimiser Results','print',1.2);
fprintf(globaldata.logid,'\r\nFINAL SOLUTION\r\n');
fprintf(globaldata.logid,'Theta: %f deg.  Theta tw: %f deg.  c_grad: %f\r\n',...
    xdeg(1),xdeg(2),xdeg(3));

%Ask if user wants to run the lastSolution script on the optimal values.
runSolutionInput=questdlg('Parse solution through S3?',...
    'Solution Viewer','Yes','No','No');
switch runSolutionInput
    case 'Yes'
       run('lastSolution');
        
        
end

%% Clean Up
% Finish and close logs and progress bars.
fprintf(globaldata.logid,'\r\n> > > END < < <\r\n');
fprintf(globaldata.logid,'Tests Completed in %f seconds---\r\n',runtimer);
progressbar(1);
fclose(globaldata.logid);
% Display core code run time
disp(['Core Completed in ' num2str(runtimer) ' seconds']);
% Display link to log in command window.
disp(['<a href = "../logs/' logpath '.log">Open Session Log</a>']);