function stop = optMonitor(x, optimValues,state,globaldata)
%OPTMONITOR Summary of this function goes here
%   Detailed explanation goes here

currOptIt=double(optimValues.iteration)+1;
loopSection=globaldata.ms.pos;
totalLoops=globaldata.ms.loops;
completedFraction=(loopSection-1)/totalLoops;
currPos=completedFraction+((currOptIt/globaldata.maxiters)/totalLoops);

switch state
    case 'init'
        %disp('Optimiser booting');
        progressbar(currPos);
    case 'iter'
        %New iteration
        %disp(['Iteration: ' num2str(currOptIt) '/' num2str(maxiters)]);
        %disp(num2str(currPos));
        progressbar(currPos);
        fprintf(globaldata.logid,'Iteration: %d Fun Evals: %d Function Value(x): %f\r\n',round(optimValues.iteration,0),round(optimValues.funccount,0),optimValues.fval);
    case 'interrupt'
        %Check conditions to see if optim should quit
    case 'done'
        %Optim complete. Clean up here.
        progressbar(currPos);
end
stop=false;
end

