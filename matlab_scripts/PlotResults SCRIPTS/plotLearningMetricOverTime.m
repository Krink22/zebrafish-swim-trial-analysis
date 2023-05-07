function  plotLearningMetricOverTime(exp, boutInds)
%UNTITLED9 Summary of this function goes here
%   Detailed explanation goes here


learningMetricVect = exp.extractBoutPropVect('learningMetric', boutInds);

bwBinSize = 101;
slidingAvLearningMetric = movmedian(learningMetricVect,[bwBinSize,0]); 
close all
plot(boutInds,slidingAvLearningMetric,'b');
hold on

%Find value of hardest thresh and final thresh
evalVsHardestThreshSwitch=1; %if not, will evaluate against first thresh


lastThreshMin = exp.threshChangeSeries(end).minThresh;
lastThreshMax = exp.threshChangeSeries(end).maxThresh;
evalThreshMin = exp.threshChangeSeries(1).minThresh;
evalThreshMax = exp.threshChangeSeries(1).maxThresh;
if evalVsHardestThreshSwitch==1  
    for newThreshInd = 1:length(exp.threshChangeSeries)
        evalThreshMin = max(evalThreshMin,exp.threshChangeSeries(newThreshInd).minThresh);
        evalThreshMax = min(evalThreshMax,exp.threshChangeSeries(newThreshInd).maxThresh);
    end
end



%Plot times of all thresh changes (red = thresh got harder, green = got
%easier) and value of hardest thresh and final thresh
xRange = xlim;
yRange = ylim;
for newThreshInd = 1:length(exp.threshChangeSeries)   
    xVect = repmat(exp.threshChangeSeries(newThreshInd).boutID,2,1);
    plot (xVect, yRange, exp.threshChangeSeries(newThreshInd).threshChangePlotColor)
end
plot(xRange, repmat(lastThreshMin,2,1), 'r:')
plot(xRange, repmat(evalThreshMin,2,1), 'r-')
plot(xRange, repmat(lastThreshMax,2,1), 'k:')
plot(xRange, repmat(evalThreshMax,2,1), 'k-')
ylim(yRange)

if evalVsHardestThreshSwitch==1  
    title('Learning metric vs Hardest Thresh and Final Thresh')
else
    title('Learning metric vs First Thresh and Final Thresh')
end

a='stop';
disp(a);