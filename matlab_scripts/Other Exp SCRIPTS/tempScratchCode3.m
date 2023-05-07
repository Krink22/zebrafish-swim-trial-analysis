

for i = 1:length(trials)
    trial=trials(i);
    trialDur(i) = (trial.endInd - trial.startInd)/6000;
end
    
plot(trialDur,'o')