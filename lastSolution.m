%% Intro
% This script is used to compile all the required graphs for the last
% solution. It also generates the status images for Github README.
close all % Close all existing figures to avoid clogging up desktop.
globaldata.flags.tiploss=true; % Set flags to default
globaldata.flags.overrideLimits=false;

%% Get S3 Data by running blade once more
[diff, AEP, S3] = WTVelocityRange(x, globaldata.A, globaldata.k,...
    globaldata.w, globaldata.c_mean, globaldata.Rmax, globaldata.Rmin, 3,...
    globaldata.Vmin, globaldata.Vmax,globaldata);
statustablematrix(S3,{'V0', 'Power', 'Probability', 'AEP', 'Ideal_AEP',...
    'Difference', 'Efficiency', 'Tip_Deflection'},false,...
    'Section 3 AEP Nodal Solution','figure',1.3);
IAEP=sum(S3(:,5));
statustablematrix([xdeg(1), xdeg(2), xdeg(3), AEP,IAEP,(IAEP-AEP),(AEP/IAEP)],...
    {'Theta','Theta_Twist','c_grad','AEP', 'Ideal_AEP', 'Diff', 'Fraction'},...
    'status/optSol.png','Section 3 AEP Total Solution','figure',1.3);

%% Plot graph of powers.
%S3-1 vs S3-2
f6=figure(6); % Init figure

% Use custom quickInterp funtion to extend data to V0 limits
[v0s,powers]=quickInterp(S3(:,1),S3(:,4),'start',globaldata.Vmin);
[v0s,powers]=quickInterp(v0s,powers,'end',globaldata.Vmax);
plot(v0s,(powers./1e6),'-b'); % Plot found AEP profile
hold on;
[v0s,powers]=quickInterp(S3(:,1),S3(:,5),'start',globaldata.Vmin);
[v0s,powers]=quickInterp(v0s,powers,'end',globaldata.Vmax);
plot(v0s,(powers./1e6),'-r'); % Plot Ideal AEP profile
grid
xlabel('Wind Speed (m/s)');
ylabel('Power x Probability (MWhr/yr)');
legend({'Found Solution', 'Ideal AEP Solution'},...
    'Location','Northeast','Interpreter','latex','FontSize',12);
set(gcf,'position',[200,200,650,450])

annotation('textbox',[.62 .4 .3 .3],'String',['Found Solution' newline ...
    '$\theta_0$: ' num2str(round(xdeg(1),2)) '$^\circ$'  ...
    newline '$\theta_{tw}$: ' num2str(round(xdeg(2),2)) '$^\circ$/m' newline...
    '$c_{grad}$: ' num2str(round(xdeg(3),4))],'FitBoxToText','on',...
    'Interpreter','Latex','FontSize',13);

saveas(f6,'status/powerLastSolution.png');
saveas(f6,'graphs/powerLastSolution.png');

% Change settings to show effect without tip loss
globaldata.flags.tiploss=false;
globaldata.flags.overrideLimits=true;

[~, ~, S3_ntl] = WTVelocityRange(x, globaldata.A, globaldata.k, globaldata.w,...
    globaldata.c_mean, globaldata.Rmax, globaldata.Rmin, 3, globaldata.Vmin,...
    globaldata.Vmax,globaldata);

[v0s,powers]=quickInterp(S3_ntl(:,1),S3_ntl(:,4),'start',globaldata.Vmin);
[v0s,powers]=quickInterp(v0s,powers,'end',globaldata.Vmax);

% Plot blade without tip losses.
plot(v0s,(powers./1e6),'LineStyle','--','Color',[0.09,0.56,0.16]);
legend({'Found Solution', 'Ideal AEP Solution','Tip Losses Neglected'},...
    'Location','Northeast','Interpreter','latex','FontSize',12);

% Revert settings
globaldata.flags.tiploss=true;
globaldata.flags.overrideLimits=false;

% Save
saveas(f6,'status/powerLastSolutionCombinedNoTipLoss.png');
saveas(f6,'graphs/powerLastSolutionCombinedNoTipLoss.png');

%% Plot Power Curve vs. Betz Curve
f13=figure(13);

% Plot solution curve overriding limits
% Change settings to create version of data overriding shutdown limits
globaldata.flags.overrideLimits=true;

[diff, AEP, S3_os]=WTVelocityRange(x, globaldata.A, globaldata.k,...
    globaldata.w, globaldata.c_mean, globaldata.Rmax, globaldata.Rmin, 3,...
    globaldata.Vmin, globaldata.Vmax,globaldata);

% Revert settings
globaldata.flags.overrideLimits=false;

actual_powers_os=S3_os(:,2);
[v0s,actual_powers_os]=quickInterp(S3_os(:,1),actual_powers_os,...
                                            'start',globaldata.Vmin);
