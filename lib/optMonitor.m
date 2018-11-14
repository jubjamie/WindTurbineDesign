function stop = optMonitor(x, optimValues,state,globaldata)
%OPTMONITOR A OutputFcn for the optimiser
%   OutputFcn format. Optimiser provides this function with
%   information on the optimiser position, state and function values.

% Calculate values for progressbar calculations.
currOptIt=double(optimValues.iteration)+1;
loopSection=globaldata.ms.pos;
totalLoops=globaldata.ms.loops;
completedFraction=(loopSection-1)/totalLoops;
currPos=completedFraction+((currOptIt/globaldata.maxiters)/totalLoops);

% Update progress bar and/or log-file depending on optimiser state.
switch state
    case 'init'
        progressbar(currPos); % Update progress bar
    case 'iter'
        %New iteration
        progressbar(currPos); % Update progress bar
        % Add new iteration attempt to log file.
        fprintf(globaldata.logid,...
            'Iteration: %d Fun Evals: %d Function Value(x): %f\r\n',...
            round(optimValues.iteration,0),round(optimValues.funccount,0),...
            optimValues.fval);
    case 'interrupt'
        %Check conditions to see if optim should quit
    case 'done'
        %Optim complete. Clean up here.
        progressbar(currPos);
end
stop=false; % Send flag to optimiser to give it permission to continue.
end

