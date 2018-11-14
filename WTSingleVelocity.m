function [Mtot_t, Mtot_n,S2,Power,def_max_y,def_max_z,deflection_distance_z] =...
            WTSingleVelocity(V0, Theta0, ThetaTwist, c_grad, TipRadius,...
            RootRadius, B,globaldata)
        
%S2: WHOLE ROTOR - loop WTInducedCalcs to find the values for all radii,
%then integrate these to get the normal and tangential moment at the blade
%root.

%% Set Up
N=19; %set radius element count
radius_delta=(TipRadius-RootRadius)/(N); %Increment in radius
S2=zeros(N,13); % Pre-allocate empty matrix to hold key values

% Convinience variables for mean chord and rotational speed
c_mean_local=globaldata.c_mean;
w_local=globaldata.w;

% Pre-allocate empty arrays for nodal powers needed for deflection.
pts=zeros(1,N+1); % Pys
pns=zeros(1,N+1);% Pzs

%% Main Loop
% Loop through all elements (for annulus calcs) and nodes (for deflection calcs)
% Note the final node (j=2N+1) is ommitted as it is a boundary condition
% set to power = 0.
for j=1:(2*N)
    
    % Calculate local radius
    local_radius=RootRadius+((j-1)*0.5*radius_delta);
    % Calculate local chord value using chord gradient
    local_chord=c_mean_local+((local_radius-((TipRadius-RootRadius)/2))*c_grad);
    % Calcualte local theta angle of the blade
    local_theta=Theta0+(local_radius*ThetaTwist);
    
    % Calculate local coefficients for the annuulus centre
    [a_s1, adash_s1, alpha, Cn_s1, Ct_s1, Vrel, tol_s1, i_s1]=...
        WTInducedCalcs(0.2,0.2,V0,w_local,local_radius,local_theta,...
        local_chord,TipRadius,globaldata);
    
    
    %Calculate each moment and power.
    Mt=(0.5*1.225*local_chord*Ct_s1*Vrel^2)*radius_delta*local_radius;
    Mn=(0.5*1.225*local_chord*Cn_s1*Vrel^2)*radius_delta*local_radius;
    pt=Mt/(radius_delta*local_radius);
    pn=Mn/(radius_delta*local_radius);
    
    % Alternate values are used for the main annulus calculation and
    % The deflection calculations.
    % Odd interations are nodes for deflection needing node power.
    % Even interations are elements for annulus calcs
    if mod(j,2)==1
        % put ps into their array
        pts(round(j/2,0))=pt;
        pns(round(j/2,0))=pn;
    else
        % Put annulus results into matrix
        S2(j/2,:)=[local_radius, a_s1, adash_s1, alpha, Cn_s1, Ct_s1,...
            tol_s1, i_s1,Vrel,Mt,Mn,pt,pn];
    end
end

%% Blade/Tip Deflection
% Following the method in Hansen Chpater 11
% Note that t(angential) is y-axis
%           n(ormal)     is z-axis
% These notations are used interchangably

% Pre-allocate arrays
Ty=zeros(1,N+1);
Tz=zeros(1,N+1);
My=zeros(1,N+1);
Mz=zeros(1,N+1);

for p=N:-1:1
    % Calcualte y/z shear forces and moments at each node.
    % Tip node N+1 left at zero.
    force_y_p=pts(p+1);
    force_y_p1=pts(p);
    force_z_p=pns(p+1);
    force_z_p1=pns(p);
    Ty(p)=Ty(p+1)+(1/2*(force_y_p+force_y_p1)*radius_delta);
    Tz(p)=Tz(p+1)+(1/2*(force_z_p+force_z_p1)*radius_delta);
    My(p)=My(1,p+1)-(radius_delta*Tz(p+1))-((force_z_p1/6)+(force_z_p/3))*radius_delta^2;
    Mz(p)=Mz(1,p+1)+(radius_delta*Ty(p+1))+((force_y_p1/6)+(force_y_p/3))*radius_delta^2;
end


% Calculate the value of theta and chord at each node.
node_thetas=linspace(Theta0,Theta0+((TipRadius-RootRadius)*ThetaTwist),N+1);
node_chords=linspace(c_mean_local+((RootRadius-((TipRadius-RootRadius)/2))*c_grad),...
    c_mean_local+((TipRadius-((TipRadius-RootRadius)/2))*c_grad),N+1);

% Calculate the moments relative to the principal axes
M1=My.*cos(node_thetas)-Mz.*sin(node_thetas);
M2=My.*sin(node_thetas)+Mz.*cos(node_thetas);

% Calculate curvatures and make relative to principal axes
k1=M1./EIcalc(node_chords);
k2=M2./EI2calc(node_chords);

kz=-k1.*sin(node_thetas) + k2.*cos(node_thetas);
ky=k1.*cos(node_thetas)+k2.*sin(node_thetas);

% Pre-allocate arrays for deflection values
deflection_angles_y=zeros(1,N+1);
deflection_angles_z=zeros(1,N+1);
deflection_distance_y=zeros(1,N+1);
deflection_distance_z=zeros(1,N+1);

for q=1:N
    % Loop through nodes and calculate deflection as per Hansen Chapter 11
    % deflection angle
    deflection_angles_y(q+1)=deflection_angles_y(1,q)+0.5*(ky(1,q+1)+ky(1,q))*radius_delta;
    deflection_angles_z(q+1)=deflection_angles_z(1,q)+0.5*(kz(1,q+1)+kz(1,q))*radius_delta;
    % Deflection amount
    deflection_distance_y(q+1)=deflection_distance_y(1,q)+...
        deflection_angles_z(1,q)*radius_delta+...
        ((kz(q+1)/6)+(kz(q)/3))*radius_delta^2;
    deflection_distance_z(q+1)=deflection_distance_z(1,q)+...
        deflection_angles_y(1,q)*radius_delta+...
        ((ky(q+1)/6)+(ky(q)/3))*radius_delta^2;
end

% Calculate maximum deflection in each axis.
def_max_y=deflection_distance_y(N+1);
def_max_z=deflection_distance_z(N+1);

%% Moments
Mtot_t=sum(S2(:,10)); % Sum moments across the blade - Tangential
Mtot_n=sum(S2(:,11)); % Sum moments across the blade - Normal
Power=Mtot_t*B*globaldata.w; % Calculate power generated by blade.

% Deprecated
Cp=Power/(0.5*1.225*(pi*(TipRadius^2-RootRadius^2))*V0^3); % Calculate Cp

end