close all
%% Get S3 Data
[diff, AEP, S3] = WTVelocityRange(x, globaldata.A, globaldata.k, globaldata.w, globaldata.c_mean, globaldata.Rmax, globaldata.Rmin, 3, globaldata.Vmin, globaldata.Vmax,globaldata);
statustablematrix(S3,{'V0', 'Power', 'Probability', 'AEP', 'Ideal_AEP', 'Difference', 'Efficiency', 'Tip_Deflection'},false,'Section 3 AEP Nodal Solution','figure',1.3);
IAEP=sum(S3(:,5));
statustablematrix([xdeg(1), xdeg(2), xdeg(3), AEP,IAEP,(IAEP-AEP),(AEP/IAEP)],{'Theta','Theta_Twist','c_grad','AEP', 'Ideal_AEP', 'Diff', 'Fraction'},'status/optSol.png','Section 3 AEP Total Solution','figure',1.3);

%% Plot graph of powers.
%S3-1 vs S3-2
f6=figure(6);

[v0s,powers]=quickInterp(S3(:,1),S3(:,4),'start',globaldata.Vmin);
[v0s,powers]=quickInterp(v0s,powers,'end',globaldata.Vmax);
plot(v0s,(powers./1e6),'-b');
hold on;
[v0s,powers]=quickInterp(S3(:,1),S3(:,5),'start',globaldata.Vmin);
[v0s,powers]=quickInterp(v0s,powers,'end',globaldata.Vmax);
plot(v0s,(powers./1e6),'-r');
grid
xlabel('Wind Speed (m/s)');
ylabel('Power x Probability (MW)');
legend({'Found Solution', 'Ideal AEP Solution'},...
    'Location','Northeast','Interpreter','latex','FontSize',12);
set(gcf,'position',[200,200,650,450])

annotation('textbox',[.62 .4 .3 .3],'String',['Found Solution' newline ...
    '$\theta_0$: ' num2str(round(xdeg(1),2)) '$^\circ$'  ...
    newline '$\theta_{tw}$: ' num2str(round(xdeg(2),2)) '$^\circ$/m' newline...
    '$c_{grad}$: ' num2str(round(xdeg(3),4))],'FitBoxToText','on','Interpreter','Latex','FontSize',13);

saveas(f6,'status/powerLastSolution.png');
saveas(f6,'graphs/powerLastSolution.png');

% Change settings
globaldata.flags.tiploss=false;
globaldata.flags.overrideLimits=true;

[diff, AEP, S3_ntl] = WTVelocityRange(x, globaldata.A, globaldata.k, globaldata.w, globaldata.c_mean, globaldata.Rmax, globaldata.Rmin, 3, globaldata.Vmin, globaldata.Vmax,globaldata);

% Revert settings
globaldata.flags.tiploss=true;
globaldata.flags.overrideLimits=false;

[v0s,powers]=quickInterp(S3_ntl(:,1),S3_ntl(:,4),'start',globaldata.Vmin);
[v0s,powers]=quickInterp(v0s,powers,'end',globaldata.Vmax);

plot(v0s,(powers./1e6),'--c');
legend({'Found Solution', 'Ideal AEP Solution','Tip Losses Neglected'},...
    'Location','Northeast','Interpreter','latex','FontSize',12);

globaldata.flags.tiploss=true;

saveas(f6,'status/powerLastSolutionCombinedNoTipLoss.png');
saveas(f6,'graphs/powerLastSolutionCombinedNoTipLoss.png');

%% Plot Power Curve vs. Betz Curve
f13=figure(13);

% Plot solution curve overriding limits
% Change settings
globaldata.flags.overrideLimits=true;

[diff, AEP, S3_os] = WTVelocityRange(x, globaldata.A, globaldata.k, globaldata.w, globaldata.c_mean, globaldata.Rmax, globaldata.Rmin, 3, globaldata.Vmin, globaldata.Vmax,globaldata);

% Revert settings
globaldata.flags.overrideLimits=false;

actual_powers_os=S3_os(:,2);
[v0s,actual_powers_os]=quickInterp(S3_os(:,1),actual_powers_os,'start',globaldata.Vmin);
[v0s,actual_powers_os]=quickInterp(v0s,actual_powers_os,'end',globaldata.Vmax);
plot(v0s,(actual_powers_os./1e6),'r--');

hold on;
grid;

ideal_powers=S3(:,5)./(S3(:,3).*8760);
actual_powers=S3(:,2);
[v0s,actual_powers]=quickInterp(S3(:,1),actual_powers,'start',globaldata.Vmin);
[v0s,actual_powers]=quickInterp(v0s,actual_powers,'end',globaldata.Vmax);
plot(v0s,(actual_powers./1e6),'r-');

[v0s,ideal_powers]=quickInterp(S3(:,1),ideal_powers,'start',globaldata.Vmin);
[v0s,ideal_powers]=quickInterp(v0s,ideal_powers,'end',globaldata.Vmax);
plot(v0s,(ideal_powers./1e6),'b-');

