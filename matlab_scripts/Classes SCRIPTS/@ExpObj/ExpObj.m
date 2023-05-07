classdef ExpObj < matlab.mixin.SetGet
    %UNTITLED4 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        rawFileName
        parameters %added 3/7/22. doesn't have anything automatically filled in but can add things for later use
        boutSeries
        trialSeries
        sessionSeries %added 3/7/22 to store info about delineations of exp into subparts like BL and training for swim dur exps or OL and CL for quitting exps
        threshChangeSeries 
        chInds
        trainingType
        plotTraces %added 3/7/22, for storing traces that can be used across different plots       
    end
    
    methods
        function obj = ExpObj(expBoutSeries, expTrialSeries, expThreshChangeSeries)
            %BOUT Construct an instance of this class
            %   A single experiment (one file)
            obj.boutSeries = expBoutSeries; %assign indices to channel names
            obj.trialSeries = expTrialSeries;
            obj.threshChangeSeries = expThreshChangeSeries;
            obj.chInds = chanInds();
            obj.plotTraces = struct();
        end

        %Functions Saved in Individual Files in class folder @ExpObj:
        
        [boutPropVect,boutTimeVect,trialIDVect]  = extractBoutPropVect(obj,boutPropStr,selectedBoutIDs);
        generateTrace(obj, traceType, showPlot)
        
        
        %The following functions SHOULD be saved in separate method files. I thought it wasn't
        %working so defined them directly here in object file, but later realized there was a different reason they werent
        %working which has been fixed. So now should move these.
               
        function [trialPropVect] = extractTrialPropVect(obj, extrCommandStr, selectedtrialIDs)
            %UNTITLED5 runs an extraction command on each trial in
            %trialInds vect and returns a vector of results
            %   e.g. extractTrialPropVect('getBoutID(1)', [1,4,6]) will
            %   return the boutInd of the first bout of each trial
            trialPropVect = nan(length(selectedtrialIDs),1);
            for trialInd = 1: length(selectedtrialIDs)
                trialID = selectedtrialIDs(trialInd);
                trial = obj.trialSeries(trialID);
                extrCommand=strcat('trial.',extrCommandStr);
                prop =eval(extrCommand);
                if ~isempty(prop) && ~isnan(prop)
                    trialPropVect(trialInd) = prop;
                else
                    trialPropVect(trialInd) = nan;
                end
            end
        end
        
        function save(obj)
            saveFolder = 'E:\KarinaLocalStorage\MatlabSavedMaterial\matlab exps\';
            experiment=obj;
            saveName = strsplit(obj.rawFileName,'.');
            saveName = strcat(saveFolder,saveName{1});
            save(saveName,'experiment','-v7.3') %'-v7.3' was added on 9/20/22 to eliminate a sometimes error in which saving would fail. Seems to have to do with the the size  of the variable being saved according to online forums this was the solution.
        end
        
        
        
        
    end

end


