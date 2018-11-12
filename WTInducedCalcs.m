function [a_out, adash_out, phi_flow, Cn, Ct,Vrel,curr_tol, i] = WTInducedCalcs(a, adash, V0, omega, y, theta, Chord, B,logid_local,etol_local,TipRadius,globaldata)
%1: SINGLE ELEMENT: use an iterative solution to find the values of a,
%adash, phi, Cn and Ct at a particular radius.

curr_tol=1;
solfnd=false;
looplimit=500;
adash_looplimit=150;
relax_looplimit=50;

solidity=(B*Chord)/(2*pi*y);

%init and adash from function input.
a_in=a;
adash_in=adash;

for i=1:looplimit
    
    phi_flow=atan(((1-a_in)*V0)/((1+adash_in)*omega*y)); %Calculate phi flow angle
    alpha=phi_flow-theta; %Calculate alpha

    Vrel=((V0*(1-a_in))^2 + (omega*y*(1+adash_in))^2)^0.5; %Find relative velocity  the airfoil sees
    re=RE(1.225,Vrel,Chord,1.81e-5); %Calculate Reynolds Number
    [Cl, Cd]=ForceCoefficient(alpha,re); %Calculate/Look Up Cl,Cd
    
    %Convert to normal and tangential forces.
    Cn=(Cl*cos(phi_flow))+(Cd*sin(phi_flow));
    Ct=(Cl*sin(phi_flow))-(Cd*cos(phi_flow));
    
    if(globaldata.flags.tiploss==true)
        %Tip Losses
        f=(B*(TipRadius-y))/(2*y*sin(phi_flow));
        F=(2/pi)*acos(exp(-f));
        
        a_out=1/(((4*F*((sin(phi_flow))^2))/(solidity*Cn))+1);
        adash_out=1/(((4*F*(sin(phi_flow)*cos(phi_flow)))/(solidity*Ct))-1);
    else
        a_out=1/(((4*((sin(phi_flow))^2))/(solidity*Cn))+1);
        adash_out=1/(((4*(sin(phi_flow)*cos(phi_flow)))/(solidity*Ct))-1);
    end
    
    
    %Test for convergance
    if i<adash_looplimit
        curr_tol=abs(a_out-a_in)+abs(adash_out-adash_in);
    else
        curr_tol=abs(a_out-a_in);
    end
    if curr_tol>etol_local
        if(i<relax_looplimit)
            k=1;
        else
            k=0.1;
        end
        %See if a near boundaries
        a_in=(k*(a_out-a_in))+a_in;
        if a_in>1
            a_in=1;
        elseif a_in<0
            a_in=0;
            %disp('Resetting a to 1');
        end
        
        %Log adash loop limit
        if i==adash_looplimit
            %fprintf(logid_local,'S1 adash Limit Reached: a=%f, adash=%f Calling function: WTInducedCalcs(%f, %f, %f, %f, %f, %f, %f, %f)\r\n',a_out,adash_out,a, adash, V0, omega, y, theta, Chord, B);
        end
        
        if i<adash_looplimit
            %See if adash near boundaries
            adash_in=(k*(adash_out-adash_in))+adash_in;
            %{
            if adash_in>1
            adash_in=1;
            disp('Resetting adash');
            elseif adash_in<0
            adash_in=0;
            disp('Resetting adash');
            end
            %}
            if ~isreal(adash_in)
                adash_in=real(adash_in)*0.95;
            end
            if adash_in>1
            adash_in=0.99;
            %disp('Resetting adash');
            elseif adash_in<0
            %disp(['Resetting adash - ' num2str(adash_in)]);
            adash_in=0.01;
            
            end
            
        else
            adash_in=0;
            adash_out=0;
        end
        
    else
        %If within tollerance then break out and return
        solfnd=true;
        break
    end
    
end

if solfnd==false
    %disp(['Convergence failed and terminated after ' num2str(i) ' loops. Returning most recent values.']);
    %fprintf(logid_local,'S1 Loop Limit Reached: a=%f, adash=%f Calling function: WTInducedCalcs(%f, %f, %f, %f, %f, %f, %f, %f)\r\n',a_out,adash_out,a, adash, V0, omega, y, theta, Chord, B);
end

end

