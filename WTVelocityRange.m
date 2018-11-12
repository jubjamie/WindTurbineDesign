function [total_diff, AEP, S3] = WTVelocityRange(bladeConfig, A, k, omega, MeanChord, TipRadius, RootRadius, B, MinV0, MaxV0,globaldata)
%3: ANNUAL ENERGY - loop WTSingleVelocity to find the moments across the
%entire velocity range. Combine this with the frequency information to get
%the AEP.

%Banded velocity calcs for wind distribution.
N=20; % Number of nodes to evaluate
V0delta=(MaxV0-MinV0)/N; % Find the velocity delta for each node
S3=zeros(N,8); %Create empty matrix for S3 results
local_upper_power=0;
upperbandv0=0;
powerHold=zeros(1,N+1);
momentHold=zeros(1,N+1);
def_yHold=zeros(1,N+1);
def_zHold=zeros(1,N+1);

parfor pn=1:N+1
        lowerbandv0=MinV0+((pn-1)*V0delta);
        [~,momentHold(pn),~,powerHold(pn),def_yHold(pn),def_zHold(pn)]=WTSingleVelocity(lowerbandv0, bladeConfig(1), bladeConfig(2), bladeConfig(3), TipRadius,RootRadius, B,globaldata);
end

for vn=1:N

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
    
    if(max(momentHold(vn),momentHold(vn+1))>globaldata.M_rootmax && globaldata.flags.overrideLimits==false)
        local_power=0;
        disp(['Moment Limit Exceeded: ' num2str(max(momentHold))]);
    elseif(max(abs(def_zHold(vn)),abs(def_zHold(vn+1)))>3 && globaldata.flags.overrideLimits==false)
        local_power=0;
        disp(['Deflections Exceeded - z: ' num2str(abs(def_zHold(end)))]);
    else
    local_power=0.5*(powerHold(1,vn)+powerHold(1,vn+1));
        if local_power<0
            local_power=0;
        end
    %disp(['Deflections Exceeded - z: ' num2str(abs(def_zHold(end)))]);
    end
    local_prob=windProb(A,k,lowerbandv0,upperbandv0);
    
    local_ideal_power=(0.5*1.225*(pi*(TipRadius^2-RootRadius^2))*local_v^3)*(16/27); % Ideal power using Betz limit.
    
    local_AEP=local_power*local_prob*8760;
    local_AEP_ideal=local_ideal_power*local_prob*8760;
    local_diff=local_AEP_ideal-local_AEP;
    local_eff=local_AEP/local_AEP_ideal;
    
    
    S3(vn,:)=[local_v, local_power, local_prob, local_AEP, local_AEP_ideal, local_diff, local_eff, abs(def_zHold(vn))];
end

AEP=sum(S3(:,4));
if AEP<0
    disp(['negative AEP >' num2str(bladeConfig(1)) ' - ' num2str(bladeConfig(2)) ' - ' num2str(bladeConfig(3))]);
end
    
total_diff=sum(S3(:,6));

end