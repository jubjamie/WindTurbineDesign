function stop = optMonitor(x, optimValues,state)
%OPTMONITOR Summary of this function goes here
%   Detailed explanation goes here
global maxiters etol
currOptIt=double(optimValues.iteration)+1;
currPos=currOptIt/maxiters;
if currPos>0.5
    etol=0.0001;
end
switch state
    case 'init'
        %disp('Optimiser booting');
        progressbar([],[],[],(currOptIt/maxiters));
    case 'iter'
        %New iteration
        %disp(['Iteration: ' num2str(currOptIt) '/' num2str(maxiters)]);
        %disp(num2str(currPos));
        progressbar([],[],[],currPos);
    case 'interrupt'
        %Check conditions to see if optim should quit
    case 'done'
        %Optim complete. Clean up here.
        progressbar([],[],[],currPos);
end
stop=false;
end

