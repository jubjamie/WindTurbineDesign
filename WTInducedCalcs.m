function [a_out, adash_out, phi_flow, Cn, Ct,Vrel,curr_tol, i] = WTInducedCalcs(a, adash, V0, omega, y, theta, Chord, B)
%1: SINGLE ELEMENT: use an iterative solution to find the values of a,
%adash, phi, Cn and Ct at a particular radius.
global logid

%Convergence Settings
etol=0.0001;
curr_tol=1;
solfnd=false;
looplimit=500;
adash_looplimit=200;

solidity=(B*Chord)/(2*pi*y);
 
%init and adash from function input.
a_in=a;
adash_in=adash;

    for i=1:looplimit
        progressbar([],[],i/(looplimit+1), []);
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
            a_in_relax=(0.05*(a_out-a_in))+a_in;
            if a_in_relax>0.95
                a_in=a_out;
            else
                a_in=a_in_relax;
            end
            
            if i==adash_looplimit
                fprintf(logid,'S1 adash Limit Reached: a=%f, adash=%f Calling function: WTInducedCalcs(%f, %f, %f, %f, %f, %f, %f, %f)\r\n',a_out,adash_out,a, adash, V0, omega, y, theta, Chord, B);
            end
            
            if i<adash_looplimit
                adash_in=(0.05*(adash_out-adash_in))+adash_in;
            else
                adash_in=0;
                adash_out=0;
            end
            
        else
            %If within tollerance then break out and return
            solfnd=true;
            progressbar([],[],1,[]);
            break
        end
       
    end
    
if solfnd==false
%disp(['Convergence failed and terminated after ' num2str(i) ' loops. Returning most recent values.']);
fprintf(logid,'S1 Loop Limit Reached: a=%f, adash=%f Calling function: WTInducedCalcs(%f, %f, %f, %f, %f, %f, %f, %f)\r\n',a_out,adash_out,a, adash, V0, omega, y, theta, Chord, B);
end

end

