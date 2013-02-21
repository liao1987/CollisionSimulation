function [numCollideDetail, collideResult numCollideDetailOut]=Collide_Observation(SystemParams, resourceStatus, numCollideDetail)
collideCondition = zeros(SystemParams.nUE, 6);
for uu = 1:SystemParams.nUE
    ueTableTemp = 1:SystemParams.nUE;
    ueTableTemp(uu) = [];
    
    for u_tmp =  ueTableTemp
        collideCondition(uu,:) = collideCondition(uu,:) + ismember(resourceStatus(uu,:), resourceStatus(u_tmp,:));
    end
 
    collideResult(uu,1) = length(find(collideCondition(uu,:) ~= 0));
    collideResult(uu,2) = sum(collideCondition(uu,:));
    numCollideDetail(uu, collideResult(uu,1)+1, collideResult(uu,2)+1) = numCollideDetail(uu, collideResult(uu,1)+1, collideResult(uu,2)+1) + 1;
    %if(collideResult(uu,1)==0)
    %numCollideDetail(uu, collideResult(uu,1)+1, collideResult(uu,2)+1) = numCollideDetail(uu, collideResult(uu,1)+1, collideResult(uu,2)+1) + 1;
    %else
    %    numCollideDetail(uu, collideResult(uu,1)+1, collideResult(uu,2)) = numCollideDetail(uu, collideResult(uu,1)+1, collideResult(uu,2)) + 1;
    %end
end
numCollideDetailOut = numCollideDetail;
end