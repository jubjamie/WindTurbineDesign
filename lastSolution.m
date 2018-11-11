close all
[diff, AEP, S3] = WTVelocityRange(x, globaldata.A, globaldata.k, globaldata.w, globaldata.c_mean, globaldata.Rmax, globaldata.Rmin, 3, globaldata.Vmin, globaldata.Vmax,globaldata);
statustablematrix(S3,{'V0', 'Power', 'Probability', 'AEP', 'Ideal_AEP', 'Difference', 'Efficiency', 'Tip_Deflection'},false,'Section 3 AEP Nodal Solution','figure',1.3);
IAEP=sum(S3(:,5));
statustablematrix([xdeg(1), xdeg(2), xdeg(3), AEP,IAEP,(IAEP-AEP),(AEP/IAEP)],{'Theta','Theta_Twist','c_grad','AEP', 'Ideal_AEP', 'Diff', 'Fraction'},'status/optSol.png','Section 3 AEP Total Solution','figure',1.3);

% Plot graph of powers.
%S3-1 vs S3-2
f6=figure(6);
plot(S3(:,1),(S3(:,4)./1e6),'-b');
hold on;
plot(S3(:,1),(S3(:,5)./1e6),'-r');
grid
xlabel('Wind Speed (m/s)');
ylabel('Power x Probability (MW)');
legend({['Found Solution' newline '$\theta$: ' num2str(round(xdeg(1),2)) '$^\circ$'  ...
    newline '$\theta_{tw}$: ' num2str(round(xdeg(2),2)) '$^\circ$/m' newline...
    '$c_{grad}$: ' num2str(round(xdeg(3),4))], 'Ideal AEP Solution'},...
    'Location','Northeast','Interpreter','latex','FontSize',12);
set(gcf,'position',[200,200,650,450])
saveas(f6,'status/powerLastSolution.png');

% Change settings
globaldata.flags.tiploss=false;
globaldata.flags.overrideLimits=true;

[diff, AEP, S3_ntl] = WTVelocityRange(x, globaldata.A, globaldata.k, globaldata.w, globaldata.c_mean, globaldata.Rmax, globaldata.Rmin, 3, globaldata.Vmin, globaldata.Vmax,globaldata);

% Revert settings
globaldata.flags.tiploss=true;
globaldata.flags.overrideLimits=false;

plot(S3_ntl(:,1),(S3_ntl(:,4)./1e6),'--c');
legend({['Found Solution' newline '$\theta$: ' num2str(round(xdeg(1),2)) '$^\circ$'  ...
    newline '$\theta_{tw}$: ' num2str(round(xdeg(2),2)) '$^\circ$/m' newline...
    '$c_{grad}$: ' num2str(round(xdeg(3),4))], 'Ideal AEP Solution','Tip Losses Neglected'},...
    'Location','Northeast','Interpreter','latex','FontSize',12);