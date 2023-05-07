function saveReliefVect(expBoutSeries)
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here


% Find start of TRAINING period (i.e. first time any conditions placed on bout duration)
    peggingBoutInd=1; %Optionally don't use bout one for starting threshes, in case I tweaked right at start of file
    startMinAllowed = expBoutSeries(peggingBoutInd).minAllowed;
    startMaxAllowed = expBoutSeries(peggingBoutInd).maxAllowed;
    teachingThreshChanged = false;
    checkingBoutInd=peggingBoutInd;
    while teachingThreshChanged == false
        nextMinAllowed = expBoutSeries(checkingBoutInd).minAllowed;
        nextMaxAllowed = expBoutSeries(checkingBoutInd).maxAllowed;
        if nextMinAllowed > startMinAllowed ||  nextMaxAllowed < startMaxAllowed
            teachingThreshChanged = true;
        else 
        checkingBoutInd = checkingBoutInd + 1;
        end
    end
    firstTrainingBout=checkingBoutInd;
    
%Generate TRAINING Bout Relief Vect
    nBoutsExcluBcOutsideOfTrials = 0;
    trainingBoutTTLVect = nan(length(expBoutSeries)-firstTrainingBout,1);  
    for trainingBoutInd=1:length(trainingBoutTTLVect)
        expBoutInd = trainingBoutInd-1+firstTrainingBout;
        if isempty(expBoutSeries(expBoutInd).relief)
            disp("WARNING: a null bout was skipped -- was likely a bout near boundaries of an interval at import that was skipped due to overhang")
        elseif isnan(expBoutSeries(expBoutInd).trialID)
            nBoutsExcluBcOutsideOfTrials = nBoutsExcluBcOutsideOfTrials + 1;
        else
            trainingBoutTTLVect(trainingBoutInd) = expBoutSeries(expBoutInd).relief;
        end
    end
    disp("Bouts excluded due to occurring outside of trial periods:")
    disp(nBoutsExcluBcOutsideOfTrials) 
    trainingBoutTTLVect = trainingBoutTTLVect(~isnan(trainingBoutTTLVect));
    trainingBoutGiveReliefVect = trainingBoutTTLVect==0; %Give relief vect should be 1 where TTL vect was 0
    plot(movmean(trainingBoutGiveReliefVect,20))
    disp("Reminder: playback is bout based not trial based, ie each bout (as long as it occurs during any trial) will get a consequence of the same bout number from original experiment(again for bouts occuring during trials not in between. Individual trials may not therefore have the same outcomes as fish will almost certainly swim different numbers iof times on some trials, getting bout consequences out of alignment with trials of original experiment")
    
%Save Training Bout Relief Vect
    currentDirec=cd;
    cd E:/KarinaLocalStorage/MatlabSavedMaterial/playbackVects_starting2021
    fileID=fopen('giveReliefVect_lastExport.txt','wt');
    formatSpec = '%d'; % '%d\n'; %used to have a newline after each entry but as of 6/16/21 this was causing issues so switched to be all one long vector
    for i=1:length(trainingBoutGiveReliefVect) 
    fprintf(fileID,formatSpec,trainingBoutGiveReliefVect(i));
    end
    fclose(fileID);
    cd(currentDirec)
end

