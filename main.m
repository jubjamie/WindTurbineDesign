%%Main script for WindTurbine Problem
%---System Init---%
close all
% Add paths
p=genpath('lib');addpath(p);p=genpath('status');addpath(p);

%---Set Global Constants---%
%Define globals from cw sheets (see /docs)
%Dimensions (m)
global Hhub dhub Rmin Rmax c_mean
Hhub=35; dhub=3; Rmin=1; Rmax=20; c_mean=1;

%Forces
global M_rootmax F_Ymax;
M_rootmax=0.5e6; %Nm
F_Ymax=70000; %N

%Quantities
global rho_blade EI_blade Vmin Vmax A k w
rho_blade=2000; %kg/m3
EI_blade=40e9 * (c_mean*(0.2*c_mean)^3)/12; %TEMP - GPA
Vmin=5; Vmax=25; %m/s
A=7; k=1.8;
w=30*2*pi/60; %rad/s

%%Section 1
%Init a and adash for Section 1 function.
init_a=0;
init_adash=0;
init_V0=20;
init_theta=0.0733;
init_R=19.5;

[a, adash, phi, Cn, Ct, tol, i]=WTInducedCalcs(init_a,init_adash,init_V0,w,init_R,init_theta,1,3);
s1singletable=table(a, adash, phi, Cn, Ct, tol, i);

%Create figure for display.
f = figure('visible','off');
axis off
hold on
set(f, 'Position', [500 500 650 80])
% Get the table in string form.
TString = evalc('disp(s1singletable)');
% Use TeX Markup for bold formatting and underscores.
TString = strrep(TString,'<strong>','\bf');
TString = strrep(TString,'</strong>','\rm');
TString = strrep(TString,'_','\_');
% Get a fixed-width font.
FixedWidth = get(0,'FixedWidthFontName');
% Output the table using the annotation command.
annotation(gcf,'Textbox','String',TString,'Interpreter','Tex',...
    'FontName',FixedWidth,'Units','Normalized','Position',[0 0 1 1]);
saveas(f,'status/s1_singlevalidation.png');

