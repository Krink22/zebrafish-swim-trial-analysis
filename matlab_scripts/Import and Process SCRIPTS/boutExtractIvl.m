function boutSeriesIvl = boutExtractIvl(impData, sampRate, dpPerIvl, ivl)
% Extract data about bouts.

%NOTE: DURING EXP, DATA ABOUT A BOUT GETS SAVED 1 LOOP AFTER QUALIFYING BOUT TERM DETECTED.
%User Set
notification = "Note 9/13/22: bout termInds are detected posthoc because data collection doesnt start at t=0 of exp, so bout term times cant be used to find inds directly. Everything else about bouts including duration, learning metric and success are taken directly from experiment logged data, so the bout inds should only affect whether a bout is ascertained to have completed within a trial or not.";
disp(notification)

%Initialize
    dpsPerMillisec=sampRate/1000;
    chInds = chanInds(); %define channel indices 
    boutRawDataPadding = 150 * dpsPerMillisec; % dps before and after bout to include in raw data
 
%Get inds when bout data was recorded
    boutTermData = impData(:,chInds('boutEndT'));
    boutSavedDataInds = (1:length(boutTermData))' .* (boutTermData~=0);
    boutSavedDataInds = boutSavedDataInds(boutSavedDataInds~=0);

if ~isempty(boutSavedDataInds) %make sure there are bouts in interval before continuing
    
    
%Get bout start and term inds from raw motor data
    rawMotor=impData(:,chInds('motorCh2'));
    rawThresh=impData(:,chInds('threshCh2'));
    [boutStartIndsIvlFromRaw, boutTermIndsIvlFromRaw] = rawMotorBoutStartsAndTermsFinderForOnsetDelayTraining(rawMotor,rawThresh,boutSavedDataInds,dpsPerMillisec);
    boutStartIndsGlblFromRaw= boutStartIndsIvlFromRaw + dpPerIvl*(ivl-1);
    boutTermIndsGlblFromRaw= boutTermIndsIvlFromRaw + dpPerIvl*(ivl-1);
         
%Get bout start and term time, recorded during exp
    %NOTE: the times recorded in data likely will not perfectly line up with the
    %time calculated from indices of bout onset and offset.
    boutStartT = impData(boutSavedDataInds,chInds('boutStartT'));
    boutTermT = impData(boutSavedDataInds,chInds('boutEndT'));
    
%Get bout start ind based on boutStartT and boutEndT recorded in exp
    boutDurExp = boutTermT - boutStartT;
    boutDpsExp = boutDurExp * dpsPerMillisec;
    boutStartIndsIvlFromExp = boutTermIndsGlblFromRaw - boutDpsExp; %9/13/22 When I tried to calculate bout start and end inds by converting recorded times in exp to dps it was off -- suggesting first ind of recorded data prob delayed relative to t = 0 of exp. So to set bout start Ind based on experiment, use posthoc termination ind and duration of bout
    boutStartIndsGlblFromExp = boutStartIndsIvlFromExp + dpPerIvl*(ivl-1);

%Compare duration based on exp times vs posthoc detected inds time
    boutDurExp = boutTermT - boutStartT;
    boutDurPostHoc = (boutTermIndsIvlFromRaw - boutStartIndsIvlFromRaw) / dpsPerMillisec;
    durDiffs = abs(boutDurPostHoc(:) - boutDurExp(:));
    dursExpVsPostMetric = median(durDiffs);
    dursOutliersIvlInds = isoutlier(durDiffs) .* (1:length(durDiffs))';
    dursOutliersIvlInds = dursOutliersIvlInds(dursOutliersIvlInds~=0);
    fprintf('      Median difference between ad hoc and post hoc bout dur measurements: %.f ms\n',dursExpVsPostMetric);
    if length(dursOutliersIvlInds) >=1
            nOutliers = length(dursOutliersIvlInds);
            valsOutliers = durDiffs (dursOutliersIvlInds);
            [minOutDur, minOutInd] = min(valsOutliers);
            minOutIndIvl = dursOutliersIvlInds(minOutInd);
            [maxOutDur, maxOutInd] = max(valsOutliers);
            maxOutIndIvl = dursOutliersIvlInds(maxOutInd);
            fprintf('      Outlier Differences: %d bouts  Min: boutIndIvl %d, dur %.f ms | Max: boutIndIvl: %d, dur %.f ms \n',nOutliers, minOutIndIvl, minOutDur, maxOutIndIvl, maxOutDur);
    end
