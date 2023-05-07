        function [boutPropVect,boutTimeVect, boutTrialvect] = extractBoutPropVect(obj,boutPropStr,selectedBoutIDs)
        %UNTITLED5 For requested bouts, returns vectors of seclected bout
        %porperty (e.g. durExp), bout onset time, and bout trial ID
        %   Detailed explanation goes here

            boutPropVect = nan(length(selectedBoutIDs),1);
            boutTimeVect = nan(length(selectedBoutIDs),1);
            boutTrialvect = nan(length(selectedBoutIDs),1);
            for boutSubsetInd = 1:length(selectedBoutIDs)
                selectedBoutID = selectedBoutIDs(boutSubsetInd);
                boutPropVect(boutSubsetInd)=get(obj.boutSeries(selectedBoutID), boutPropStr);
                boutTimeVect(boutSubsetInd)=get(obj.boutSeries(selectedBoutID), "onT");
                boutTrialvect(boutSubsetInd)=get(obj.boutSeries(selectedBoutID), "trialID");
            end


        end