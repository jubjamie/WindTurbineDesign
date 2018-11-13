function [a_out, adash_out, phi_flow, Cn, Ct,Vrel,curr_tol, i] = WTInducedCalcs(a, adash, V0, omega, y, theta, Chord,TipRadius,globaldata)
%1: SINGLE ELEMENT: use an iterative solution to find the values of a,
%adash, phi, Cn and Ct at a particular radius.

curr_tol=1; % Dummy current error tolerance
looplimit=500; % Max number of loops before giving up.
adash_looplimit=150; % Number of loops before holding adash to zero.
relax_looplimit=50; % Number of loops before relaxation factor is used.
etol_local=globaldata.etol;
solidity=(globaldata.B*Chord)/(2*pi*y); % Calcualte solidity for this annulus.

%init and adash from function input.
a_in=a;
adash_in=adash;

% Loop through the a/a' system of equations to find coefficients
for i=1:looplimit
    
    phi_flow=atan(((1-a_in)*V0)/((1+adash_in)*omega*y)); % Calculate phi flow angle
    alpha=phi_flow-theta; %Calculate alpha
    
    % Find relative velocity  the airfoil sees
    Vrel=((V0*(1-a_in))^2 + (omega*y*(1+adash_in))^2)^0.5; 
    re=RE(1.225,Vrel,Chord,1.81e-5); % Calculate Reynolds Number
    [Cl, Cd]=ForceCoefficient(alpha,re); % Calculate/Look Up Cl,Cd
    
    %Convert to normal and tangential forces.
    Cn=(Cl*cos(phi_flow))+(Cd*sin(phi_flow));
    Ct=(Cl*sin(phi_flow))-(Cd*cos(phi_flow));
    
    if(globaldata.flags.tiploss==true)
        %Use Tip Losses if flag set
        %From Hansen
        f=(globaldata.B*(TipRadius-y))/(2*y*sin(phi_flow));
        F=(2/pi)*acos(exp(-f));
        
        % Use tip losses coefficients to calcualte new a/a'
        a_out=1/(((4*F*((sin(phi_flow))^2))/(solidity*Cn))+1);
        adash_out=1/(((4*F*(sin(phi_flow)*cos(phi_flow)))/(solidity*Ct))-1);
    else
        % If tip losses flag is not set, use older BEMT with no tip losses
        a_out=1/(((4*((sin(phi_flow))^2))/(solidity*Cn))+1);
        adash_out=1/(((4*(sin(phi_flow)*cos(phi_flow)))/(solidity*Ct))-1);
    end
    
    
    % Test for convergance/loop settings/errors
    % If a' set to zero, calculate convergence tolerance on a only.
    if i<adash_looplimit
        curr_tol=abs(a_out-a_in)+abs(adash_out-adash_in);
    else
        curr_tol=abs(a_out-a_in);
    end
    
    % Check error tolerance for convergence If not:
    if curr_tol>etol_local
        % Check if loop at point that triggers relaxing
        if(i<relax_looplimit)
            k=1;
        else
            k=0.1;
        end
        
        % Set new a
        a_in=(k*(a_out-a_in))+a_in;
        % See if a near boundaries. Caches NaN,Inf,Complex errors
        % Often caused by floating point allowing a/a' to leave 0<a/a'<1 range
        if a_in>1
            a_in=1;
        elseif a_in<0
            a_in=0;
        end
        
        % If a' still in use
        if i<adash_looplimit
            % Calculate new a'
            adash_in=(k*(adash_out-adash_in))+adash_in;
            % See if a' near boundaries. Caches NaN,Inf,Complex errors
            % Often caused by floating point allowing a/a' to leave 0<a/a'<1 range
            if ~isreal(adash_in)
                % If complex, relax a'
                adash_in=real(adash_in)*0.95;
            end
            if adash_in>1
            adash_in=0.99;
            elseif adash_in<0
            adash_in=0.01;
            end
            
        else
            % If over loop count for a', set to zero.
            adash_in=0;
            adash_out=0;
        end
        
    else
        %If within tollerance then break out and return
        break
    end
    
end

end

