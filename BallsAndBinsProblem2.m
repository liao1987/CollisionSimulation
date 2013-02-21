% ball and bins problem 2
clear
nUE = 50
nTosses = 20000;
balls = 6; % balls users
bins = 50; % bins =>cyclicShift

binVectors = zeros(1,bins);


results = randi([1 12],1,balls);
uniqueResults = unique(results);
collisionCollect = zeros(bins,balls+1);
numOfUECollect = zeros(bins,nUE+1)

for n_ = 1:nTosses
    
    
    %results = randi([1 12],1,balls);
  binsCollect = zeros(bins,nUE);
    for u_=1:nUE
    results = randperm(bins);
    resutls = results(1:balls);
    binsCollect(resutls,u_)=1;
    
    end
    tempSum =sum(binsCollect');
    
    for t_ = 0:nUE
        
        binIndicator=find(tempSum==t_);
        numOfUECollect(binIndicator,t_+1)=numOfUECollect(binIndicator,t_+1)+1;
        
    end
%     for b_ = 1:bins
%         
%         binMatch = find(b_ == results);
%         numOfBallsInBin = length(binMatch);
%         
%         if numOfBallsInBin== 0
%             collisionCollect(b_,1) = collisionCollect(b_,1) +1;
%             
%         else
%             collisionCollect(b_,numOfBallsInBin+1) = collisionCollect(b_,numOfBallsInBin+1) +1;
%             
%             
%             
%         end
%         %for i_ = 1:length(uniqueResults)
%         
%         %currentBins = uniqueResults(i_);
%         %ballInBins=find( results == currentBins);
%         %numOfBallsInBin = length(ballInBins);
%         %collisionCollect(currentBins,numOfBallsInBin+1) = collisionCollect(currentBins,numOfBallsInBin+1) +1;
%         
%         %end
%         
%     end
end
p = balls/bins;
q= 1-p;

for k = 0:nUE
    
    analytical(k+1)=nchoosek(nUE,k)*p^k*q^(nUE-k);
    
    
end
% 
collisionProb = mean(numOfUECollect/nTosses);
% 
% for k = 0 : balls
% analytical(k+1) = nchoosek(balls,k)*(1/bins)^k*(1-(bins^-1))^(balls-k);
% end
% 
% % for n_ = 1:nTosses
%     for i_ = results
%
%         binVectors(i_) = binVectors(i_)+1;
%
%
%     end
% end