function plotBouts(expBoutSeries, boutsToPlotInds)
%UNTITLED7 Summary of this function goes here
%   Detailed explanation goes here

chInds = chanInds(); %define channel indices
useGlobalInds = 1; %use global inds for x-axis vs default of inds starting at 0 for rawData excerpt
close all

for plotInd = boutsToPlotInds
    figure(plotInd)
    bout = expBoutSeries(plotInd);
    data = bout.rawDataChs;
    if useGlobalInds == 1
        xVals = bout.rawDataStartInd:(bout.rawDataStartInd+length(data)-1);
    else
        xVals = 1: length(data);
    end
    %Plot motor
    plot(xVals,data(:,chInds('motorCh2')))
    hold on
    %Plot thresh
    plot(xVals,data(:,chInds('threshCh2')),'k--')
    %Plot bout onInd and offInD (meausred posthoc) AND bout length based on
    %bout onT and offT (measured adhoc)
    boutDurDPs = bout.durExp * bout.sampRate/1000;
    vertLinesToPlot = [bout.onInd, bout.offInd, bout.offInd-boutDurDPs];
    colors=['g','r','k--'];
    for i = 1:length(vertLinesToPlot)
        x = vertLinesToPlot(i);
        if useGlobalInds ~= 1
            x = x -bout.rawDataStartInd;
        end
        plot([x,x],ylim,colors(i))
    end
end

