function  plotAccuracyOverTime(exp, boutInds, nBLcollectionsToPlot, nTrialsPerBLCollection, nPostThreshChangePeriodsToPlot)
%UNTITLED9 Summary of this function goes here
%   Detailed explanation goes here

%WARNINGS AND REMINDERS:
message1 = "REMINDER 1: training accuracy may not start at exact expected thresh (usually 50%) if there were multiple swims of exactly the threshold duration in starting distribution. These will all count as fails since succcess requires <> teaching thresh. Problem should only be severe if quite narrow short distribution"; 
message2 = "WARNING 1: for experiments before 11/30/22 median was short by half an index, so training accuracy likely to start slightly below intended baseline for ceiling training and above for floor";
message = strcat(message1, message2);
popup = msgbox(message,"Warnings and Reminders");

%USER SETTIGS
evalVsHardestThreshSwitch=0; %if =0, will evaluate against specified thresh ind 
chosenThresh = 1; %15;%36; %Only applies if evalVsHardestThreshSwitch=0
bwBinSize = 49;%How many dps BEHIND the current dp's index to inclue in avg for that timepoint


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------THRESH CHANGE DETECTION AND PLOT-----------------

%Plot times of all thresh changes (red = thresh got harder, green = got
%easier) and value of hardest thresh and final thresh
nThreshChangesToPlot = min(length(exp.threshChangeSeries),nPostThreshChangePeriodsToPlot);

%Get info for each thresh change
threshAssociatedInfoUnsorted = zeros(length(exp.threshChangeSeries),2); %will need to sort bc threshes dont appear to be stored in order of time
for newThreshInd = 1:length(exp.threshChangeSeries)%Get trials associated with each thresh change
        associatedBoutID = exp.threshChangeSeries(newThreshInd).boutID;
        if sum(boutInds == associatedBoutID) == 0
            disp("Note: nearest bout to thresh change was not one of the bouts input to this function (likely not a first bout or outside of trial), so will plot at next bout that is")
            while sum(boutInds == associatedBoutID) == 0
                if associatedBoutID < length(exp.boutSeries)
                associatedBoutID = associatedBoutID + 1;
                else
                    break
                end
            end
        end
        threshAssociatedInfoUnsorted(newThreshInd,1) = get(exp.boutSeries(associatedBoutID), "trialID");
        if exp.threshChangeSeries(newThreshInd).threshChangePlotColor == 'g'
            threshAssociatedInfoUnsorted(newThreshInd,2)=1;
        elseif exp.threshChangeSeries(newThreshInd).threshChangePlotColor == 'r'
            threshAssociatedInfoUnsorted(newThreshInd,2)=-1;
        end
        threshAssociatedInfoUnsorted(newThreshInd,3) = exp.threshChangeSeries(newThreshInd).minThresh;
        threshAssociatedInfoUnsorted(newThreshInd,4) = exp.threshChangeSeries(newThreshInd).maxThresh;
end
%Find first and last thresh changes to plot
threshAssociatedInfoSorted = sortrows(threshAssociatedInfoUnsorted,1); % sorted in order of thresh occurence, each row contains thresh's trial id, color, minThresh, maxThresh
threshChangeTrials = threshAssociatedInfoSorted(:,1); %global trialId associated with each thresh change
threshChangeColors = threshAssociatedInfoSorted(:,2);
firstThreshTrialId = threshChangeTrials(1);
if length(threshChangeTrials) <= nThreshChangesToPlot
    lastTrialToPlot = 'end';
else
    lastTrialToPlot =threshChangeTrials(nThreshChangesToPlot + 1) -1;
end
%Find value of hardest thresh and final thresh
if evalVsHardestThreshSwitch==1  
    evalThreshMin = max(threshAssociatedInfoSorted(1:nThreshChangesToPlot,3));
    evalThreshMax = min(threshAssociatedInfoSorted(1:nThreshChangesToPlot,4));
else
    evalThreshMin = threshAssociatedInfoSorted(chosenThresh,3);
    evalThreshMax = threshAssociatedInfoSorted(chosenThresh,4);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------ACCURACY CALCULATION AND PLOT-----------------

%Get plot's X and Y coords: time of bout onset and accuracy relative to hardest threshes
[learningMetricVect, associatedTimeVect, associatedTrialIDvect] = exp.extractBoutPropVect('learningMetric', boutInds); %includes only bouts supplied by boutInds input to this function, which is set by an input to this script, if called from a_BoutAnalysis_MasterScript then they should be set there.
if lastTrialToPlot == 'end'
    lastTrialToPlot = associatedTrialIDvect(end);
end
finalAccuracyVect = zeros(size(learningMetricVect));
for i = 1:length(finalAccuracyVect)
    if (learningMetricVect(i) > evalThreshMin && learningMetricVect(i) < evalThreshMax)
        finalAccuracyVect(i) = 1;
    end
