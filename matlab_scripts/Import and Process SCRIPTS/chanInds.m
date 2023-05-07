function chInds = chanInds()

% How to make/use a dictionary of channel names and inds
% c = containers.Map
% c('foo') = 1
% c(' not a var name ') = 2
% keys(c)
% values(c)

%Create dict like object
chInds = containers.Map;
% Define which channels are which
chInds('motorCh1') = 1;
chInds('motorCh2') = 2;
chInds('boutStartT') = 3;
chInds('boutEndT') = 4;
chInds('learningMetricCh') = 5;
chInds('TTLCh') = 6; %trialPeriodOn
chInds('threshCh1') = 7;
chInds('threshCh2') = 8;
chInds('maxTeachingMetricCh') = 9;
chInds('minTeachingMetricCh') = 10;
chInds('stimVCh') = 11; 

