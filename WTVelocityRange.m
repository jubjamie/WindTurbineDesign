function [total_diff, AEP, S3] = WTVelocityRange(bladeConfig, A, k, omega, MeanChord, TipRadius, RootRadius, B, MinV0, MaxV0,globaldata)
%3: ANNUAL ENERGY - loop WTSingleVelocity to find the moments across the
%entire velocity range. Combine this with the frequency information to get
%the AEP.

N=20; % Number of nodes to evaluate
V0delta=(MaxV0-MinV0)/N; % Find the velocity delta for each node
S3=zeros(N,8); %Create empty matrix for S3 results
% Pre-allocate arrays
powerHold=zeros(1,N+1); % Blade Powers
momentHold=zeros(1,N+1); % Root Bending Moments
def_yHold=zeros(1,N+1); % Tip Deflection in y
def_zHold=zeros(1,N+1); % Tip Deflection in z

%% Parallel Processing of Velocities
% Implement multi-thread operations to loop through the different velocities
% The parallel processing means a blade can be evaluated at multiple velocities
% at the same time/wall-time. This can improve optimisation wall-times by
% 4-10x faster performance.

parfor pn=1:N+1
    lowerbandv0=MinV0+((pn-1)*V0delta); % Calculate lower V0 in V band
    % Evaluate blade at a V0
    [~,momentHold(pn),~,powerHold(pn),def_yHold(pn),def_zHold(pn)]=...
        WTSingleVelocity(lowerbandv0, bladeConfig(1), bladeConfig(2),...
        bladeConfig(3), TipRadius,RootRadius, B,globaldata);
end

%% AEP Calculations
% Evaluate power at a velocity band e.g. 5-6 m/s giving V0=5.5 m/s

% Loop through each band
for vn=1:N
    % Calculate the token local velocity and band values
    local_v=MinV0+((vn-0.5)*V0delta);
    lowerbandv0=MinV0+((vn-1)*V0delta);
    upperbandv0=lowerbandv0+V0delta;
    
    % Check if bending moments or tip deflection are limits
    % This can be overrided by setting the global flag 'overrideLimits'=True
    % If a limit is breached, the turbine is "turned off" by setting the
    % power at that velocity to zero.
    if(max(momentHold(vn),momentHold(vn+1))>globaldata.M_rootmax &&...
            globaldata.flags.overrideLimits==false)
        local_power=0; % Turn off turbine
        %disp(['Moment Limit Exceeded: ' num2str(max(momentHold))]);
    elseif(max(abs(def_zHold(vn)),abs(def_zHold(vn+1)))>3 &&...
            globaldata.flags.overrideLimits==false)
        local_power=0; % Turn off turbine
        %disp(['Deflections Exceeded - z: ' num2str(abs(def_zHold(end)))]);
    else
        % Otherwise calculate local power
        local_power=0.5*(powerHold(1,vn)+powerHold(1,vn+1));
        if local_power<0
            local_power=0;
        end
        %disp(['Deflections Exceeded - z: ' num2str(abs(def_zHold(end)))]);
    end
    
    % Calculate Weibull probability for wind speed
    local_prob=windProb(A,k,lowerbandv0,upperbandv0);
    % Calculate ideal power with same conditions with betz Limit
    local_ideal_power=(0.5*1.225*(pi*(TipRadius^2-RootRadius^2))*local_v^3)*(16/27);
    
    % Calculate local AEP and the difference to ideal
    local_AEP=local_power*local_prob*8760;
    local_AEP_ideal=local_ideal_power*local_prob*8760;
    local_diff=local_AEP_ideal-local_AEP;
    local_eff=local_AEP/local_AEP_ideal;
    
    % Save this velocity and data into the S3 matrix
    S3(vn,:)=[local_v, local_power, local_prob, local_AEP, local_AEP_ideal,...
        local_diff, local_eff, abs(def_zHold(vn))];
end

% Calculate total AEP for wind range by summing velocity band values
AEP=sum(S3(:,4));
% Calculate the difference between the calcualted AEP and Ideal  for use as
% Cost in optimiser.
total_diff=sum(S3(:,6));

end