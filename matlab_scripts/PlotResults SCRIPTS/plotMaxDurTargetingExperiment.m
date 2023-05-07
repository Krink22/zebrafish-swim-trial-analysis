function [firstBoutOnsetDelaysS,trialDursS] = plotMaxDurTargetingExperiment(experiment)
    sampRate = 6000; %samples per second
    nTrials = length(experiment.trialSeries);

    %Get onset time of first bouts in each trial (Cant use extractTrialPropVect
    %method bc in main data processing bouts that dont terminate in a trial are
    %excluded from trial, but we want them for this analysis
    boutInd = 1;
    for trialID = 1:nTrials
        trialStartInd = experiment.trialSeries(trialID).startInd;
        trialStartInds(trialID) = trialStartInd;
        trialEndInds(trialID) = experiment.trialSeries(trialID).endInd;
        if boutInd > length(experiment.boutSeries) %if past last bout in experiment stop looking for bouts in trials
            trialFirstBoutOnInd(trialID) = NaN;%trialStartInds(trialInd) - sampRate; %if no bout detected for this trial set onset to one sec before trial onset
            allBoutsInTrialOnInds(trialID,1) = NaN;
            allBoutsInTrialOffInds(trialID,1) = NaN;
        else
        boutInPrevTrialInd = 2; %the while loop finishes looping through and saving onsets of all bouts on previous trial before finding first bout of current trial
        while experiment.boutSeries(boutInd).onInd < trialStartInd
            if trialID > 1
                allBoutsInTrialOnInds(trialID - 1,boutInPrevTrialInd) = experiment.boutSeries(boutInd).onInd; %as tick through remaining bouts of prev trial after first, add them to its list of bouts 
                allBoutsInTrialOffInds(trialID - 1,boutInPrevTrialInd) = experiment.boutSeries(boutInd).offInd;
                boutInPrevTrialInd = boutInPrevTrialInd + 1;
            end
            boutInd = boutInd + 1;
        end
        boutOnInd = experiment.boutSeries(boutInd).onInd;     
        if trialID < nTrials %for all but last trial, check if this bout belongs to next trial, which indicates no bouts initiated on this trial
            if boutOnInd >  experiment.trialSeries(trialID + 1).startInd
                trialFirstBoutOnInd(trialID) = NaN;%trialStartInds(trialInd) - sampRate; %if no bout detected for this trial set onset to one sec before trial onset
                allBoutsInTrialOnInds(trialID,1) = NaN;
                allBoutsInTrialOffInds(trialID,1) = NaN;
            else
            trialFirstBoutOnInd(trialID) = boutOnInd;
            allBoutsInTrialOnInds(trialID,1) = experiment.boutSeries(boutInd).onInd; %start full set of bouts for this trial with first bout of trial
            allBoutsInTrialOffInds(trialID,1) = experiment.boutSeries(boutInd).offInd;
            boutInd = boutInd + 1;
            end
        else  
            %allBoutsInTrialOnInds(trialInd,boutInTrialInd) = boutOnInd;
            trialFirstBoutOnInd(trialID) = boutOnInd;
            allBoutsInTrialOnInds(trialID,1) = experiment.boutSeries(boutInd).onInd;
            allBoutsInTrialOffInds(trialID,1) = experiment.boutSeries(boutInd).offInd;
            boutInd = boutInd + 1;
        end
        end
    end
    trialDursS = (trialEndInds - trialStartInds)/sampRate;
    firstBoutOnsetDelaysS = (trialFirstBoutOnInd - trialStartInds)/sampRate;
    allBoutsInTrialOnInds(allBoutsInTrialOnInds==0) = NaN;
    allBoutsInTrialOnsetDalayS = (allBoutsInTrialOnInds - repmat(trialStartInds',1,size(allBoutsInTrialOnInds,2)))/sampRate;
    allBoutsInTrialOffsetDalayS = (allBoutsInTrialOffInds - repmat(trialStartInds',1,size(allBoutsInTrialOffInds,2)))/sampRate;
    
    %Get inds of trials with and without responses
    trialsWithRespInds = find(~isnan(firstBoutOnsetDelaysS));
    trialsWithoutRespInds = find(isnan(firstBoutOnsetDelaysS));
    
    %Get trialDur Period Bounds
    trialDurPeriodLastTrialID = find(abs(trialDursS(2:end)-trialDursS(1:end-1))>.1); %last trial of current dur
    trialDurPeriodLastTrialID = [trialDurPeriodLastTrialID,nTrials];
    trialDurPeriodFirstTrialID = [1,(trialDurPeriodLastTrialID(1:end-1) + 1)];
    
    %For trialDur period, get statistics
    nPeriods = length(trialDurPeriodFirstTrialID);
    for i = 1:nPeriods
        periodStartTrial = trialDurPeriodFirstTrialID(i);
        periodLastTrial =trialDurPeriodLastTrialID(i);
        periodTrialDurs(i) = round(mean(trialDursS(periodStartTrial:periodLastTrial)),1);
        pctl_5s(i) = prctile(firstBoutOnsetDelaysS(periodStartTrial:periodLastTrial),5);
        pctl_95s(i) = prctile(firstBoutOnsetDelaysS(periodStartTrial:periodLastTrial),95);
    end
        
    
    
    %PLOT
    figure(1)
    ylabel("Time after trial Start")
    xlabel("Trial")
    hold on
    
    %Plot First Bout Onset Delay Info
    plot(1:length(firstBoutOnsetDelaysS),firstBoutOnsetDelaysS, 'bo')
    plot(trialsWithoutRespInds, trialDursS(trialsWithoutRespInds)+ 1, 'xk');

    %Plot First Bout Offset Delay Info
    if false %true
        for trialID = 1:nTrials
            firstBoutTerm = allBoutsInTrialOffsetDalayS(trialID,1);
            if ~isnan(firstBoutTerm)
                plot(trialID,firstBoutTerm,'r*');
            end
        end
    end
    
    %Plot Trial Duration Info
    if true
        plot(trialDursS, 'r:') %plot red line indicating trial duration
    end
    if false
        for pInd=2:nPeriods
            xline(trialDurPeriodFirstTrialID(pInd),'r'); %plot vertical line at start of trial
            indicateLastPeriodsDistribution = false;
            if indicateLastPeriodsDistribution
                %plot previous period metric for comparison with horizontal line segment
                if periodTrialDurs(pInd) > periodTrialDurs(pInd-1) %if this period has longer trials plot 95th pctl thresh of last period
                    plot([trialDurPeriodFirstTrialID(pInd),trialDurPeriodLastTrialID(pInd)],[pctl_95s(pInd-1),pctl_95s(pInd-1)],'g:')
                else
                    plot([trialDurPeriodFirstTrialID(pInd),trialDurPeriodLastTrialID(pInd)],[pctl_5s(pInd-1),pctl_5s(pInd-1)],'g:')
                end
            end
        end
    end
    
    %Plot Other Bout Onset Delays
    if true
        for trialID = 1:nTrials
            spareBouts = allBoutsInTrialOnsetDalayS(trialID,2:end);
            spareBouts = spareBouts(~isnan(spareBouts));
            if length(spareBouts) >= 1
                plot(repmat(trialID,1,length(spareBouts)),spareBouts,'co');
            end
        end
    end
    
   legend("First Swim", "Skipped Trial", "Other Swims")
    
    %CALCULATE SUMMARY INFORMATION AND PLOT:
    %Plot fraction of trials with first swim in each duration bucket for
    %each period
    
    uniqueTrialDurs = unique(periodTrialDurs);   
    for pInd=1:nPeriods
        lastUniqueTrialDur = 0;
        for uniqueTrialDurInd = 1:length(uniqueTrialDurs)
            bracketLabels(uniqueTrialDurInd) = strcat(num2str(lastUniqueTrialDur),"< t <",num2str(uniqueTrialDurs(uniqueTrialDurInd)));
            firstTrialID = trialDurPeriodFirstTrialID(pInd);
            lastTrialID = trialDurPeriodLastTrialID(pInd);
            trialsToAssess = firstBoutOnsetDelaysS(firstTrialID:lastTrialID);
            nTrialsInUniqueBracket = sum((trialsToAssess>lastUniqueTrialDur) .* (trialsToAssess < uniqueTrialDurs(uniqueTrialDurInd)));   
            fractionTrialsInEachBracket(pInd,uniqueTrialDurInd) = nTrialsInUniqueBracket/(lastTrialID - firstTrialID + 1);
            lastUniqueTrialDur = uniqueTrialDurs(uniqueTrialDurInd);
        end
    
    end
    disp("rows = periods, columns = unique trial durations")
    disp(fractionTrialsInEachBracket)
    
    
    %BAR CHART (FIG 2)
    %Average results for periods w/same trial dur together for summary plot
    for uniqueTrialDurInd = 1:length(uniqueTrialDurs)
        uniqueTrialDur = uniqueTrialDurs(uniqueTrialDurInd);
        rowInds = find(periodTrialDurs == uniqueTrialDur);
        avgfractionTrialsInEachBracket(uniqueTrialDurInd,:) = mean(fractionTrialsInEachBracket(rowInds,:),1);
    end
    figure(2)
    bracketLabelsCat = categorical(bracketLabels);
    bar(reordercats(bracketLabelsCat, string(bracketLabelsCat)), avgfractionTrialsInEachBracket'); %reordering is necessary because for some reason when enter a categorical directly into a barchart plots in alphabetical order (e.g. so 0.5<t comes before 0<t)
    ylabel("% of Trials")
    xlabel("First Swim Time") 
    legend(split(num2str(uniqueTrialDurs)));
    
    figure(3)
    bHand = bar(categorical(split(num2str(uniqueTrialDurs))),avgfractionTrialsInEachBracket, 'FaceColor',"flat");
    ylabel("% of Trials with first Swim in Specified Time Window")
    xlabel("Trial Duration")
    legend(bracketLabels)
    %Change to rainbow color for easier reading
    c=hsv(5); %break rainbow hsv colormap into 6 discrete colors
    colormap(c(1:size(avgfractionTrialsInEachBracket,2),:)); %take as many colors from colormap as number of bars
    for k = 1:size(avgfractionTrialsInEachBracket,2)
        bHand(k).CData = k;
    end
    
    a = 1;
end