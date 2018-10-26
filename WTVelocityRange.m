function [total_diff, AEP, S3] = WTVelocityRange(bladeConfig, A, k, omega, MeanChord, TipRadius, RootRadius, B, MinV0, MaxV0)
%3: ANNUAL ENERGY - loop WTSingleVelocity to find the moments across the
%entire velocity range. Combine this with the frequency information to get
%the AEP.

%Banded velocity calcs for wind distribution.
N=20; % Number of nodes to evaluate
V0delta=(MaxV0-MinV0)/N; % Find the velocity delta for each node
S3=zeros(N,7); %Create empty matrix for S3 results

for vn=1:N
    progressbar(vn/(N+1),[],[],[]);
    local_v=MinV0+((vn-0.5)*V0delta);
    
    %Band boundary cals - LOWER
    lowerbandv0=MinV0+((vn-1)*V0delta);
        
    %Band boundary cals - Upper
    upperbandv0=MinV0+(vn*V0delta);
        
    %Find node power as mean of boundary values
    [~,~,~,local_power]=WTSingleVelocity(local_v, bladeConfig(1), bladeConfig(2), bladeConfig(3), TipRadius,RootRadius, B);
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