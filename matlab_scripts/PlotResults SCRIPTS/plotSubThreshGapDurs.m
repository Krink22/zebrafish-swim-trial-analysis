function plotSubThreshGapDurs(expBoutSeries,boutsToPlotInds)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

nBouts = size(expBoutSeries,2);
largestGap = zeros(nBouts,1);
for boutInd = boutsToPlotInds
    largestGap(boutInd) = expBoutSeries(boutInd).FindLargestGap();    
end
largestGap = largestGap(largestGap~=0);

figure()
histogram(largestGap,10)
xlabel('Largest Gap in dps (6 dps/ms)')

end
