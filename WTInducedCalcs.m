function [a_out, adash_out, phi_flow, Cn, Ct,Vrel,curr_tol, i] = WTInducedCalcs(a, adash, V0, omega, y, theta, Chord, B)
%1: SINGLE ELEMENT: use an iterative solution to find the values of a,
%adash, phi, Cn and Ct at a particular radius.

%Convergence Settings
etol=0.000001;
curr_tol=1;
solfnd=false;

solidity=(B*Chord)/(2*pi*y);
 
%init and adash from function input.
a_in=a;
adash_in=adash;

    for i=1:500
        phi_flow=atan(((1-a_in)*V0)/((1+adash_in)*omega*y));
        alpha=phi_flow-theta;
        Vrel=((V0*(1-a_in))^2 + (omega*y*(1+adash_in))^2)^0.5;
        re=RE(1.225,Vrel,Chord,1.81e-5);
        [Cl, Cd]=ForceCoefficient(alpha,re);
        Cn=(Cl*cos(phi_flow))+(Cd*sin(phi_flow));
        Ct=(Cl*sin(phi_flow))-(Cd*cos(phi_flow));
        a_out=1/(((4*(sin(phi_flow)^2))/(solidity*Cn))+1);
        adash_out=1/(((4*(sin(phi_flow)*cos(phi_flow))/(solidity*Ct))-1));
        
        %Test for convergance
        curr_tol=abs(a_out-a_in)+abs(adash_out-adash_in);
        if curr_tol>etol
            a_in=(0.1*(a_out-a_in))+a_in;
            adash_in=(0.1*(adash_out-adash_in))+adash_in;
        else
            %If within tollerance then break out and return
            solfnd=true;
            break
        end
       
    end
    
if solfnd==false
disp(["Convergence failed and terminated after " i " loops. Returning most recent values."]);
end

end

