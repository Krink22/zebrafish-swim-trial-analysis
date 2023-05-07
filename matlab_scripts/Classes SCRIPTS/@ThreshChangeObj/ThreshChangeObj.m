classdef ThreshChangeObj < matlab.mixin.SetGet
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        boutID
        minThresh
        maxThresh
        minChangeDir %-1=smaller, 0=no change, 1 = bigger
        maxChangeDir %-1=smaller, 0=no change, 1 = bigger
        threshChangeDiffDir %change in difficulty: -1=harder, 0=no change, 1 = harder
        threshChangePlotColor % r if thresh got harder, g if thresh got easier
    end
    
    methods
        function obj = ThreshChangeObj()
            %UNTITLED2 Construct an instance of this class
            %   Detailed explanation goes here
            %obj.Property1 = inputArg1 + inputArg2;
        end
        
        function outputArg = method1(obj,inputArg)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            outputArg = obj.Property1 + inputArg;
        end
    end
end

