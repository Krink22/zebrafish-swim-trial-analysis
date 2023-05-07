classdef AnalysisGroupObj < matlab.mixin.SetGet
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        expType
        fileGroups
        
    end
    
    methods
        function obj = AnalysisGroupObj(expType)
            %CONSTUCTOR Construct an instance of this class
            %   Detailed explanation goes here
            obj.expType = expType;
            obj.fileGroups = struct();
        end
        
        %Functions Saved in Individual Files in class folder @AnalysisGroupObj:
        defineFileGroup(obj,fileGroupName, fileNames)%Adds a set of files to the fileGroups struct under specified fileGroupName
        [overlayedTraceXData,overlayedTraceYData] = plotOverlayedTraces(obj,fileGroup,traceType)

    end
end

