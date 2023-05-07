function createExpMovie(expObj,boutPropStr,selectedBoutIDs)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here

  
    %Define Params
    threshChangesToShowInds = [1]; %select which threshChanges to plot. 1 means show only initial change from baseline.
    binSpan = 30;
    nBoutsPerHisto = 50;
    yMaxToggle = .08 ; %Set this to percent of bouts expect to fall in a 10ms span (obv depends on distribution but 5-10% usually right)
    nNewBoutsPerFrame=1;
    nBaselineBoutsToInclude = 140;
    nOverflowBouts = 100;
    pauseAtThreshShifts = 1;
    saveMovie = 0;
    movieFileName = '20210126_02';
    
    %Assemble Relevant Data
    boutPropVect = extractBoutPropVect(expObj,boutPropStr,selectedBoutIDs);
    threshesToPlot = expObj.threshChangeSeries(threshChangesToShowInds);
    
    %Calculate Derived Params
    startTrainingBoutID = threshesToPlot(1).boutID; %global boutID in experiment
    startTrainingBoutInd = find(sort(selectedBoutIDs)>startTrainingBoutID, 1, 'first') ;%boutInd in the series of bouts input ot this function
    startBoutInd = startTrainingBoutInd - nBaselineBoutsToInclude;
    maxBoutVal = max(boutPropVect);
    nBins = ceil(maxBoutVal/binSpan);
    histoEdges=0:floor(maxBoutVal/nBins):maxBoutVal;
    xMax= max(boutPropVect(~isoutlier(boutPropVect,'mean')))+50;
    xMin = min(boutPropVect(~isoutlier(boutPropVect,'mean')))-50;
    yMax=yMaxToggle*nBoutsPerHisto*binSpan/10; %based on rough estimate that I expect a max of ~4% of all bouts in any 10 ms bin.
    
    nIncludedBouts = length(boutPropVect) - startTrainingBoutInd -nOverflowBouts;
    endFrame = ceil((nIncludedBouts - (nBoutsPerHisto-1))/nNewBoutsPerFrame);
    
   
    %Initialize
    startFrame = 1;
    if saveMovie == 1 
    myMovie=[]; %create var first in case it doent exist yet so dont throw an error on next step
    clear myMovie; %delete if already exists
    end
    currentThreshPeriodInd = 0;
    currentThreshToShow = threshesToPlot(1); %Show first thresh during BL
    nextThreshToShow = threshesToPlot(currentThreshPeriodInd+1);
    
%run movie
    figure()
    for frameInd = startFrame:endFrame
        %Select Frame Data
        firstBoutInFrameInd = startBoutInd + (frameInd-1)*nNewBoutsPerFrame;
        windowBoutVals=boutPropVect(firstBoutInFrameInd:(firstBoutInFrameInd+nBoutsPerHisto-1));
        lastBoutInFrameId = selectedBoutIDs(firstBoutInFrameInd+nBoutsPerHisto-1); %To display in text annotation
        lastBoutInNextFrameId = selectedBoutIDs(firstBoutInFrameInd+nBoutsPerHisto); %To display in text annotation
        
         %Set forbidden zones to show (not necc same as thresh during that bout in exp)
         fZoneShortH = area([0 currentThreshToShow.minThresh], [yMax yMax],'FaceColor','r'); %"too short"
         hold on
         if xMax>currentThreshToShow.maxThresh
            fZoneLongH = area([currentThreshToShow.maxThresh xMax], [yMax yMax],'FaceColor','r'); %"too long"
         end
         %plot([minDurPerm,minDurPerm],[0,yMax],'r');
         %plot([maxDurPerm,maxDurPerm],[0,yMax],'r');
         
         
         %Plot histo
         histogram(windowBoutVals,histoEdges);
         ylim([0,yMax]);
         xlim([xMin,xMax]);
         title(sprintf('Frame: %d, Last Bout Num: %d | TrialId: #%d', frameInd, firstBoutInFrameInd+nBoutsPerHisto,lastBoutInFrameId));
         %Check if a thresh transition frame
         if frameInd == startFrame %show user baseline and wait for keypress to start movie
             title('BASELINE DISTRIBUTION');
             if pauseAtThreshShifts == 1
                pause();
             end
         end
         if lastBoutInNextFrameId > nextThreshToShow.boutID
             title(sprintf('END OF CURRENT THRESH PERIOD Frame: %d, Last Bout Num: %d | TrialId: #%d', frameInd, firstBoutInFrameInd+nBoutsPerHisto,lastBoutInFrameId));
             if pauseAtThreshShifts == 1
                pause();
             end
             pause(.001);
             if saveMovie == 1
                 myMovie(frameInd-startFrame+1)=getframe(gcf);
             end
             %Update to new threshes
             currentThreshPeriodInd = currentThreshPeriodInd + 1;
             currentThreshToShow = threshesToPlot(currentThreshPeriodInd);
             if length(threshesToPlot)>currentThreshPeriodInd
                nextThreshToShow = threshesToPlot(currentThreshPeriodInd+1);
             else
                 nextThreshToShow = ThreshChangeObj;
                 nextThreshToShow.boutID = nan;
             end
             %Display New Threshes
             title ('NEW THRESH REQUIREMENTS');
             fZoneShortH.XData = [0, currentThreshToShow.minThresh]; %"too short"
             if xMax>currentThreshToShow.maxThresh
                fZoneLongH.XData = [currentThreshToShow.maxThresh,xMax]; %"too long"
             end
             if pauseAtThreshShifts == 1
                pause();
             end 
         end
         pause(.001);
         if saveMovie == 1
             myMovie(frameInd-startFrame+1)=getframe(gcf);
         end
         hold off
    end

    if saveMovie == 1
        myVideo = VideoWriter(movieFileName,'MPEG-4');
        open(myVideo);
        writeVideo(myVideo, myMovie);
        close(myVideo);
    end
    
    

end