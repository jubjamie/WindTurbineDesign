progressbar('Calculating Power', 'Solving Rotor', 'Finding Local Induced Flow', 'Parsing Solution');
        progressbar([],[],[],1);
        [diff, AEP, S3] = WTVelocityRange(x, globaldata.A, globaldata.k, globaldata.w, globaldata.c_mean, globaldata.Rmax, globaldata.Rmin, 3, globaldata.Vmin, globaldata.Vmax,globaldata);
        statustablematrix(S3,{'V0', 'Power', 'Probability', 'AEP', 'Ideal_AEP', 'Difference', 'Efficiency'},false,'Section 3 AEP Nodal Solution','figure',1.3);
        IAEP=sum(S3(:,5));
        statustablematrix([xdeg(1), xdeg(2), xdeg(3), AEP,IAEP,(IAEP-AEP),(AEP/IAEP)],{'Theta','Theta_Twist','c_grad','AEP', 'Ideal_AEP', 'Diff', 'Fraction'},'status/optSol.png','Section 3 AEP Total Solution','figure',1.3);