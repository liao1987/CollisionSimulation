% Created by ktliao
clc;clear;%clear all;


nTrial = 10000;
simPrefix = 'Direct';
simStartTime = clock
simStartTimePrinted = sprintf('%04d_%02d_%02d_%02d%02d%02',simStartTime(1),simStartTime(2),simStartTime(3),simStartTime(4),simStartTime(5),simStartTime(6))

%%
SystemParams.nUE = 2;
SystemParams.ueRB = 6;
SystemParams.totalRB = 15;
SystemParams.orderedIndex = 1:SystemParams.totalRB;
SystemParams.cyclicShiftRange = [0 11];
SystemParams.readoutIndex = 1:SystemParams.totalRB;
SystemParams.codeMethod = 2;
SystemParams.spreadingFactor = 3;
SystemParams.circularOnOff = 0;
SystemParams.intlvSizeMatrix = [5 3];
%SystemParams.intlvSizeMatrix = [3 5 ;4 4 ;5 3];
%SystemParams.intlvSizeMatrix = [5 10; 6 9 ; 10 5];

%%
numOfRBCollide = zeros(nTrial,SystemParams.nUE);
numOfCodeCollide = zeros(nTrial,SystemParams.nUE);
numOfRBAccess = zeros(nTrial,SystemParams.totalRB );
numOfUECollect =  zeros(SystemParams.totalRB,SystemParams.nUE+1);
%%
for u_ = 1:SystemParams.nUE
    % UE object generation
    UE(u_) = NetworkElement.UE_Parameters;
end
for n_ = 1:nTrial
        ueCodeTable = zeros(SystemParams.totalRB,SystemParams.nUE);
        ueRBTable   = zeros(SystemParams.totalRB,SystemParams.nUE);
    for u_ = 1:SystemParams.nUE
        %UE(u_).UE_IntlvParameterGen(SystemParams);
        UE(u_).UE_DirectParameterGen(SystemParams);
        [tempRB tempCode]= UE(u_).getResourcePatterns;        
        [sortedPhyIndex sortedOrder] = sort(tempRB);
        ueCodeTable(sortedPhyIndex,u_) = tempCode(sortedOrder);
        ueRBTable(sortedPhyIndex,u_) = sortedPhyIndex;
    end
    
    ueRBMarked = logical( ueRBTable);
    sumRBMarked = sum(ueRBMarked.');  
    for t_ = 0:SystemParams.nUE
        
        binIndicator=find(sumRBMarked==t_);
        numOfUECollect(binIndicator,t_+1)=numOfUECollect(binIndicator,t_+1)+1;
        
    end
    
    
    collideTable = zeros(SystemParams.totalRB,SystemParams.nUE); 
    [nRBAccess]=ResourceAccessDetection(SystemParams,ueRBTable);
    [RBCollideTable totalRBCollide] = CollisionDetection(SystemParams,ueRBTable);
    [codeCollideTable totalCodeCollide] = CollisionDetection(SystemParams,ueCodeTable);

    numOfRBCollide(n_,:) = totalRBCollide;
    numOfCodeCollide(n_,:) = totalCodeCollide;
    numOfRBAccess(n_,:) = nRBAccess;
end

for l = 1:SystemParams.nUE
    for ncollide = 1:SystemParams.ueRB+1        
        RBCollideTotal(ncollide,l) = length(find( numOfRBCollide(:,l)==ncollide-1) );
        codeCollideTotal(ncollide,l) = length(find( numOfCodeCollide(:,l)==ncollide-1) );
    end
end

simPrefix = [simPrefix '_' num2str(SystemParams.nUE) 'UEs_' 'CM_' num2str(SystemParams.codeMethod) '_' simStartTimePrinted];
codeCollisionProb = mean( codeCollideTotal'/nTrial);
RBCollisionProb = mean(RBCollideTotal'/nTrial);
%save([simPrefix '.mat'])