function  [xData,yData] = plotOverlayedTraces(obj, fileGroup, traceType)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

    close all
    clc

    %loadData = inputdlg("Data needs to be loaded? (enter y)");
    loadData = "y";
    if loadData == "y"
        %clearvars
        waitfor(msgbox("Set switches for all plots on a_BoutAnalysis_MasterScript to off. Press Okay when ready to proceed. (Ultimately better to make this happen via a function)"))
        %SELECT EXPS
        exps = obj.fileGroups.(fileGroup);
        %EXTRACT INDIVIDUAL TRACES TO PLOT
        origDirec = cd;
        cd("E:\KarinaLocalStorage\MatlabSavedMaterial\matlab exps");
        nExps = length(exps);
        xData = cell(1,nExps);
        yData = cell(1,nExps);
        shortestTraceLength = Inf;
        for expInd = 1:nExps
            %Get Experiment
            try
                load(exps(expInd))%Load experiment variable if already has been created and saved
            catch
                waitfor(msgbox(strcat(exps(expInd), " has not yet been imported. Select to import in next step.")));
                a_BoutAnalysis_MasterScript("import");
            end
            %Extract Relevant Traces
            try
                a=experiment.plotTraces.(traceType); %check if this trace type has already been added to experiment (to see all trace types, open "generateTrace" function in experiment object class file
            catch
                showIndividualPlots = false;
                experiment.generateTrace(traceType, showIndividualPlots)
            end
            xData{expInd} = experiment.plotTraces.(traceType).x;
            yData{expInd} = experiment.plotTraces.(traceType).y;
            key{expInd} = experiment.rawFileName(1:end-8);
            shortestTraceLength = min(shortestTraceLength,length(yData{expInd}));
            a = 1;
        end
        %GET AVERAGE and STDEV TRACES
        traceMatrix =  zeros(nExps,shortestTraceLength);
        for expInd = 1:nExps
            traceMatrix(expInd,:) = yData{expInd}(1:shortestTraceLength);
        end
        avgTrace = mean(traceMatrix,1);
        stdevTrace = std(traceMatrix,1);
        cd(origDirec)
    end
    %Plot overlayed traces and avg traces
    figure()
    hold on
    for traceInd = 1:length(xData)
        plot(xData{traceInd},yData{traceInd})
    end
    legend(key)
    hold off
    
    figure()
    plot(1:shortestTraceLength, avgTrace);
    hold on
    plot(1:shortestTraceLength, avgTrace + stdevTrace, ':');
    plot(1:shortestTraceLength, avgTrace - stdevTrace, ':');
end

