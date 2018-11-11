function [xdeg_co] = checkOptima(x,globaldata)
%CHECKOPTIMA Produces graphs holding 2 params constant and varying the other.
%   Helps show check solution is optimal.

globaldata.flags.overrideLimits=true;

%% Changing Theta 0
N=300;
variableSpace=linspace(deg2rad(2),deg2rad(18),N);
aepHold=zeros(1,N);
progressbar('Finding AEPs - Changing Theta');
for i=1:N
    [~, aepHold(i), ~] = WTVelocityRange([variableSpace(i),x(2),x(3)], globaldata.A,...
        globaldata.k, globaldata.w, globaldata.c_mean, globaldata.Rmax,...
        globaldata.Rmin, globaldata.B, globaldata.Vmin, globaldata.Vmax,...
        globaldata);
    progressbar(i/N);
end
f7=figure(7);
plot(rad2deg(variableSpace),aepHold,'r--');
xdeg_co=[rad2deg(x(1)),rad2deg(x(2)),x(3)];
hold on
globaldata.flags.overrideLimits=false;
aepHold=zeros(1,N);
progressbar('Finding AEPs - Changing Theta');
for i=1:N
    [~, aepHold(i), ~] = WTVelocityRange([variableSpace(i),x(2),x(3)], globaldata.A,...
        globaldata.k, globaldata.w, globaldata.c_mean, globaldata.Rmax,...
        globaldata.Rmin, globaldata.B, globaldata.Vmin, globaldata.Vmax,...
        globaldata);
    progressbar(i/N);
end
plot(rad2deg(variableSpace),aepHold,'b-');
globaldata.flags.overrideLimits=false;

%% Changing Theta twist
N=300;
variableSpace=linspace(deg2rad(-1.5),deg2rad(0.5),N);
aepHold=zeros(1,N);
progressbar('Finding AEPs - Changing Theta Twist');
for i=1:N
    [~, aepHold(i), ~] = WTVelocityRange([x(1),variableSpace(i),x(3)], globaldata.A,...
        globaldata.k, globaldata.w, globaldata.c_mean, globaldata.Rmax,...
        globaldata.Rmin, globaldata.B, globaldata.Vmin, globaldata.Vmax,...
        globaldata);
    progressbar(i/N);
end
f7=figure(8);
plot(rad2deg(variableSpace),aepHold);
xdeg_co=[rad2deg(x(1)),rad2deg(x(2)),x(3)];

%% Changing c_grad
N=300;
variableSpace=linspace(-0.1,0.1,N);
aepHold=zeros(1,N);
progressbar('Finding AEPs - Changing Chord Gradient');
for i=1:N
    [~, aepHold(i), ~] = WTVelocityRange([x(1),x(2),variableSpace(i)], globaldata.A,...
        globaldata.k, globaldata.w, globaldata.c_mean, globaldata.Rmax,...
        globaldata.Rmin, globaldata.B, globaldata.Vmin, globaldata.Vmax,...
        globaldata);
    progressbar(i/N);
end
f7=figure(9);
plot(variableSpace,aepHold);
xdeg_co=[rad2deg(x(1)),rad2deg(x(2)),x(3)];

end

