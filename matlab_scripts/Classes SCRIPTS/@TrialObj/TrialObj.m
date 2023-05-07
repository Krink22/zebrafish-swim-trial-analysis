classdef TrialObj < matlab.mixin.SetGet
    %UNTITLED3 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        trialID
        startInd
        endInd
        avStimStartInd
        reliefStartInd
        boutIDs
        
    end
    
    methods
        function obj = TrialObj()
            %UNTITLED3 Construct an instance of this class
            %   Detailed explanation goes here
        end
        
        function boutID = getBoutID(obj,boutIndTrial)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            if isstring(boutIndTrial)
                if boutIndTrial == "lastMax2" %get the second trial if it exists, otherwise first. Or 0 if there are none.
                    boutIndTrial = length(obj.boutIDs{1});
                    if boutIndTrial > 2
                        boutIndTrial = 2;
                    end
                end
            elseif boutIndTrial<0 %if indexing from end
                boutIndTrial = length(obj.boutIDs{1}) + boutIndTrial + 1;
            end
            if (length(obj.boutIDs{1})>=boutIndTrial && boutIndTrial ~= 0)
                boutID = obj.boutIDs{1}(boutIndTrial);
            else
                boutID = nan;
            end
        end
    end
end

