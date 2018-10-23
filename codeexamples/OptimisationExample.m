function [] = OptimisationExample()
%This function creates noisy sine data then uses fminsearchbnd to get the
%optimised values of amplitude, frequency and phase lag that give the best
%possible sine curve fitto this noisy data. 

%In each loop of fminsearchbnd it also plots the data and fit, saves
%this as a frame and then at the end animates these frames.

%CREATE DATA - sine curve with noise
Data = zeros(100, 2);
Data(:,1) = 0.01:0.01:1;
Data(:,2) = sin(2*pi*Data(:,1))+0.1*randn(100,1);

%DEFINE FRAMES FOR MOVIE
global F j    %F and j are declared global so they can are automatically passed across functions
j=0;          %Initialise j - this is to record the framenumber
F = struct('cdata',[],'colormap',[]);   %Initialise F - these

%OPTIMISE FIT - 3 variables: amplitude, frequency and phaselag
opts = optimset('fminsearch');
opts.Display = 'iter'; %What to display in command window
opts.TolX = 0.001; %Tolerance on the variation in the parameters
opts.TolFun = 0.001; %Tolerance on the error
opts.MaxFunEvals = 100; %Max number of iterations
[x] = fminsearchbnd(@sinfit, [1.5 1 0], [0.5 0.1 -pi], [2 2 pi], opts, Data);

%PLAY MOVIE - 3 times
movie(F, 3)

%WRITE OPTIMAL VARIABLES IN COMMAND WINDOW
disp(strcat('OPTIMAL VALUES: Amplitude = ', num2str(x(1)), 'Frequency = ', num2str(x(2)), 'Phase-Lag = ', num2str(x(3))))
end