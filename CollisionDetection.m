function [collideTable totalCollide] = CollisionDetection(LTE_params, resourceTable);

ueRB = length(find(resourceTable(:,1)~=0));
nUE = LTE_params.nUE;
collideTable = zeros(ueRB,nUE);
collideDetail = zeros(ueRB,nUE);
%codeCollideTable = zeros(ueRB,nUE);
for u_ = 1:nUE;
    numOfRB = length(resourceTable(:,u_));
    tableExtract = zeros(numOfRB,LTE_params.nUE);
    %codeTableExtract = zeros(numOfRB,LTE_params.nUE);
    
    extractIndex = find(resourceTable(:,u_)~=0);
    %codeExtractIndex = find(ueCodeTable(:,u_)~=0);
    
    tableExtract(extractIndex,:) = resourceTable(extractIndex,:);
    %codeTableExtract(codeExtractIndex,:) = ueCodeTable(codeExtractIndex,:);
    
    ueTableTemp = 1:LTE_params.nUE;
    ueTableTemp(u_) = [];
    for c_ = ueTableTemp
        [collide_row collide_col collide_val]=find(tableExtract(extractIndex,u_)==tableExtract(extractIndex,c_));
        collideTable(collide_row,u_) = 1;
        collideDetail(collide_row,u_) =  collideDetail(collide_row,u_) + 1;
        
        
        %[collide_row collide_col collide_val]=find(codeTableExtract(codeExtractIndex,u_)==codeTableExtract(codeExtractIndex,c_));
        %codeCollideTable(collide_row,u_) = 1;
        
        
    end
end
totalCollide = sum(collideTable);





end