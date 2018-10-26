function [Mt, Mn,S2,Power] = WTSingleVelocity(V0, Theta0, ThetaTwist, c_grad, TipRadius,RootRadius, B)
%2: WHOLE ROTOR - loop WTInducedCalcs to find the values for all radii,
%then integrate these to get the normal and tangential moment at the blade
%root.
global Hhub dhub Rmin Rmax c_mean M_rootmax F_Ymax rho_blade EI_blade Vmin Vmax A k w logid

N=19; %set radius node count
radius_delta=(TipRadius-RootRadius)/(N); %Increment in radius
S2=zeros(N,11); %Creat empty matrix to hold values

for j=1:N
    progressbar([],j/(N+1),[],[]);
    local_radius=RootRadius+((j-1)*radius_delta)+(radius_delta/2); % Calculate local radius from centre increment TODO shorten this
    local_chord=c_mean+((local_radius-((TipRadius-RootRadius)/2))*c_grad); % Calculate tapered chord
    local_theta=Theta0+(local_radius*ThetaTwist);
    [a_s1, adash_s1, phi_s1, Cn_s1, Ct_s1, tol_s1, i_s1]=WTInducedCalcs(0,0,V0,w,local_radius,local_theta,local_chord,3);
    [a_s1, adash_s1, phi_s1, Cn_s1, Ct_s1, Vrel, tol_s1, i_s1]=WTInducedCalcs(0,0,V0,w,local_radius,local_theta,local_chord,3);
    if a_s1<0 || adash_s1<0
        fprintf(logid,'S2 Negatives Detected: a=%f, adash=%f Calling function: WTSingleVelocity(%f, %f, %f, %f, %f,%f,%f)\r\n',a_s1, adash_s1,V0, Theta0, ThetaTwist, c_grad, TipRadius,RootRadius, B);
    end
    S2(j,1:8)=[local_radius, a_s1, adash_s1, phi_s1, Cn_s1, Ct_s1, tol_s1, i_s1];
    
    %Calculate each moment
    Vrel=((V0*(1-a_s1))^2 + (w*local_radius*(1+adash_s1))^2)^0.5;
    Mt=(0.5*1.225*local_chord*Ct_s1*Vrel^2)*radius_delta*local_radius;
    Mn=(0.5*1.225*local_chord*Cn_s1*Vrel^2)*radius_delta*local_radius;
    S2(j,9:11)=[Vrel,Mt,Mn];

end

Mtot_t=sum(S2(:,10));
Mtot_n=sum(S2(:,11));
Power=Mtot_t*B*w;
Cp=Power/(0.5*1.225*(pi*(TipRadius^2-RootRadius^2))*V0^3);
%{
if Cp<(16/27)
    disp("Below Betz Limit");
else
    disp('Unrealistic - Above Betz Limit');
end
%}
end