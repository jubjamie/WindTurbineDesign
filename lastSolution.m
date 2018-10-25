global Hhub dhub Rmin Rmax c_mean M_rootmax F_Ymax rho_blade EI_blade Vmin Vmax A k w 
progressbar('Calculating Power', 'Solving Rotor', 'Finding Local Induced Flow', 'Parsing Solution');
        progressbar([],[],[],1);
        [diff, AEP, S3] = WTVelocityRange(x, A, k, w, c_mean, Rmax, Rmin, 3, Vmin, Vmax);
        statustablematrix(S3,{'V0', 'Power', 'Probability', 'AEP', 'Ideal_AEP', 'Difference', 'Efficiency'},false,'Section 3 AEP Nodal Solution','figure',1.3);
        IAEP=sum(S3(:,5));
        statustablematrix([xdeg(1), xdeg(2), xdeg(3), AEP,IAEP,(IAEP-AEP),(AEP/IAEP)],{'Theta','Theta_Twist','c_grad','AEP', 'Ideal_AEP', 'Diff', 'Fraction'},'status/optSol.png','Section 3 AEP Total Solution','figure',1.3);