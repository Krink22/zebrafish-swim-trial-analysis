function  plotSuccessOverTime(expBoutSeries, expThreshChangeSeries)
%UNTITLED9 Summary of this function goes here
%   Detailed explanation goes here

successVect = nan(size(expBoutSeries,2),1);
for boutInd = 1: length(successVect)
    successVect(boutInd)=expBoutSeries(boutInd).success;    
end

bwBinSize = 101;
slidingAvSuccess = movmean(successVect,[bwBinSize,0]); 
close all
plot(slidingAvSuccess,'b');
hold on
for newThreshInd = 1:length(expThreshChangeSeries)   
    xVect = repmat(expThreshChangeSeries(newThreshInd).boutInd,2,1);
    plot (xVect, [0,1], expThreshChangeSeries(newThreshInd).threshChangePlotColor)
end
a='stop';
disp(a);