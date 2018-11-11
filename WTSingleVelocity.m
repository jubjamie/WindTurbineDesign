function [Mtot_t, Mtot_n,S2,Power,def_max_y,def_max_z] = WTSingleVelocity(V0, Theta0, ThetaTwist, c_grad, TipRadius,RootRadius, B,globaldata)
%2: WHOLE ROTOR - loop WTInducedCalcs to find the values for all radii,
%then integrate these to get the normal and tangential moment at the blade
%root.

N=19; %set radius node count
radius_delta=(TipRadius-RootRadius)/(N); %Increment in radius
S2=zeros(N,13); %Creat empty matrix to hold values

c_mean_local=globaldata.c_mean;
logid_local=globaldata.logid;
w_local=globaldata.w;
etol_local=globaldata.etol;

for j=1:N
    %progressbar([],j/(N+1),[],[]);
    local_radius=RootRadius+((j-1)*radius_delta)+(radius_delta/2); % Calculate local radius from centre increment TODO shorten this
    local_chord=c_mean_local+((local_radius-((TipRadius-RootRadius)/2))*c_grad); % Calculate tapered chord
    local_theta=Theta0+(local_radius*ThetaTwist);
    [a_s1, adash_s1, phi_s1, Cn_s1, Ct_s1, Vrel, tol_s1, i_s1]=WTInducedCalcs(0,0,V0,w_local,local_radius,local_theta,local_chord,B,logid_local,etol_local,TipRadius);
    if a_s1<0 || adash_s1<0
        %fprintf(logid_local,'S2 Negatives Detected: a=%f, adash=%f Calling function: WTSingleVelocity(%f, %f, %f, %f, %f,%f,%f)\r\n',a_s1, adash_s1,V0, Theta0, ThetaTwist, c_grad, TipRadius,RootRadius, B);
    end
    
    
    %Calculate each moment
    Mt=(0.5*1.225*local_chord*Ct_s1*Vrel^2)*radius_delta*local_radius;
    Mn=(0.5*1.225*local_chord*Cn_s1*Vrel^2)*radius_delta*local_radius;
    pt=Mt/(radius_delta*local_radius);
    pn=Mn/(radius_delta*local_radius);
    S2(j,:)=[local_radius, a_s1, adash_s1, phi_s1, Cn_s1, Ct_s1, tol_s1, i_s1,Vrel,Mt,Mn,pt,pn];

end


Ty=zeros(1,N+1);
Tz=zeros(1,N+1);
My=zeros(1,N+1);
Mz=zeros(1,N+1);
for p=N:-1:3
    % Interp Forces at each node
    force_y_p=(1/2*(S2(p,12)+S2(p-1,12)));
    force_y_p1=(1/2*(S2(p-1,12)+S2(p-2,12)));
    force_z_p=(1/2*(S2(p,13)+S2(p-1,13)));
    force_z_p1=(1/2*(S2(p-1,13)+S2(p-2,13)));
    Ty(p)=Ty(p+1)+(S2(p,12)*radius_delta);
    Tz(p)=Tz(p+1)+(S2(p,13)*radius_delta);
    My(1,p)=My(1,p+1)-(radius_delta*Tz(p+1))-((force_z_p1/6)+(force_z_p/3))*radius_delta^2;
    Mz(1,p)=Mz(1,p+1)+(radius_delta*Ty(p+1))+((force_y_p1/6)+(force_y_p/3))*radius_delta^2;
end

% For nodes 1 and two use central approximations.
for p=2:-1:1
    force_y_p=S2(p,12);
    force_y_p1=S2(max(p-1,1),12);
    force_z_p=S2(p,13);
    force_z_p1=S2(max(p-1,1),13);
    Ty(p)=Ty(p+1)+(S2(p,12)*radius_delta);
    Tz(p)=Tz(p+1)+(S2(p,13)*radius_delta);
    My(1,p)=My(1,p+1)-(radius_delta*Tz(p+1))-((force_z_p1/6)+(force_z_p/3))*radius_delta^2;
    Mz(1,p)=Mz(1,p+1)+(radius_delta*Ty(p+1))+((force_y_p1/6)+(force_y_p/3))*radius_delta^2;
end

% M1s and M2s
node_thetas=linspace(Theta0,Theta0+((TipRadius-RootRadius)*ThetaTwist),N+1);
node_chords=linspace(c_mean_local+((RootRadius-((TipRadius-RootRadius)/2))*c_grad),...
    c_mean_local+((TipRadius-((TipRadius-RootRadius)/2))*c_grad),N+1);
M1=My.*cos(node_thetas)-Mz.*sin(node_thetas);
M2=My.*sin(node_thetas)+Mz.*cos(node_thetas);
k1=M1./EIcalc(node_chords);
k2=M2./EI2calc(node_chords);
% kappas
kz=-k1.*sin(node_thetas) + k2.*cos(node_thetas);
ky=k1.*cos(node_thetas)+k2.*sin(node_thetas);

deflection_angles_y=zeros(1,N+1);
deflection_angles_z=zeros(1,N+1);
deflection_distance_y=zeros(1,N+1);
deflection_distance_z=zeros(1,N+1);

for q=1:N
    % deflection angle
    deflection_angles_y(1,q+1)=deflection_angles_y(1,q)+0.5*(ky(1,q+1)+ky(1,q))*radius_delta;
    deflection_angles_z(1,q+1)=deflection_angles_z(1,q)+0.5*(kz(1,q+1)+kz(1,q))*radius_delta;
    % Deflection amount
    deflection_distance_y(1,q+1)=deflection_distance_y(1,q)+...
                                 deflection_angles_z(1,q)*radius_delta+...
                                 ((kz(q+1)/6)+(kz(q)/3))*radius_delta^2;
     deflection_distance_z(1,q+1)=deflection_distance_z(1,q)+...
                                 deflection_angles_y(1,q)*radius_delta+...
                                 ((ky(q+1)/6)+(ky(q)/3))*radius_delta^2;
end

def_max_y=deflection_distance_y(N+1);
def_max_z=deflection_distance_z(N+1);

Mtot_t=sum(S2(:,10));
Mtot_n=sum(S2(:,11));
Power=Mtot_t*B*globaldata.w;
Cp=Power/(0.5*1.225*(pi*(TipRadius^2-RootRadius^2))*V0^3);
%{
if Cp<(16/27)
    disp("Below Betz Limit");
else
    disp('Unrealistic - Above Betz Limit');
end
%}
end