function [xdeg_co] = checkOptima(x,globaldata)
%CHECKOPTIMA Produces graphs holding 2 params constant and varying the other.
%   Helps show check solution is optimal.


%% Changing Theta 0
N=200; % Mesh resolution
variableSpace=linspace(deg2rad(2),deg2rad(18),N); % Create theta values
aepHold=zeros(1,N); % Pre-allocate AEP holding array
progressbar('Finding AEPs - Changing Theta'); % Init progres bar

globaldata.flags.overrideLimits=false; % Ignore bending limits first time.

% Loop through the different theta0 values, AEP to holding array
for i=1:N
    [~, aepHold(i), ~] = WTVelocityRange([variableSpace(i),x(2),x(3)], globaldata.A,...
        globaldata.k, globaldata.w, globaldata.c_mean, globaldata.Rmax,...
        globaldata.Rmin, globaldata.B, globaldata.Vmin, globaldata.Vmax,...
        globaldata);
    progressbar(i/N);
end

% Init figure and plot theta vs aep
f7=figure(7);
plot(rad2deg(variableSpace),aepHold,'r-');
xdeg_co=[rad2deg(x(1)),rad2deg(x(2)),x(3)];


%% Changing Theta twist
N=150; % Mesh resolution
variableSpace=linspace(deg2rad(-1.5),deg2rad(0.5),N); % Create theta_tw values
aepHold=zeros(1,N); % pre-allocate AEP holding array
progressbar('Finding AEPs - Changing Theta Twist'); % Init progress bar
% Loop through twist values
for i=1:N
    [~, aepHold(i), ~] = WTVelocityRange([x(1),variableSpace(i),x(3)], globaldata.A,...
        globaldata.k, globaldata.w, globaldata.c_mean, globaldata.Rmax,...
        globaldata.Rmin, globaldata.B, globaldata.Vmin, globaldata.Vmax,...
        globaldata);
    progressbar(i/N);
end
% Create figure and plot theta_twist vs aep.
f8=figure(8);
plot(rad2deg(variableSpace),aepHold,'r-');
xdeg_co=[rad2deg(x(1)),rad2deg(x(2)),x(3)];


%% Changing c_grad
N=150; % Mesh resolution
variableSpace=linspace(-0.1,0.1,N); % Create chord gradient values.
aepHold=zeros(1,N); % Pre-allocate aep holding array
progressbar('Finding AEPs - Changing Chord Gradient'); % Init progress bar.

% Loop through chord gradients.
for i=1:N
    [~, aepHold(i), ~] = WTVelocityRange([x(1),x(2),variableSpace(i)], globaldata.A,...
        globaldata.k, globaldata.w, globaldata.c_mean, globaldata.Rmax,...
        globaldata.Rmin, globaldata.B, globaldata.Vmin, globaldata.Vmax,...
        globaldata);
    progressbar(i/N);
end
% Create figure and plot chord gradients vs aep
f9=figure(9);
plot(variableSpace,aepHold,'r-');
xdeg_co=[rad2deg(x(1)),rad2deg(x(2)),x(3)];

end

