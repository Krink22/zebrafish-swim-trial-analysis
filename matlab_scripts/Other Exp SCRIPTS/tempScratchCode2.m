%QUICK CODE TO ANALYZE AGENCY "CATCH TRIAL" TRAINING DATA
clc

bouts = experiment.boutSeries;
trials = experiment.trialSeries;

onsetDelaysCL = [];
onsetDelaysOL = [];
trialSkips = 0;

for i = 1:length(trials)
    trial = trials(1,i);
    %Get trial state
    trialDur = (trial.endInd - trial.startInd)/6000;
    if trialDur > 2.4
        if isempty(trial.boutIDs{1,1}) %trialSkips
             trialState = "UNKNOWN"; %The way data is exported can't get trial state bc its saved to bout which there arent any. Need to go back to raw data to get?
             trialSkips = trialSkips + 1;
        else
            trialState = "OL";
        end
    else
        trialState = "CL";
    end
    
    %Get onsetDelay
    %***!!** calculates onset delay by subtracting bout start from trial
    %start because exp code for learning metric has a bug that is resulting
    %in negative durations for some CL trials (because finding time
    %relative to start of NEXT trial)
    trialStartInd = trial.startInd;
    if trialState=="OL" || trialState == "CL"
        firstBoutOfTrialID = trial.boutIDs{1,1};
        if isempty(firstBoutOfTrialID)
            disp(i);
            disp("ERROR: A TRIAL THAT WAS SHORTER THAN FULL TRIAL DUR HAS NO ASSOCIATED BOUT. THIS SHOULD NOT BE POSSIBLE.")
        else
            firstBoutOfTrial = bouts(1,firstBoutOfTrialID);
            onsetDelay_s = (firstBoutOfTrial.onInd - trialStartInd)/6000;
            if trialState== "OL"  
                onsetDelaysOL(end+1) = onsetDelay_s;
                placeholder = 1;
            elseif trialState== "CL"
                onsetDelaysCL(end+1) = onsetDelay_s;
            end
        end
    end
end
    

avgOLOnsetDelay_s = mean(onsetDelaysOL)
avgCLOnsetDelay_s = mean(onsetDelaysCL)
[h,p] = ttest2(onsetDelaysOL,onsetDelaysCL)
figure(1)
histfit(onsetDelaysOL)
title("OL");
figure(2)
histfit(onsetDelaysCL)
title("CL");
        