[v0s,actual_powers_os]=quickInterp(v0s,actual_powers_os,'end',globaldata.Vmax);
plot(v0s,(actual_powers_os./1e6),'r--'); % Plot power curve with no limits

hold on;
grid;

ideal_powers=S3(:,5)./(S3(:,3).*8760);
actual_powers=S3(:,2);
[v0s,actual_powers]=quickInterp(S3(:,1),actual_powers,'start',globaldata.Vmin);
[v0s,actual_powers]=quickInterp(v0s,actual_powers,'end',globaldata.Vmax);
plot(v0s,(actual_powers./1e6),'r-'); % Plot actual power curve

[v0s,ideal_powers]=quickInterp(S3(:,1),ideal_powers,'start',globaldata.Vmin);
[v0s,ideal_powers]=quickInterp(v0s,ideal_powers,'end',globaldata.Vmax);
plot(v0s,(ideal_powers./1e6),'b-'); % Plot ideal power curve

legend({'Solution - Ignoring Bending/Moment Limits',...
    'Solution - With Shutdown Limits','Betz Curve'},...
    'Location','Northwest','Interpreter','latex','FontSize',12);
title('Power Curve Comparison');
xlabel('Wind Speed (m/s)');
ylabel('Power (MW)');
saveas(f13,'graphs/powerBetzCurves.png');

%% Plot Power Coeffs
f14=figure(14);

% Plot solution curve overriding limits
% Change settings to create version of data overriding shutdown limits

actual_powers_os=S3_os(:,2);
[v0s,actual_powers_os]=quickInterp(S3_os(:,1),actual_powers_os,'start',...
                                                         globaldata.Vmin);
[v0s,actual_powers_os]=quickInterp(v0s,actual_powers_os,'end',globaldata.Vmax);
% Plot power coeff with no limits
plot(v0s,(actual_powers_os./...
    (0.5*1.225*(pi*(globaldata.Rmax^2-globaldata.Rmin^2)).*(v0s).^3)),'r--');

hold on;
grid;

ideal_powers=S3(:,5)./(S3(:,3).*8760);
actual_powers=S3(:,2);
[v0s,actual_powers]=quickInterp(S3(:,1),actual_powers,'start',globaldata.Vmin);
[v0s,actual_powers]=quickInterp(v0s,actual_powers,'end',globaldata.Vmax);

plot(v0s,(actual_powers./(0.5*1.225*(pi*(globaldata.Rmax^2-globaldata.Rmin^2))...
    .*(v0s).^3)),'r-'); % Plot actual power curve

plot([v0s(1),v0s(end)],[(16/27),(16/27)],'b-'); % Plot ideal power curve

legend({'Solution - Ignoring Bending/Moment Limits',...
    'Solution - With Shutdown Limits','Betz Curve'},...
    'Location','North','Interpreter','latex','FontSize',12);
title('Power Coefficient Comparison');
xlabel('Wind Speed (m/s)');
ylabel('Power Coefficient');
ylim([0 0.9]);
saveas(f14,'graphs/powerBetzCurvesCoeff.png');

%% Plot blade power profile with tip losses on/off at 15m/s
% Get more indepth blade data at 15 m/s
[~, ~,S2,~,~,~]=WTSingleVelocity(15, x(1), x(2), x(3),...
    globaldata.Rmax,globaldata.Rmin, globaldata.B,globaldata);
statustablematrix(S2,{'r', 'a', 'adash', 'alpha', 'Cn', 'Ct', 'tol',...
    'i','Vrel','Mt','Mn','Pt','Pn'},'status/optSol_S2.png',...
    'Rotor Profile 15m/s','figure',1);
Power=S2(:,10)*globaldata.B*globaldata.w;
f10=figure(10);
plot(S2(:,1),Power,'b-'); % Plot power with tip losses at 15 m/s across blade
hold on;
grid;

% Turn off tip loss and calculate again
globaldata.flags.tiploss=false;
[Mtot_t, Mtot_n,S2,Power,def_max_y,def_max_z]=WTSingleVelocity(15, x(1),...
    x(2), x(3), globaldata.Rmax,globaldata.Rmin, globaldata.B,globaldata);
Power=S2(:,10)*globaldata.B*globaldata.w;
plot(S2(:,1),Power,'r-'); % Plot power without tip losses at 15 m/s across blade
title('Tip Losses Effect at 15m/s');
xlabel('Blade Radius (m)');
ylabel('Power (W)');
legend({'With Tip Losses', 'Without Tip Losses'},...
    'Interpreter','latex','FontSize',11,'Location',...
    'Northwest');
saveas(f10,'graphs/bladeTipLoss.png');

globaldata.flags.tiploss=true; % Reset flag

