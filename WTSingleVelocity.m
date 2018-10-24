function [Mt, Mn] = WTSingleVelocity(V0, Theta0, ThetaTwist, MeanChord, c_grad, TipRadius,RootRadius, omega, B)
%2: WHOLE ROTOR - loop WTInducedCalcs to find the values for all radii,
%then integrate these to get the normal and tangential moment at the blade
%root.
global Hhub dhub Rmin Rmax c_mean M_rootmax F_Ymax rho_blade EI_blade Vmin Vmax A k w

N=18; %set radius node count
radius_delta=(TipRadius-RootRadius)/N; %Increment in radius
S1=zeros(N,7); %Creat empty matrix to hold values

for i=1:N
    local_radius=TipRadius+((N-1)*radius_delta); % Calculate local radius from increment
    local_chord=c_mean+((local_radius-((TipRadius-RootRadius)/2))*c_grad); % Calculate tapered chord
    local_theta=Theta0+(local_radius*ThetaTwist);
    s1_out=WTInducedCalcs(0,0,V0,w,local_radius,local_theta,local_chord,3);
    S1(i,:)=s1_out;

end
statustablematrix(S1,{'a', 'adash', 'phi', 'Cn', 'Ct', 'tol', 'i'},'status/s2_multivalidation.png',true);

Mt=0;
Mn=0;

end