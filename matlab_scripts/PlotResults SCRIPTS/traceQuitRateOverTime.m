function  traceQuitRateOverTime(exp, showPlot)
close all
clc

%Find start of each session and label CL or OL
minGapBtwnSessions = 60; %seconds, greater than this between trials means start of a new session
sampRate = 6000;
minGapBtwnSessionsDps = minGapBtwnSessions*sampRate;
endOfLastTrial = exp.trialSeries(1).endInd;
sessionStartTrials=[1];
for trialId = 2:length(exp.trialSeries) %Find session starts (sessions are grouped sequences of trials with a time gap between them)
    trial = exp.trialSeries(trialId);
    if (trial.startInd - endOfLastTrial) > minGapBtwnSessionsDps %check if new session starting
        sessionStartTrials(end + 1) = trialId;
    end
    endOfLastTrial = trial.endInd;
end %
for sessionId = 1:length(sessionStartTrials)
    trial = exp.trialSeries(sessionStartTrials(sessionId));
    firstBoutOfSessionID = trial.boutIDs{1};
    if isempty(firstBoutOfSessionID)
        disp("No swims detected in first trial of this trial series. Need to update code to find first trial with swims in it to extract data about threshes for this trial series") 
    else
        minAllowed = exp.boutSeries(1,firstBoutOfSessionID).minAllowed;
        maxAllowed = exp.boutSeries(1,firstBoutOfSessionID).maxAllowed;
        if (maxAllowed - minAllowed) <5
            disp("OL")
            sessionKey(length(sessionStartTrials)) = "OL";
        else
            disp("CL")
            sessionKey(length(sessionStartTrials)) = "CL";
        end
    end
end
sessionStartTrials(end+1) = trialId+1; %fake session start to use in next session when determining nTrials per session
disp(sessionStartTrials)

%Make moving avg responsiveness for each session
windowSz = 20; %10
for sessionId= 1:length(sessionStartTrials)-1
    firstSessionTrialGlobalId = sessionStartTrials(sessionId);
    nSessionTrials = sessionStartTrials(sessionId+1) - firstSessionTrialGlobalId;
    trialWithinSessionInd = 1;
    for trialGlobalId=firstSessionTrialGlobalId:firstSessionTrialGlobalId + nSessionTrials -1
        bInds = exp.trialSeries(1,trialGlobalId).boutIDs{1,1};
        if isempty(bInds)
           swimTrials{sessionId}(trialWithinSessionInd) = 0;
        else
           swimTrials{sessionId}(trialWithinSessionInd)=1;
        end
        trialWithinSessionInd = trialWithinSessionInd +1;
    end  
    swimTrialsAvg{sessionId} = movmean(swimTrials{sessionId},[windowSz,0]);
end

%Save analysis traces to experiment
for sessionId= 1:length(sessionStartTrials)-1
    x = 1:length(swimTrialsAvg{sessionId});
    y = swimTrialsAvg{sessionId};
    exp.plotTraces.(sessionKey(sessionId)) = struct(...
        'x', x, ...
        'y', y ...
        );
end


%Plot CL and OL traces overlayed
if showPlot == true
    plot(exp.plotTraces.CL.x,exp.plotTraces.CL.y);
    hold on
    plot(exp.plotTraces.OL.x,exp.plotTraces.OL.y);
    plotKey = ["CL", "OL"];
    legend(plotKey)
end


end


