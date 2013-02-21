function [nRBAccess nCodeAccess]=ResourceAccessDetection(LTE_params, rbTable, codeTable)
totalRB = size(rbTable,1);
nUE = size(rbTable,2);
RBGrid = zeros(totalRB,1);

nRBAccess =zeros(totalRB,1);
nCodeAccess = zeros(totalRB,LTE_params.spreadingFactor);
%  for rb_ = 1 : totalRB
%     nAccess(rb_) = length(find(rbTable(rb_,:)~=0));
% end

for c_ =1:nUE
    tempRBIndex = find(rbTable(:, c_) ~= 0);
    tempCodeLocation = find(codeTable(:, c_) ~= 0);
    usedCodeIndex = codeTable(tempCodeLocation,c_);
    indexTransformed = tempCodeLocation + (usedCodeIndex-1) * totalRB;
    nRBAccess(tempRBIndex,c_) = 1;
    nCodeAccess(indexTransformed) =  nCodeAccess(indexTransformed) +1;
    
end

end