%% Plot probability against V0
% Create velocity space
v0s=linspace(globaldata.Vmin,globaldata.Vmax,100);
v0s_delta=v0s(2)-v0s(1);
% Calculate Weibull probabilities at v0 using narrow velocity bands
probs=windProb(globaldata.A,globaldata.k,v0s-(v0s_delta/2),v0s+(v0s_delta/2));
f11=figure(11);
plot(v0s,probs); % Plot probabilities against wind speeds
grid;
title('Weibull Probabilities of Wind Speeds');
xlabel('Wind Speed (m/s)');
ylabel('Probability');
saveas(f11,'graphs/windProbs.png');

%% Plot Deflection
f12=figure(12);
% Find highest speed solution index
v_powers=S3(:,2)';
highestSpeedIndex=find(v_powers>0,1,'last');

% Find speed at which it occurs (by element ONLY);
highestSpeed=S3(highestSpeedIndex,1);
% Evaluate blade at highest speed for more in depth deflection data
[~,~,S2_maxdef,~,~,~,defz_array]=WTSingleVelocity(highestSpeed, x(1), x(2), x(3),...
    globaldata.Rmax,globaldata.Rmin, globaldata.B,globaldata);
% Find deflection at tip for this scenario
maxDeflect=abs(round(defz_array(end),3));
% Create the radius space for the blade
radius_space=linspace(globaldata.Rmin,globaldata.Rmax,...
    round(globaldata.Rmax-globaldata.Rmin,0)+1);

% Plot the blade profile mirrored. Not technically correct as 3 blade design
% does not have symmetric design in this orientation
plot(horzcat(flip(abs(defz_array)),abs(defz_array)),...
    horzcat(radius_space,radius_space+globaldata.Rmax)-20,'r-','LineWidth',2);

hold on;
grid;

% Plot on to scale turbine tower etc.
plot([0,3.5],[0,0],'LineWidth',3,'Color','b',...
    'LineStyle','--');
plot([3.2,3.2],[0.5,-35],'LineWidth',1,'Color',...
    'b','LineStyle','--');
% Add graph decoration
title('Blade Tip Deflection Profile');
xlabel('Deflection (m)');
ylabel('Blade (m)');
xlim([-15, 15]);
ylim([-35, globaldata.Rmax+3]);

annotation('textarrow',[0.2,0.4],[0.7,0.7]);
annotation('textarrow',[0.2,0.4],[0.5,0.5]);
annotation('textarrow',[0.2,0.4],[0.8,0.8]);
annotation('textarrow',[0.2,0.4],[0.4,0.4]);
annotation('textbox',[0.2 0.44 0.2,0.2],'String',...
        ['Wind Speed = ' num2str(highestSpeed) ' m/s'],...
        'Interpreter','Latex','FitBoxToText','on','HorizontalAlignment',...
        'center','FontSize',12,'LineStyle','none');
annotation('textbox',[0.65 0.34 0.2,0.2],'String',...
        ['Max Deflection' newline '=' newline  num2str(maxDeflect) ' m'],...
        'Interpreter','Latex','FitBoxToText','on','HorizontalAlignment',...
        'center','FontSize',14);
set(gcf,'position',[800,200,550,600]);
% Save
saveas(f12,'graphs/maxDeflection.png');


%% Plot Mt and Alpha at different Velocities
f15=figure(15); % Moment Graph
f16=figure(16); % Alpha Graph
clf(15);clf(16); % Clear graphs first.
globaldata.flags.overridelimits=true;
globaldata.flags.tiploss=false;
vc=5;
vspace=linspace(5,25,vc);
MtHold=zeros(20,vc);
for i=1:vc
    [~,~,S2_ol,~,~,~,~]=WTSingleVelocity(vspace(i), x(1), x(2), x(3),...
    globaldata.Rmax,globaldata.Rmin, globaldata.B,globaldata);
figure(15)
hold on;
grid on;
plot(S2_ol(:,1),(S2_ol(:,10)./1e3),'DisplayName',[num2str(vspace(i)) ' m/s']);
figure(16)
hold on;
grid on;
plot(S2_ol(:,1),(rad2deg(S2_ol(:,4))),'DisplayName',[num2str(vspace(i)) ' m/s']);
end
figure(15)
leg=legend('Location', 'Northwest');
set(leg, 'Interpreter', 'Latex');
set(leg, 'FontSize', 11);
title('Tangential Moments Along the Blade at Different Wind Speeds');
xlabel('Blade Radius (m)');
ylabel('Tangential Moment (kNm)');
saveas(f15,'graphs/momentStalling.png');

figure(16)
leg=legend('Location', 'Northeast');
set(leg, 'Interpreter', 'Latex');
set(leg, 'FontSize', 11);
title('Flow Angle Alpha Across the Blade at Different Wind Speeds');
xlabel('Blade Radius (m)');
ylabel('Alpha Angle (°)');
saveas(f16,'graphs/alphaStalling.png');

globaldata.flags.tiploss=true; % Set flags to default
globaldata.flags.overrideLimits=false;

