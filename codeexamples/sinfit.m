function [Error] = sinfit(Parameters, Data)
a = Parameters(1); %Amplitude
f = Parameters(2); %Frequency
PL = Parameters(3); %Phaselag

%CREATE DATA
y = a*sin(2*pi*f.*(Data(:,1)-PL)); 

%MOVIE DEFINITIONS
global F j %allows F and j to be passed between functions
j=j+1; %the iteration count

%PLOT FIT vs DATA COMPARISON
PlotData=1;
if PlotData == 1
    close gcf %close last figure window
    figure %create new figure window
    hold on %hold figure constant - plot data ver each other
    
    plot(Data(:,1), Data(:,2), 'ro') %plot noisy data
    plot(Data(:,1), y(:), '-k') %plot sine curve
    
    set(gca, 'XLim', [0 1]) %set x-range
    set(gca, 'YLim', [-1.5 1.5]) %set y-range
    
    F(j)=getframe; %Record as a frame for movie
end

%COST FUNCTION - calculate difference (in y) between data points and the sine curve. 
Error=0;
for i = 1:length(Data)
    Error=Error+abs(Data(i,2)-y(i));
end
end