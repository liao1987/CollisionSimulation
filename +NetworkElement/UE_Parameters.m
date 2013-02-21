classdef UE_Parameters < handle
    
    properties
        bandWidth
        assignedRB
        assignedCode
        intlvSize
        cyclicShift
        rsCyclicShift
        rbCyclicShift
        rowCyclicShift
        spreadingFactor
        
    end
    methods
        %% constructor for initialization
        function obj = UE_Parameters
            obj.bandWidth = 6;
            obj.assignedRB = [];
            obj.assignedCode = [];
            obj.intlvSize = [];
            obj.cyclicShift = [0;0];
            obj.rsCyclicShift = [];
            obj.rbCyclicShift = [];
            obj.rowCyclicShift = [];
            obj.spreadingFactor = [];
        end
        
        %% manual assigne parameters
        function UE_Parameter_Assignment(obj,ueRB, RBIndex, codeIndex, intlvSize, cyclicShift,spreadingFactor)
            
            obj.bandWidth = ueRB;
            obj.assignedRB = RBIndex;
            obj.assignedCode = codeIndex;
            obj.intlvSize = intlvSize
            obj.cyclicShift = cyclicShift;
            obj.spreadingFactor = spreadingFactor;
        end
        
     %% Random Selection
     function UE_RandomSelection(obj, SystemParams)
         totalRB = SystemParams.totalRB;
         orderedIndex = SystemParams.orderedIndex;
         codeMethod = SystemParams.codeMethod;
         ueRB = obj.bandWidth;
         obj.assignedRB = randperm(totalRB, ueRB);
         obj.assignedCode = randi([1 SystemParams.spreadingFactor],1,ueRB);
     end
        %% The eNB Direct allocate a segment of continuous RB to the UE
        function UE_DirectParameterGen(obj,SystemParams)
            % System Parameters
            totalRB = SystemParams.totalRB;
            orderedIndex = SystemParams.orderedIndex;
            codeMethod = SystemParams.codeMethod;
            cyclicShiftRange = SystemParams.cyclicShiftRange;
            %UE Parameters
            ueRB = obj.bandWidth;
            RBOrder = 1:ueRB;
            %obj.cyclicShift(1) = randi(cyclicShiftRange,1,1);
            %obj.cyclicShift(2) = randi ([0 obj.intlvSize(2)-1],1,1);
            
            obj.rsCyclicShift = randi(cyclicShiftRange,1,1);
            obj.rbCyclicShift = obj.rsCyclicShift;
            obj.rowCyclicShift = 0;
            
            obj.spreadingFactor = SystemParams.spreadingFactor;
            
            startIndex = randi(totalRB-ueRB+1,1,1);
            virtualIndex = (startIndex-1) + (1:ueRB);
            
            obj.assignedRB = virtualIndex;
            if(codeMethod == 1)   
                obj.assignedCode = mod(obj.assignedRB+obj.rsCyclicShift,SystemParams.spreadingFactor)+1;
            else 
                obj.assignedCode = mod(obj.assignedRB+RBOrder+obj.rsCyclicShift,SystemParams.spreadingFactor)+1;
            end
            
        end
        
        
        %% The original type, fixed interleaver to 3x5,and cyclicshift2 to 0
        function UE_IntlvParameterGen(obj,SystemParams)
            % System parameters
            totalRB = SystemParams.totalRB;
            orderedIndex = SystemParams.orderedIndex;
            codeMethod = SystemParams.codeMethod;
            cyclicShiftRange = SystemParams.cyclicShiftRange;
            readoutIndex = 1:totalRB;
            isExtendedCyclicShift = SystemParams.extendedCyclicShiftOnOff;
            
            % UE parameters
            ueRB = obj.bandWidth;
            RBOrder = 1:ueRB;
            obj.intlvSize = SystemParams.intlvSizeMatrix(1,:); % using the first elements as default size for this case
            
            if isExtendedCyclicShift
                obj.rbCyclicShift = randi(cyclicShiftRange,1,1);
                obj.rsCyclicShift = mod(obj.rbCyclicShift, 12);
            else
                
                obj.rbCyclicShift = randi(cyclicShiftRange,1,1);
                obj.rsCyclicShift = obj.rbCyclicShift;
            end
               obj.rowCyclicShift = 0;
            if SystemParams.circularOnOff
                startIndex = randi(totalRB,1,1);
            else
                startIndex = randi(totalRB-ueRB+1,1,1);
            end
            %virtualIndex = (startIndex-1) + (1:ueRB);
            tempIndex = (startIndex-1) + (1:ueRB);
            virtualIndex = mod(tempIndex-1,totalRB)+1;
            intlvIndex = IntlvMapping_Gen_columnshift_2(orderedIndex,obj.intlvSize(1),obj.intlvSize(2),readoutIndex, obj.rbCyclicShift, obj.rowCyclicShift);
            
            obj.assignedRB = intlvIndex(virtualIndex);
            
            if(codeMethod == 1)
                obj.assignedCode = mod(obj.assignedRB+obj.rbCyclicShift,SystemParams.spreadingFactor)+1;
            else
                obj.assignedCode = mod(obj.assignedRB+RBOrder+obj.rbCyclicShift,SystemParams.spreadingFactor)+1;
            end
            obj.spreadingFactor = SystemParams.spreadingFactor;
        end
        
        
        %% Resource allocation with cyclicshift 1 (rbCyclicShift) and cyclichshift 2  ¡]rowCyclicShift¡^
        function UE_IntlvParameterGenWithCyclicShift2(obj,SystemParams)
            % System parameters
            totalRB = SystemParams.totalRB;
            orderedIndex = SystemParams.orderedIndex;
            codeMethod = SystemParams.codeMethod;
            cyclicShiftRange = SystemParams.cyclicShiftRange;
            readoutIndex = 1:totalRB;
            fixIntlvIndex = SystemParams.fixIntlvIndex;
            intlvSizeMatrix = SystemParams.intlvSizeMatrix;
             isExtendedCyclicShift = SystemParams.extendedCyclicShiftOnOff;
            % UE parameters
            ueRB = obj.bandWidth;
            RBOrder = 1:ueRB;
            
            obj.intlvSize = intlvSizeMatrix(fixIntlvIndex,:);
            %obj.cyclicShift(1) = randi(cyclicShiftRange,1,1);
            obj.rowCyclicShift(2) = randi ([0 obj.intlvSize(2)-1],1,1);
            
            if isExtendedCyclicShift
                obj.rbCyclicShift = randi(cyclicShiftRange,1,1);
                obj.rsCyclicShift = mod(obj.rbCyclicShift, 12);
            else
                
                obj.rbCyclicShift = randi(cyclicShiftRange,1,1);
                obj.rsCyclicShift = obj.rbCyclicShift;
            end
            
            if SystemParams.circularOnOff
                startIndex = randi(totalRB,1,1);
            else
                startIndex = randi(totalRB-ueRB+1,1,1);
            end
            
            %virtualIndex = (startIndex-1) + (1:ueRB);
            tempIndex = (startIndex-1) + (1:ueRB);
            virtualIndex = mod(tempIndex-1,totalRB)+1;
            
            
            intlvIndex = IntlvMapping_Gen_columnshift_2(orderedIndex,obj.intlvSize(1),obj.intlvSize(2),readoutIndex, obj.rbCyclicShift, obj.rowCyclicShift(2));
            
            obj.assignedRB = intlvIndex(virtualIndex);
            
            if(codeMethod == 1)
                obj.assignedCode = mod(obj.assignedRB+obj.rbCyclicShift(1),SystemParams.spreadingFactor)+1;
            else
                obj.assignedCode = mod(obj.assignedRB+RBOrder+obj.rbCyclicShift(1),SystemParams.spreadingFactor)+1;
            end
            obj.spreadingFactor = SystemParams.spreadingFactor;
        end
        
        
        %% Resource allocation with different size of interleaver
        function UE_IntlvParameterWithDifferentSizeIntlver(obj,SystemParams)
            totalRB = SystemParams.totalRB;
            orderedIndex = SystemParams.orderedIndex;
            codeMethod = SystemParams.codeMethod;
            cyclicShiftRange = SystemParams.cyclicShiftRange;
            readoutIndex = 1:totalRB;
            intlvSizeMatrix = SystemParams.intlvSizeMatrix;
            numOfAvailableIntlvr = size(intlvSizeMatrix,1);
             isExtendedCyclicShift = SystemParams.extendedCyclicShiftOnOff;
            
            ueRB = obj.bandWidth;
            RBOrder = 1:ueRB;
            tempIntlvrIndex = randi([1 numOfAvailableIntlvr],1,1);
            obj.intlvSize = SystemParams.intlvSizeMatrix(tempIntlvrIndex,:);
    
            
            
             obj.rowCyclicShift = 0; 
                      
            if isExtendedCyclicShift
                obj.rbCyclicShift = randi(cyclicShiftRange,1,1);
                obj.rsCyclicShift = mod(obj.rbCyclicShift, 12);
            else
                
                obj.rbCyclicShift = randi(cyclicShiftRange,1,1);
                obj.rsCyclicShift = obj.rbCyclicShift;
            end
            
            if SystemParams.circularOnOff
                startIndex = randi(totalRB,1,1);
            else
                startIndex = randi(totalRB-ueRB+1,1,1);
            end
            
            %virtualIndex = (startIndex-1) + (1:ueRB);
            tempIndex = (startIndex-1) + (1:ueRB);
            virtualIndex = mod(tempIndex-1,totalRB)+1;
            
            
            intlvIndex = IntlvMapping_Gen_columnshift_2(orderedIndex,obj.intlvSize(1),obj.intlvSize(2),readoutIndex, obj.rbCyclicShift, obj.rowCyclicShift);
            
            obj.assignedRB = intlvIndex(virtualIndex);
            
            if(codeMethod == 1)
                obj.assignedCode = mod(obj.assignedRB+obj.rbCyclicShift, SystemParams.spreadingFactor)+1;
            else
                obj.assignedCode = mod(obj.assignedRB+RBOrder+obj.rbCyclicShift,SystemParams.spreadingFactor)+1;
            end
            obj.spreadingFactor = SystemParams.spreadingFactor;
        end
        %% Combine interleaver size and cyclicshift2
        function UE_DifferentSizeOfIntlvrWithCyclicShift2(obj,SystemParams)
            totalRB = SystemParams.totalRB;
            orderedIndex = SystemParams.orderedIndex;
            codeMethod = SystemParams.codeMethod;
            cyclicShiftRange = SystemParams.cyclicShiftRange;
            readoutIndex = 1:totalRB;
            intlvSizeMatrix = SystemParams.intlvSizeMatrix;
            numOfAvailableIntlvr = size(intlvSizeMatrix,1);  
             isExtendedCyclicShift = SystemParams.extendedCyclicShiftOnOff;
             
            ueRB = obj.bandWidth;
            RBOrder = 1:ueRB;
            
            tempIntlvrIndex = randi([1 numOfAvailableIntlvr],1,1);
            obj.intlvSize = SystemParams.intlvSizeMatrix(tempIntlvrIndex,:);     
            obj.rowCyclicShift = randi ([0 obj.intlvSize(2)-1],1,1);
            %obj.cyclicShift(1) = randi(cyclicShiftRange,1,1);
            %obj.cyclicShift(2) = randi(obj.intlvSize(2)-1,1,1);
            
                       
            if isExtendedCyclicShift
                obj.rbCyclicShift = randi(cyclicShiftRange,1,1);
                obj.rsCyclicShift = mod(obj.rbCyclicShift, 12);
            else
                
                obj.rbCyclicShift = randi(cyclicShiftRange,1,1);
                obj.rsCyclicShift = obj.rbCyclicShift;
            end
            
            if SystemParams.circularOnOff
                startIndex = randi(totalRB,1,1);
            else
                startIndex = randi(totalRB-ueRB+1,1,1);
            end
            
            tempIndex = (startIndex-1) + (1:ueRB);
            virtualIndex = mod(tempIndex-1,totalRB)+1;
           
            intlvIndex = IntlvMapping_Gen_columnshift_2(orderedIndex,obj.intlvSize(1),obj.intlvSize(2),readoutIndex, obj.rbCyclicShift, obj.rowCyclicShift);
            
            obj.assignedRB = intlvIndex(virtualIndex);
            
            if(codeMethod == 1)
                obj.assignedCode = mod(obj.assignedRB+obj.rbCyclicShift,SystemParams.spreadingFactor)+1;
            else
                obj.assignedCode = mod(obj.assignedRB+RBOrder+obj.rbCyclicShift,SystemParams.spreadingFactor)+1;
            end
            obj.spreadingFactor = SystemParams.spreadingFactor;
        end
        
        
        
        
        %% function for get resource pattern
        function [RBIndex codeIndex] = getResourcePatterns(obj)
            RBIndex = obj.assignedRB;
            codeIndex = obj.assignedCode;
            %cyclicShift = obj.cyclic
        end
        function [rbCyclicShift rsCyclicShift rowCyclicShift intlvSize] = getUECyclicShiftAndIntlvSize(obj)
            rbCyclicShift = obj.rbCyclicShift;
            rsCyclicShift = obj.rsCyclicShift;
            rowCyclicShift = obj.rowCyclicShift;
            intlvSize = obj.intlvSize;
        end
        
        %function setResource
        
        
    end
end
