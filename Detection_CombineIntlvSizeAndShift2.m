% Created by ktliao
clc;clear;%clear all;


nTrial = 5000;
simPrefix = 'DiffSizeIntlvWithCyclicShift2';
simStartTime = clock
simStartTimePrinted = sprintf('%04d_%02d_%02d_%02d%02d%02',simStartTime(1),simStartTime(2),simStartTime(3),simStartTime(4),simStartTime(5),simStartTime(6))

%%
SystemParams.nUE = 4;
SystemParams.ueRB = 6;
SystemParams.totalRB = 15;
SystemParams.orderedIndex = 1:SystemParams.totalRB;
SystemParams.cyclicShiftRange = [0 11];
SystemParams.readoutIndex = 1:SystemParams.totalRB;
SystemParams.codeMethod = 2;
SystemParams.spreadingFactor = 3;
SystemParams.intlvSizeMatrix = [3 5 ;4 4;5 3];

%%
nPossibleIntlv = size(SystemParams.intlvSizeMatrix,1)
numOfRBCollide = zeros(nTrial,SystemParams.nUE);
numOfCodeCollide = zeros(nTrial,SystemParams.nUE);
numOfRBAccess = zeros(nTrial,SystemParams.totalRB );
orderedIndex = SystemParams.orderedIndex;
readoutIndex = orderedIndex;
ueRB =SystemParams.ueRB;
codeMethod = 2;
                         
%%
for u_ = 1:SystemParams.nUE
    % UE object generation
    UE(u_) = NetworkElement.UE_Parameters;
end
for n_ = 1:nTrial
        ueCodeTable = zeros(SystemParams.totalRB,SystemParams.nUE);
        ueRBTable   = zeros(SystemParams.totalRB,SystemParams.nUE);
        ueCyclicShiftTable = [];
        ueIntlvSizeTable = [];
    for u_ = 1:SystemParams.nUE
        %UE(u_).UE_IntlvParameterGenWithCyclicShift2(SystemParams);
        %UE(u_).UE_DifferentSizeOfIntlvrWithCyclicShift2(SystemParams);
        UE(u_).UE_IntlvParameterGen(SystemParams);
        [tempRB tempCode]= UE(u_).getResourcePatterns;        
        [sortedPhyIndex sortedOrder] = sort(tempRB);
        ueCodeTable(sortedPhyIndex,u_) = tempCode(sortedOrder);
        ueRBTable(sortedPhyIndex,u_) = sortedPhyIndex;
        [tempCyclicShift tempIntlvSize]=UE(u_).getUECyclicShiftAndIntlvSize
        ueCyclicShiftTable = [ueCyclicShiftTable tempCyclicShift];
        ueIntlvSizeTable = [ueIntlvSizeTable; tempIntlvSize];
    end
    
   detectedRef = unique(ueCyclicShiftTable(1,:));
   ndetectedRef = length(detectedRef);
   detectedRB = cell(1,ndetectedRef);
   for r_ = 1:ndetectedRef
        temp = (find(ueCyclicShiftTable(1,:) == detectedRef(r_)))
       [indexOfSameRef(r_)]= unique(ueCyclicShiftTable(1,temp))
       tempCollect = [];
       for t_ =1:length(temp)
           tIndex = temp(t_);
       tempDetectedRBIndex = find(ueRBTable(:,tIndex)~= 0);
       tempCollect = [tempCollect ueRBTable(tempDetectedRBIndex,tIndex)']; 
       end
       detectedRB{r_} =unique(tempCollect);
   end
    %%
            allCandidateRB=[];
            allCandidateCode = [];
            recordedCyclicShift  = [];
   
   for d_ = 1:ndetectedRef
       dRBIndex = detectedRB{d_};
       cyclicShift1 = detectedRef(d_)
       for i_ = 1:nPossibleIntlv
           numOfRows = SystemParams.intlvSizeMatrix(i_,1);
           numOfCols = SystemParams.intlvSizeMatrix(i_,2);
           %for c_ = 0:numOfCols-1
           for c_=0
               cyclicShift2 = c_;
               intlvIndex = IntlvMapping_Gen_columnshift_2(orderedIndex,numOfRows,numOfCols,readoutIndex,cyclicShift1,cyclicShift2);
               [sortedPhyIndex sortedOrder] = sort( intlvIndex );
                tempDeIntlv = sortedOrder(dRBIndex);
               sortedDeIntlv = sort(tempDeIntlv);
            %  possible combination enumeration
               diff_observed = diff( sortedDeIntlv);
               loc = find(diff_observed~=1)+0.5;
            loc = [loc-0.5 loc+0.5];
            %indexForSegment = sort([1 loc length( sortedDeIntlv)]);
            %indexForSegment = reshape(indexForSegment,2,[])'; % list all possible segmentation
            
            indexForSegment = unique(loc);
            indexForSegment(indexForSegment==1 | indexForSegment==length(sortedDeIntlv)) =[];
            %indexForSegment(indexForSegment==length(sortedDeIntlv)) = [];
            indexForSegment = kron(ones(2,1),indexForSegment);
            indexForSegment=reshape([1 indexForSegment(:).' length(sortedDeIntlv)],2,[])';
            segmentLength = diff(indexForSegment');
            
            indexOfSurivor = find(segmentLength >= ueRB-1);
            indexForSegment = indexForSegment(indexOfSurivor,:);
            
            
            totalSegment = size(indexForSegment,1);
            segmentedIndex = cell(1,totalSegment);
               for s_ =1:totalSegment
                
                segmentedIndex{s_}=indexForSegment(s_,1):indexForSegment(s_,end);
                if ~(length(segmentedIndex{s_}) < ueRB)
                    numOfenumerated = length(  sortedDeIntlv(segmentedIndex{s_})) - ueRB+1;
                    % numOfenumerated = length(temp) - ueRB+1;
                    indexStarted = segmentedIndex{s_}(1:numOfenumerated);
                    indexStarted = kron(indexStarted',ones(1,ueRB));
                    tempIndex = 0:ueRB-1;
                    tempIndex = kron(tempIndex,ones(numOfenumerated,1));
                    enumeratedIndex = sortedDeIntlv(indexStarted+tempIndex);
                    rbOrder=kron(1:ueRB,ones(size(enumeratedIndex,1),1));

                    allCandidateRB = [allCandidateRB;intlvIndex(enumeratedIndex) ];
                    switch codeMethod
                        
                        case 1
                            allCandidateCode = [allCandidateCode;mod(intlvIndex(enumeratedIndex) + cyclicShift1,3)+1];
                        case 2
                            allCandidateCode = [allCandidateCode;mod(intlvIndex(enumeratedIndex) + cyclicShift1 + rbOrder,3)+1];
                    end
                    recordedCyclicShift = [recordedCyclicShift;ones(size(enumeratedIndex,1),1)*(cyclicShift1) ones(size(enumeratedIndex,1),1)*(cyclicShift2)];
                end
                
            end
          
           
           
           end
           
           
           
           
       end
       %%
       
   end % end of 
  
    
    
    
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
save([simPrefix '.mat'])