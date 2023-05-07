close all
clc
trialsW2PlusSwims = [];
secondSwimDurs = [];
for trialInd=1:length(experiment.trialSeries)
 if length(experiment.trialSeries(trialInd).boutIDs{1})>=2
     secondBoutId=experiment.trialSeries(trialInd).boutIDs{1}(2);
     trialsW2PlusSwims(end + 1) = trialInd;
     secondSwimDurs(end + 1) = experiment.boutSeries(secondBoutId).durExp;
 end

end

plot(trialsW2PlusSwims,secondSwimDurs)
hold on
plot([0,trialsW2PlusSwims(end)],[134,134],'r')