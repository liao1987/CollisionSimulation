% ball and bins problem

nTosses = 10000;
balls = 50; % balls users
bins = 12; % bins =>cyclicShift

binVectors = zeros(1,bins);


results = randi([1 12],1,balls);
uniqueResults = unique(results);
collisionCollect = zeros(bins,balls+1);

for n_ = 1:nTosses
    results = randi([1 12],1,balls);
    uniqueResults = unique(results);
    
    for b_ = 1:bins
        
        binMatch = find(b_ == results);
        numOfBallsInBin = length(binMatch);
        
        if numOfBallsInBin== 0
            collisionCollect(b_,1) = collisionCollect(b_,1) +1;
            
        else
            collisionCollect(b_,numOfBallsInBin+1) = collisionCollect(b_,numOfBallsInBin+1) +1;
            
            
            
        end
        %for i_ = 1:length(uniqueResults)
        
        %currentBins = uniqueResults(i_);
        %ballInBins=find( results == currentBins);
        %numOfBallsInBin = length(ballInBins);
        %collisionCollect(currentBins,numOfBallsInBin+1) = collisionCollect(currentBins,numOfBallsInBin+1) +1;
        
        %end
        
    end
end


collisionProb = mean(collisionCollect/nTosses);

for k = 0 : balls
analytical(k+1) = nchoosek(balls,k)*(1/bins)^k*(1-(bins^-1))^(balls-k);
end

% for n_ = 1:nTosses
%     for i_ = results
%
%         binVectors(i_) = binVectors(i_)+1;
%
%
%     end
% end