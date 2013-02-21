%% 2013-02-19 created 
% This program is using for different resource allocation scheme to calculate collision probability
%
clear
%% System parameters initialization 
SystemParams.allocationMethod = 'continuous_selection';
SystemParams.nUE = 20;
SystemParams.ueRB = 6;
SystemParams.totalRB = 50;
SystemParams.orderedIndex = 1:SystemParams.totalRB;
SystemParams.cyclicShiftRange = [0 49];
SystemParams.readoutIndex = 1:SystemParams.totalRB;
SystemParams.codeMethod = 2;
SystemParams.spreadingFactor = 3;
SystemParams.circularOnOff = 0;
%SystemParams.intlvSizeMatrix = [3 5, 4 4, 5 3];
SystemParams.intlvSizeMatrix = [5 10; 6 9 ; 10 5];
SystemParams.fixIntlvIndex = 1;
SystemParams.extendedCyclicShiftOnOff = 1;
%% Simulation parameters initialization
nTrial = 5000; % number of trial
%% case 1 random selection
numberRBCollide = zeros(nTrial, SystemParams.nUE);
numberCodeCollide = zeros(nTrial, SystemParams.nUE);

numberRBCollide2 = zeros(nTrial, SystemParams.nUE);
numberCodeCollide2 = zeros(nTrial, SystemParams.nUE);
numberCodeCollideDetail =zeros(SystemParams.nUE, 7, 36);
numberRBCollideDetail =zeros(SystemParams.nUE, 7, 36);

numberOfRBAccess = zeros(nTrial, SystemParams.nUE);
ueRBStatus = zeros(SystemParams.nUE, 6);
ueCodeStatus = zeros(SystemParams.nUE, 6);
% UE object generation
for u_ = 1 : SystemParams.nUE
    UE(u_) = NetworkElement.UE_Parameters;
end

for n_ = 1:nTrial
       ueCodeTable = zeros(SystemParams.totalRB,SystemParams.nUE);
      ueRBTable   = zeros(SystemParams.totalRB,SystemParams.nUE);
     for u_ = 1:SystemParams.nUE
      %  UE(u_).UE_IntlvParameterGenWithCyclicShift2(SystemParams);
      switch SystemParams.allocationMethod
          case 'random_selection'
            UE(u_).UE_RandomSelection(SystemParams);
          case 'continuous_selection'
            UE(u_).UE_DirectParameterGen(SystemParams);  
          case 'interleaver'
           UE(u_).UE_DifferentSizeOfIntlvrWithCyclicShift2(SystemParams);
          case 'fixed_size'
              UE(u_).UE_IntlvParameterGen(SystemParams);
      end

        [tempRB tempCode]= UE(u_).getResourcePatterns;        
        [sortedPhyIndex sortedOrder] = sort(tempRB);
        ueCodeTable(sortedPhyIndex,u_) = tempCode(sortedOrder);
        ueRBTable(sortedPhyIndex,u_) = sortedPhyIndex;
        ueRBStatus(u_, :) = tempRB;
        ueCodeStatus(u_, :) = tempRB + (tempCode - 1) * SystemParams.totalRB;
     end
%        compareResult = zeros(SystemParams.nUE, 6);
%      for uu = 1:SystemParams.nUE
%      ueTableTemp = 1:SystemParams.nUE  
%      ueTableTemp(uu) = [];
%    
%      for u_tmp =  ueTableTemp
%      compareResult(uu, :) = compareResult(uu, :) + ismember(ueCodeStatus(uu,:), ueCodeStatus(u_tmp,:)) 
%      end
%      end
    [dd1 dd2 numberCodeCollideDetail]=Collide_Observation(SystemParams, ueCodeStatus, numberCodeCollideDetail);
   % [dd3 dd4]=Collide_Observation(SystemParams, ueRBStatus, numberRBCollideDetail)
     collideTable = zeros(SystemParams.totalRB,SystemParams.nUE); 
    %[nRBAccess]=ResourceAccessDetection(SystemParams,ueRBTable);
    [RBCollideTable totalRBCollide] = CollisionDetection(SystemParams,ueRBTable);
    [codeCollideTable totalCodeCollide] = CollisionDetection(SystemParams,ueCodeTable);
  
    numOfRBCollide(n_,:) = totalRBCollide;
    numOfCodeCollide(n_,:) = totalCodeCollide;
    
 
%     numOfRBAccess(n_,:) = nRBAccess;
end
for l = 1:SystemParams.nUE
    for ncollide = 1:SystemParams.ueRB+1        
        RBCollideTotal(ncollide,l) = length(find( numOfRBCollide(:,l)==ncollide-1) );
        codeCollideTotal(ncollide,l) = length(find( numOfCodeCollide(:,l)==ncollide-1) );
    end
end
codeCollisionProb = mean( codeCollideTotal'/nTrial);
RBCollisionProb = mean(RBCollideTotal'/nTrial);