%Get stim relief or not %!!**!!4/24/23 Note this could lead to errors in
%onsetDelay analyses because this evaluates stim after boutTerm, not after
%onset, so in cases where swim goes to end of trial, for example, will
%look like got relief even in OL when it definitely didnt
    if length(impData)>boutSavedDataInds(end)+100
        stimCheckInds = boutSavedDataInds + 100;%check 100 ms after bout data recorded in case takes time for aversive stim controlling voltage to ramp to new value

    else
        stimCheckInds = [boutSavedDataInds(1:end-1); length(impData)]; %Max out the last ind if the extra 100 dps would go past the end
    end
    stimReliefs = impData(stimCheckInds,chInds('stimVCh')); 

%Get min and max teachingMetrics
    minsAllowed = impData(boutSavedDataInds,chInds('minTeachingMetricCh')); 
    maxsAllowed = impData(boutSavedDataInds,chInds('maxTeachingMetricCh'));

%Get bout success or not
    boutLearningMetrics = impData(boutSavedDataInds,chInds('learningMetricCh'));
    boutSuccesses = (boutLearningMetrics>minsAllowed).*(boutLearningMetrics<maxsAllowed);    
    
%Initialize BoutSeries
boutSeriesIvl(length(boutSavedDataInds),1) = BoutObj();

%Fill in Bouts Info
fprintf('%.f bouts in this interval \n',length(boutSeriesIvl));

for bInd = 1:length(boutSeriesIvl)
    boutSeriesIvl(bInd).sampRate = sampRate;
    rawDataClipStartIndIvl = boutStartIndsIvlFromRaw(bInd)-boutRawDataPadding;
    rawDataClipEndIndIvl = boutTermIndsIvlFromRaw(bInd)+boutRawDataPadding;
    if(rawDataClipStartIndIvl>=1 && rawDataClipEndIndIvl < length(impData))
        boutSeriesIvl(bInd).rawDataChs =   impData(rawDataClipStartIndIvl:rawDataClipEndIndIvl,:);
        boutSeriesIvl(bInd).rawDataStartInd = boutStartIndsGlblFromRaw(bInd)-boutRawDataPadding;
    else
        disp(bInd)
        disp ('this bout was too close to start or end of interval to get full-length raw data clip, raw data clip will be empty')
        close all
        figure(99)
        hold on
        plotBuffer = 500; %dps before detected boutOnset to plot
        if(boutStartIndsIvlFromRaw(bInd)>plotBuffer)
            plot(impData((boutStartIndsIvlFromRaw(bInd) - plotBuffer):end,chInds('motorCh2')))
            plot(impData((boutStartIndsIvlFromRaw(bInd) - plotBuffer):end,chInds('threshCh2')))
        else
            plot(impData(1: boutTermIndsIvlFromRaw(bInd) + plotBuffer,chInds('motorCh2')))
            plot(impData(1: boutTermIndsIvlFromRaw(bInd) + plotBuffer,chInds('threshCh2')))
        end
        plot([plotBuffer,plotBuffer],[0,plotBuffer],'g')
        boutDur = boutTermIndsIvlFromRaw(bInd) - boutStartIndsIvlFromRaw(bInd);
        plot([plotBuffer+boutDur,plotBuffer+boutDur],[0,plotBuffer],'r')
        a='wait';
    end
        boutSeriesIvl(bInd).onT =          boutStartT(bInd); %recorded during exp
        boutSeriesIvl(bInd).offT =         boutTermT(bInd); %recorded during exp
        boutSeriesIvl(bInd).onInd =        boutStartIndsGlblFromRaw(bInd);% as of 9/13/22 made this based on experiments bout detection instead of posthoc  %boutStartIndsGlblFromRaw(bInd); %assessed posthoc
        boutSeriesIvl(bInd).offInd =       boutTermIndsGlblFromRaw(bInd);  %assessed posthoc
        boutSeriesIvl(bInd).durExp =       boutDurExp(bInd);
        boutSeriesIvl(bInd).durPostHoc =   boutDurPostHoc(bInd);
        boutSeriesIvl(bInd).learningMetric = boutLearningMetrics(bInd);
        %postUsT
        %postCsT
        boutSeriesIvl(bInd).minAllowed =   minsAllowed(bInd);
        boutSeriesIvl(bInd).maxAllowed =   maxsAllowed(bInd);
        boutSeriesIvl(bInd).success =   boutSuccesses(bInd);
        boutSeriesIvl(bInd).relief =       stimReliefs(bInd);
end

else
    boutSeriesIvl = [];
end