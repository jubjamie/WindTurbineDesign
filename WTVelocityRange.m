function [total_diff, AEP, S3] = WTVelocityRange(bladeConfig, A, k, omega, MeanChord, TipRadius, RootRadius, B, MinV0, MaxV0,globaldata)
%3: ANNUAL ENERGY - loop WTSingleVelocity to find the moments across the
%entire velocity range. Combine this with the frequency information to get
%the AEP.

%Banded velocity calcs for wind distribution.
N=20; % Number of nodes to evaluate
V0delta=(MaxV0-MinV0)/N; % Find the velocity delta for each node
S3=zeros(N,7); %Create empty matrix for S3 results
local_upper_power=0;
upperbandv0=0;
powerHold=zeros(1,N+1);

parfor pn=1:N
        lowerbandv0=MinV0+((pn-1)*V0delta);
        [~,~,~,powerHold(1,pn)]=WTSingleVelocity(lowerbandv0, bladeConfig(1), bladeConfig(2), bladeConfig(3), TipRadius,RootRadius, B,globaldata);
end

for vn=1:N
    progressbar((vn/(N)-0.01),[],[],[]);
    local_v=MinV0+((vn-0.5)*V0delta);
    lowerbandv0=MinV0+((vn-1)*V0delta);
    upperbandv0=lowerbandv0+V0delta;
    %{
    if vn==1
        %Band boundary cals - LOWER
        lowerbandv0=MinV0+((vn-1)*V0delta);
        [~,~,~,local_lower_power]=WTSingleVelocity(lowerbandv0, bladeConfig(1), bladeConfig(2), bladeConfig(3), TipRadius,RootRadius, B);
    else
        lowerbandv0=upperbandv0;
        local_lower_power=local_upper_power;
    end
    %}
        
    %Band boundary cals - Upper
    %upperbandv0=MinV0+(vn*V0delta);
    %[~,~,~,local_upper_power]=WTSingleVelocity(upperbandv0, bladeConfig(1), bladeConfig(2), bladeConfig(3), TipRadius,RootRadius, B);
    
    %Find node power as mean of boundary values
    local_power=0.5*(powerHold(1,vn)+powerHold(1,vn+1));
    local_prob=windProb(A,k,lowerbandv0,upperbandv0);
    
    local_ideal_power=(0.5*1.225*(pi*(TipRadius^2-RootRadius^2))*local_v^3)*(16/27); % Ideal power using Betz limit.
    
    local_AEP=local_power*local_prob*8760;
    local_AEP_ideal=local_ideal_power*local_prob*8760;
    local_diff=local_AEP_ideal-local_AEP;
    local_eff=local_AEP/local_AEP_ideal;
    
    S3(vn,:)=[local_v, local_power, local_prob, local_AEP, local_AEP_ideal, local_diff, local_eff];
end

AEP=sum(S3(:,4));
total_diff=sum(S3(:,6));

end