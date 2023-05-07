classdef BoutObj < matlab.mixin.SetGet
    %UNTITLED4 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        boutID
        trialID
        sampRate
        rawDataChs
        chInds
        rawDataStartInd %global index of first dp in rawData saved for this bout
        onT %assessed in exp
        offT %assess in exp
        durExp %duration in ms
        onInd %assessed post hoc
        offInd %assessed post hoc
        durPostHoc
        learningMetric
        postUsT
        postCsT
        maxAllowed
        minAllowed
        success
        relief
    end
    
    methods
        function obj = BoutObj()
            %BOUT Construct an instance of this class
            %   An individual swim bout
            obj.chInds = chanInds(); %assign indices to channel names
        end
        
        %Functions Saved in Individual Files in class folder @BoutObj:
        largestGap = FindLargestGap(obj)
    end
end

