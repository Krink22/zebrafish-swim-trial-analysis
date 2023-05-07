close all
clc

%User Set
nBLTrials = 0; %BL trials currently detect as no swims because they are in boutOnset mode,
%so this will manually set them to having a response (WHICH WILL BE WRONG
%IF FISH DOESNT ALWAYS RESPOND, SO MAKE SURE TO CHANGE DETECTION AND UPDATE
%THIS BEFORE USING FOR REAL DATA OR DATA WHERE I HAVENT WATCHED TO BE SURE FISH RESPONDS ON ALL BLs!).
disp("WARNING: BL Trials manually set to 1. This is a shortcut for now since code isn't made to detect swims in bout onset mode. Address this before using without careful monitoring of BL.",'r')

x = 1:length(experiment.trialSeries);
for i=1:length(experiment.trialSeries)
    bInds = experiment.trialSeries(1,i).boutIDs{1,1};
    if i<= nBLTrials
       swimTrials(i) = 1;
    elseif isempty(bInds)
       swimTrials(i) = 0;
    else
       swimTrials(i)=1;
    end
     
end
swimTrialsAvg = movmean(swimTrials,[10,0]); 

plot(x,swimTrials,'o') %binary skips and swims
hold on
plot(x, swimTrialsAvg, '-x') %smoothed average rate of swims
 