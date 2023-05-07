function expThreshChangeSeries = threshChangeExtractSeries(expBoutSeries)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here


newThreshInd = 1;
for boutInd = 2: length(expBoutSeries)
    %Check if thresh changed and how
    minChangeDir = sign(expBoutSeries(boutInd).minAllowed - expBoutSeries(boutInd-1).minAllowed);
    maxChangeDir = sign(expBoutSeries(boutInd).maxAllowed - expBoutSeries(boutInd-1).maxAllowed);
    threshDiffInc = minChangeDir == 1 || maxChangeDir == -1; %difficulty increased
    threshDiffDec = minChangeDir == -1 || maxChangeDir == 1; %difficulty decreased
    threshChanged = threshDiffInc + threshDiffDec;
    if threshDiffInc == 1 && threshDiffDec == 0 %if harder
        threshChangePlotColor = 'r';
        threshDiffDir = 1;
    elseif threshDiffInc == 0 && threshDiffDec == 1 %if easier
        threshChangePlotColor = 'g';
        threshDiffDir = -1;
    elseif threshDiffInc == 1 && threshDiffDec == 1 %both changed
        threshChangePlotColor = 'y';
        threshDiffDir = 0;
    end
    %If thresh changed, add a threshChange object to expThreshChangeSeries:
    if  threshDiffInc == 1 || threshDiffDec == 1
        expThreshChangeSeries(newThreshInd) = ThreshChangeObj();
        expThreshChangeSeries(newThreshInd).boutID =expBoutSeries(boutInd).boutID;
        expThreshChangeSeries(newThreshInd).minThresh = expBoutSeries(boutInd).minAllowed;
        expThreshChangeSeries(newThreshInd).maxThresh = expBoutSeries(boutInd).maxAllowed; 
        expThreshChangeSeries(newThreshInd).minChangeDir = minChangeDir;
        expThreshChangeSeries(newThreshInd).maxChangeDir = maxChangeDir;
        expThreshChangeSeries(newThreshInd).threshChangeDiffDir = threshDiffDir;
        expThreshChangeSeries(newThreshInd).threshChangePlotColor = threshChangePlotColor;
        newThreshInd = newThreshInd+1;
    end
end
