function stop = optMonitor(x, optimValues,state)
%OPTMONITOR Summary of this function goes here
%   Detailed explanation goes here
global maxiters
progressbar([],[],[],optimValues.iteration/maxiters);
end