end
%Make sliding Avg
slidingAvfinalAccuracy = movmean(finalAccuracyVect,[bwBinSize,0]); %Note the inds here are per bout in bout series input, but in some figs will be plotted vs associated TRIAL (specified on fig)
%Find Skipped Trials (ie trials for which the bout series sent to this
%function has no bout, this code is not looking at rawer data than that to
%determine skips)
skippedTrials=[];
slidingAvFinalAccuracyWithSkippedTrialsAdded = zeros(associatedTrialIDvect(end),1);
lastManagedTrialId = 0;
lastManagedTrialSlidingAccuracyVal = slidingAvfinalAccuracy(1);
for boutSeriesInd = 1:length(associatedTrialIDvect)
    boutTrialId = associatedTrialIDvect(boutSeriesInd);
    %Record skipped trials
    while boutTrialId - lastManagedTrialId > 1  %If skipped forward more than 1 since previous bout's trial then this is a skipped trial
        skippedTrials(end+1) = lastManagedTrialId+1; %Add trialID one forward of last managed trialId to missedTrialVect
        lastManagedTrialId = lastManagedTrialId + 1; %set that trialID to 
        slidingAvFinalAccuracyWithSkippedTrialsAdded(lastManagedTrialId) = lastManagedTrialSlidingAccuracyVal;
    end
    lastManagedTrialSlidingAccuracyVal= slidingAvfinalAccuracy(boutSeriesInd);
    slidingAvFinalAccuracyWithSkippedTrialsAdded(boutTrialId) = lastManagedTrialSlidingAccuracyVal;
    lastManagedTrialId = boutTrialId; %iterate lastManagedTrialId to reflect unskipped trial of this loop   
    a=1;
end

%Reindex trials ignoring skips
reindexedTrialsIds = 1:length(associatedTrialIDvect); %simple renumbering of trials associated with bout series supplied to this function based on their relative sequence as supplied irrespective of bouts or trials in orig experiment not supplied to this function
for i = 1:length(threshChangeTrials)%reindex threshold change trials
    reindexedThreshChangeTrials(i) = find(threshChangeTrials(i) == associatedTrialIDvect); %finds thresh's global trialId's location in vector of boutIds sent to this function. In this way thresh is reindexed from its global trialId to the relative "trialID" of this analysis where each of the selected bouts is considered a trial
end


%%%%%%%%%%%%%%%%%%%%%%PLOTS

%FIGURE 1: Accuracy including place holders for skipped trials
%Plot thresh changes
close all
figure()
for threshInd = 1:length(threshChangeTrials)
    xVect = repmat(threshChangeTrials(threshInd)-1,2,1); %minus 1 because the trial found is the first with NEW thresh and we want to mark the last trial with old thresh
    if threshChangeColors(threshInd) == -1
        plotColor = 'r';
    elseif threshChangeColors(threshInd) == 1
        plotColor = 'g';
    end
    plot (xVect, [0,1], plotColor)
    hold on
end
%Plot Accuracy
plot(associatedTrialIDvect,slidingAvfinalAccuracy,'bo:'); %Plots percent accuracy at bout vs TRIAL
skippedPlotY = min(slidingAvfinalAccuracy);
plot(skippedTrials,skippedPlotY*ones(length(skippedTrials)),'r.') %Indicate skipped bouts along bottom of plot
xlabel("NOTE: x-axis is trials but window for % accuracy is a number of BOUTS so can include more trials if some skipped. SKIPPED trials keep same % accuracy as previous trial.",'Color','r')
if evalVsHardestThreshSwitch==1  
    title('Percent Accuracy vs Trial (Hardest Thresh)')
else
    title('Percent Accuracy vs Trial (Chosen Thresh)')
end

%Crop based on n baseline collection and thresh change parameters
xMin = firstThreshTrialId - (nBLcollectionsToPlot * nTrialsPerBLCollection);
xMax = lastTrialToPlot;
xlim([xMin,xMax])

croppedPlotInds = (1:length(associatedTrialIDvect))'.*((associatedTrialIDvect>xMin) & (associatedTrialIDvect<xMax));
croppedPlotInds = croppedPlotInds(croppedPlotInds~=0);
yMax = 1;
yMin = min(slidingAvfinalAccuracy(croppedPlotInds));
ylim([yMin,yMax])


%FIGURE 2: Same as 1 (Accuracy including place holders for skipped trials), but SIMPLIFIED FOR GROUP PLOTS
figure()
firstTrialToPlot = firstThreshTrialId - (nBLcollectionsToPlot * nTrialsPerBLCollection);

xVals =(firstTrialToPlot:lastTrialToPlot) - firstThreshTrialId + 1; %set last BL trial as 0 (%plus 1 because the thresh trial found is the first with NEW thresh and we want to mark the last trial with old thresh)
yVals = slidingAvFinalAccuracyWithSkippedTrialsAdded(firstTrialToPlot:lastTrialToPlot);
plot(xVals,yVals)
hold on
xline(0)

%FIGURE 3: PLOT WITH TRIALS REINDEXED TO EXCLUDE SKIPS
figure()
%plot threshes
for threshInd = 1:length(reindexedThreshChangeTrials)
    xVect = repmat(reindexedThreshChangeTrials(threshInd) - 1,2,1); %minus 1 because the thresh change trial found is the first with NEW thresh and we want to mark the last trial with old thresh
    plot (xVect, [0,1], plotColor) %same plotColors apply as were already found for plot with Skips included
    hold on
end
%Plot Accuracy
plot(reindexedTrialsIds,slidingAvfinalAccuracy,'bo:'); %Plots percent accuracy at bout vs TRIAL


% !!!***!!!##***
% NEXT: 
% Try this third plot on recent data to make sure working
% consider adding xlim and ylim analogous to in figure 1
% consider adding fourth figure analagous to figure 2




a='stop';