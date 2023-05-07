
function experiment = a_BoutAnalysis_MasterScript(experiment)
%Master script for bout analysis.
%Run  a_BoutAnalysis_MasterScript("import") to import new experiment
%Run a_BoutAnalysis_MasterScript(experiment) if experiment already imported

%% NEXT TO DO:
%troubleshoot why so many raw data bouts are getting cut off
%add in function to make movie of exp

    %% CLEAN UP ENVIRONMENT
        fclose('all');
        close all
        clc

    %% IMPORT RAW DATA (EXECUTE THIS MANUALLY IF DESIRED)
    playWithRawDataSwitch = 0;
    if playWithRawDataSwitch == 1
        startDpInd = 1;
        impData = plotArbitraryRawData(startDpInd);
        return %end script so can engage with data manually
        
        %PLOT A TRIAL
        %user set
        exp = experiment;
        trialId = 56;
        xUnitDivisor = 6000; %6 for ms, 6000 for s, 1 for dps
        %process data
        trialStartI = exp.trialSeries(1,trialId).startInd;
        trialEndI = exp.trialSeries(1,trialId).endInd;
        margin = round((trialEndI - trialStartI)/4);
        startI = trialStartI - margin ;
        endI = trialEndI + margin;
        x = (startI:endI)/xUnitDivisor;
        motor = impData(startI:endI,2);
        %plot
        figure(trialId)
        plot(x,motor); %motor channel
        hold on
        plot(x,impData(startI:endI,8),'r'); %thresh channel
        xline(trialStartI/xUnitDivisor,'k:'); %trial start
        xline(trialEndI/xUnitDivisor,'k:'); %trial end
        hold off
    end
    
    %% IMPORT AND EXTRACT DATA (INTERACTIVELY OPTIONAL)
    if experiment == "import"
        impDataSwitch= inputdlg('Import new data? Enter onset or duration if so','Import Data',1,"onset");
        expType = lower(impDataSwitch);
        if any(strcmp(["onset", "duration"],expType))
            clearvars -except expType
            experiment = process_12_chan_data(expType);
            saveDataSwitch = inputdlg('Save data? enter y');   
            if saveDataSwitch{1} == 'y'
                experiment.save()
            end 
        end
    else
        clearvars -except experiment
    end


    
    %% FUNCTIONS THAT OPERATE ON A TRIAL SERIES
    trialsToProcessInds = 1:length(experiment.trialSeries);
    %trialsToProcesInds = 1:10; %subset
    
    %Get inds of first bout and last bout in every trial
    firstBoutInds = experiment.extractTrialPropVect('getBoutID(1)', trialsToProcessInds);
    lastBoutInds = experiment.extractTrialPropVect('getBoutID(-1)', trialsToProcessInds);
    lastMax2BoutInds = experiment.extractTrialPropVect('getBoutID("lastMax2")', trialsToProcessInds);
    
    %% FUNCTIONS THAT OPERATE ON A BOUT SERIES (PLOTTING)
    ignoreSkippedTrials = 1;
    if ignoreSkippedTrials ==1
        firstBoutInds_noSkips = firstBoutInds(~isnan(firstBoutInds));
        lastBoutInds_noSkips = lastBoutInds(~isnan(lastBoutInds));
        lastMax2BoutInds_noSkips = lastMax2BoutInds(~isnan(lastMax2BoutInds));
    end
    boutsToPlotInds = 1:length(experiment.boutSeries); %plot all bout
    boutsToPlotInds = firstBoutInds; %plot only first bout in each series (trial?)
    boutsToPlotInds = firstBoutInds_noSkips;
    %boutsToPlotInds = lastBoutInds_noSkips;
    %boutsToPlotInds = lastMax2BoutInds_noSkips; %"last" of max 2 first bouts
    

    % Plot and Save boutReliefVect to text file for Playback
    plotAndSaveReliefVectSwitch = 0;
    if plotAndSaveReliefVectSwitch == 1
        saveReliefVect(experiment.boutSeries); %always for ALL BOUTS during training trials, regardless of what subset chosen for boutsToPlotInds
    end
    
    % Plot individual bouts
    plotBoutsSwitch = 0;
    if plotBoutsSwitch == 1
        boutsToPlotInds = [90, 93, 94, 95, 105];
        plotBouts(experiment.boutSeries, boutsToPlotInds);
    end
    
    %Plot timeseries of learning metric (duration or onset) with teaching threshes
    plotAvgLearningMetricSwitch = 0;
    if plotAvgLearningMetricSwitch == 1
        plotLearningMetricOverTime(experiment, boutsToPlotInds)
    end
    
    %Plot percent accuracy of learning metric over time (relative to a
    %single thresh, either first or hardest)
    plotAccuracyOverTimeSwitch = 0;
    if plotAccuracyOverTimeSwitch == 1
        nBLcollectionsToPlot = 1;
        nTrialsPerBLCollection = 50;
        nPostThreshChangePeriodsToPlot = 1000; %if this is more than max actual thresh changes will just plot them all
        plotAccuracyOverTime(experiment, boutsToPlotInds, nBLcollectionsToPlot, nTrialsPerBLCollection, nPostThreshChangePeriodsToPlot)
    end
   
    %Plot sliding avg success vect (relative to threshes AT TIME of bout)
    %% **Note: This is success per bout, which may or may not correspond to getting relief depending on whether program is set to give relief only on first bout in a trial
    plotAvgSuccessSwitch = 0;
    if plotAvgSuccessSwitch == 1
        plotSuccessOverTime(experiment.boutSeries,experiment.threshChangeSeries);
    end
    
    %Plot bout histo movie
    plotBoutHistoMovieSwitch = 0;
    if plotBoutHistoMovieSwitch == 1
        createExpMovie(experiment,'durExp',boutsToPlotInds);
    end
    
    %TROUBLESHOOTING FUNCTIONS ON BOUT SERIES
    plotSubThreshGapDursSwitch = 0;
    if plotSubThreshGapDursSwitch == 1
        plotSubThreshGapDurs(experiment.boutSeries,boutsToPlotInds)
    end
    
    
    
end
    