legend({'Solution - Ignoring Bending/Moment Limits', 'Solution - With Shutdown Limits','Betz Curve'},...
    'Location','Northwest','Interpreter','latex','FontSize',12);
title('Power Curve Comparison');
xlabel('Wind Speed (m/s)');
ylabel('Power (MW)');
saveas(f13,'graphs/powerBetzCurves.png');



%% Plot blade power profile with tip losses on/off at 15m/s
[~, ~,S2,~,~,~]=WTSingleVelocity(15, x(1), x(2), x(3), globaldata.Rmax,globaldata.Rmin, globaldata.B,globaldata);
statustablematrix(S2,{'r', 'a', 'adash', 'phi', 'Cn', 'Ct', 'tol', 'i','Vrel','Mt','Mn','Pt','Pn'},'status/optSol_S2.png','Rotor Profile 15m/s','figure',1);
Power=S2(:,10)*globaldata.B*globaldata.w;
f10=figure(10);
plot(S2(:,1),Power);
hold on;
grid;
globaldata.flags.tiploss=false;
[Mtot_t, Mtot_n,S2,Power,def_max_y,def_max_z]=WTSingleVelocity(15, x(1), x(2), x(3), globaldata.Rmax,globaldata.Rmin, globaldata.B,globaldata);
%statustablematrix(S2,{'r', 'a', 'adash', 'phi', 'Cn', 'Ct', 'tol', 'i','Vrel','Mt','Mn','Pt','Pn'},'status/optSol_S2.png','Rotor Profile 20m/s','figure',1);
Power=S2(:,10)*globaldata.B*globaldata.w;
plot(S2(:,1),Power);
title('Tip Losses Effect at 15m/s');
xlabel('Blade Radius (m)');
ylabel('Power (W)');
legend({'With Tip Losses', 'Without Tip Losses'},...
    'Location','Northeast','Interpreter','latex','FontSize',11);
saveas(f10,'graphs/bladeTipLoss.png');
globaldata.flags.tiploss=true;

%% Plot probability against V0
% Create velocity space
v0s=linspace(globaldata.Vmin,globaldata.Vmax,100);
v0s_delta=v0s(2)-v0s(1);
probs=windProb(globaldata.A,globaldata.k,v0s-(v0s_delta/2),v0s+(v0s_delta/2));
f11=figure(11);
plot(v0s,probs);
grid;
title('Weibull Probabilities of Wind Speeds');
xlabel('Wind Speed (m/s)');
ylabel('Probability');
saveas(f10,'graphs/windProbs.png');

%% Plot Deflection
f12=figure(12);
% Find highest speed solution index
v_powers=S3(:,2)';
if(all(S3(:,2)>0))
    %No cut off, highest speed is end value
highestSpeedIndex=size(S3,1);
else
highestSpeedIndex=find(v_powers>0,1,'last');
end
maxDeflect=round(S3(highestSpeedIndex,8),3);
highestSpeed=S3(highestSpeedIndex,1);
% Run at highest speed
[~,~,~,~,~,~,defz_array]=WTSingleVelocity(highestSpeed, x(1), x(2), x(3), globaldata.Rmax,globaldata.Rmin, globaldata.B,globaldata);
radius_space=linspace(globaldata.Rmin,globaldata.Rmax,round(globaldata.Rmax-globaldata.Rmin,0)+1);
plot(horzcat(flip(abs(defz_array)),abs(defz_array)),horzcat(radius_space,radius_space+globaldata.Rmax),'r-','LineWidth',2);
hold on;
grid;
plot([0,3.5],[globaldata.Rmax,globaldata.Rmax],'LineWidth',3,'Color','b','LineStyle','--');
plot([3.2,3.2],[globaldata.Rmax+0.5,globaldata.Rmax-35],'LineWidth',1,'Color','b','LineStyle','--');
title('Blade Tip Deflection Profile');
xlabel('Deflection (m)');
ylabel('Blade (m)');
xlim([-15, 15]);
ylim([globaldata.Rmax-35, 2*globaldata.Rmax+3]);
set(gca,'YTickLabel',[]);
annotation('textarrow',[0.2,0.4],[0.7,0.7]);
annotation('textarrow',[0.2,0.4],[0.5,0.5]);
annotation('textarrow',[0.2,0.4],[0.8,0.8]);
annotation('textarrow',[0.2,0.4],[0.4,0.4]);
annotation('textbox',[0.2 0.44 0.2,0.2],'String',['Wind Speed = ' num2str(highestSpeed) ' m/s'],'Interpreter','Latex','FitBoxToText','on','HorizontalAlignment','center','FontSize',12,'LineStyle','none');
annotation('textbox',[0.65 0.34 0.2,0.2],'String',['Max Deflection' newline '=' newline  num2str(maxDeflect) ' m'],'Interpreter','Latex','FitBoxToText','on','HorizontalAlignment','center','FontSize',14);
set(gcf,'position',[800,200,550,600])
saveas(f12,'graphs/maxDeflection.png');


