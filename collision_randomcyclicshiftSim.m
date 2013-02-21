% Created by ktliao
clc;clear;%clear all;

% nUE = ;
% totalRB = 15;
% orderedIndex = 1:totalRB;
nTrial = 5000;
% cyclicShiftRange1 = [0 1 2];
% codeMethod = 1;
%%
MAT_FILE_NAME = 'test'
SystemParams.nUE = 6;
SystemParams.ueRB = 6;
SystemParams.totalRB = 15;
SystemParams.orderedIndex = 1:SystemParams.totalRB;
SystemParams.cyclicShiftRange = [0 11];
SystemParams.readoutIndex = 1:SystemParams.totalRB;
SystemParams.codeMethod = 1;
SystemParams.spreadingFactor = 3;
SystemParams.intlvSizeMatrix = [3 5 ;4 4 ;5 3];

%%
numOfRBCollide = zeros(nTrial,SystemParams.nUE);
numOfCodeCollide = zeros(nTrial,SystemParams.nUE);
numOfRBAccess = zeros(nTrial,SystemParams.totalRB );
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
        UE(u_).UE_IntlvParameterWithDifferentSizeIntlver(SystemParams)
        %UE(u_).UE_DirectParameterGen(SystemParams);
        [tempRB tempCode]= UE(u_).getResourcePatterns;
        
        [sortedPhyIndex sortedOrder] = sort(tempRB);
        ueCodeTable(sortedPhyIndex,u_) = tempCode(sortedOrder);
        ueRBTable(sortedPhyIndex,u_) = sortedPhyIndex;
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
codeCollisionProb = mean( codeCollideTotal'/nTrial);
RBCollisionProb = mean(RBCollideTotal'/nTrial);

save MAT_FILE_NAME codeCollisionProb RBCollisionProb