function experiment = process_11_chan_data(expType)
%PROCESS_11_CHAN_DATA Process raw 11chan data into a data structure suited tos analysis
%   Detailed explanation goes here

%0) User Set Values
    maxMinsToProcess = 600;
    dataFolder= 'E:\KarinaLocalStorage'; %'E:\KarinaLocalStorage';%

%1) Establish General Use Vars
    nDataChans = 12;
    sampRate = 6000; %samples per second
    bytesPerEntry = 4; %this many positions in file for every resulting entry when imported into matlab. Found this empirically, though assume has to do with importing as "float"

%2) Pick and open Data File    
    [fileInstance, fileName] = SelectAndOpenDataFile(dataFolder);

%3) Define Intervals
    minPerIvl = 600;
    dpPerIvl=minPerIvl*60*sampRate;
    ivlStartPositions = dataParse(fileInstance, minPerIvl, nDataChans, sampRate, bytesPerEntry);
    %Adjust max number of Ivls to process if necessary
    if length(ivlStartPositions) > ceil(maxMinsToProcess/minPerIvl)
        nIvlsToProcess = ceil(maxMinsToProcess/minPerIvl);
    else
        nIvlsToProcess = length(ivlStartPositions);
    end

%4) Extract Bout and Trial Series (one interval at a time)
    fprintf('Extracting bout information for %.f intervals \n',nIvlsToProcess);
    approxNBoutsPerIvl = minPerIvl*100; %overestimate, used to initialize a large enough matrix
    expBoutSeries(nIvlsToProcess*approxNBoutsPerIvl)=BoutObj(); %semi-initialize
    nBouts=0;
    nTrials = 0;
    for ivl = 1:nIvlsToProcess
        fprintf('...PROCESSING INVL %i...\n',ivl);
        impData = ivlImport(ivl, ivlStartPositions, fileInstance, nDataChans, bytesPerEntry); %Import interval of raw data
        
        %Extract Bouts
        boutSeriesIvl = boutExtractIvl(impData,sampRate,dpPerIvl,ivl); %Extract Bout Data
        if ~isempty(boutSeriesIvl)
            for boutInd = (1:length(boutSeriesIvl))
                boutSeriesIvl(boutInd).boutID = boutInd + nBouts;
                boutSeriesIvl(boutInd).trialID = nan; %boutInd + nBouts;
            end
            expBoutSeries((nBouts+1):(nBouts+length(boutSeriesIvl))) = boutSeriesIvl(:);
            nBouts = nBouts+length(boutSeriesIvl);
        end
        
        %Extract Trials (ie a single aversive stim period)
        %Something wacky happening in next line assigning bouts to trials
        %at least with file 20200304_01
        trialSeriesIvl = trialExtractIvl(impData,sampRate,dpPerIvl,ivl,boutSeriesIvl,expType); %Extract Trial Data
        if ~isempty(trialSeriesIvl)   %Get trials' global IDs and tag associated bouts with them         
            for trialIvlInd = (1:length(trialSeriesIvl))
                %Label each trial in Ivl with its globalID
                trialSeriesIvl(trialIvlInd).trialID = trialIvlInd + nTrials; %nTrials is total trials in whole exp up until this ivl
                boutIDsInTrial = trialSeriesIvl(trialIvlInd).boutIDs{1};
                %label all bouts in trial with trial ID
                for boutTrialInd = 1:length(boutIDsInTrial)
                    boutID = boutIDsInTrial(boutTrialInd);
                    if ~isempty(boutID)
                        expBoutSeries(boutID).trialID = trialSeriesIvl(trialIvlInd).trialID;
                    end
                end
                %disp(trialIvlInd) %show what trial currently being
                %processed
            end
            expTrialSeries((nTrials+1):(nTrials+length(trialSeriesIvl))) = trialSeriesIvl(:);
            nTrials = nTrials+length(trialSeriesIvl); 
        end
    
    end
    expBoutSeries=expBoutSeries(1:nBouts); %Get rid of excess bout spaces that were never used
    expTrialSeries=expTrialSeries(1:nTrials); %Get rid of excess trial spaces that were never used
    
%5) Extract Thresh Change Series 
    try
        expThreshChangeSeries = threshChangeExtractSeries(expBoutSeries);
    catch
        disp("NOTE: No teaching thresh changes were found")
        expThreshChangeSeries(1) = ThreshChangeObj();
    end
    
%6) Close File
    fclose('all');
    
%7) Create and fill Experiment Object

    experiment = ExpObj(expBoutSeries, expTrialSeries, expThreshChangeSeries);
    experiment.rawFileName = fileName;

end

