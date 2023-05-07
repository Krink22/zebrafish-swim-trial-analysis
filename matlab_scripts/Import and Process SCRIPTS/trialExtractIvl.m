function trialSeriesIvl = trialExtractIvl(impData,sampRate,dpPerIvl,ivl,boutSeriesIvl, expType)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here


%Initialize
    chInds = chanInds(); %define channel indices 
    trialState = impData(:,chInds('TTLCh'));

%Get interval inds
    trialInds = (1:length(trialState))' .* (trialState==5);
    trialInds = trialInds(trialInds~=0);
    trialEndIndsIvl = (diff(trialInds)>1).*trialInds(1:end-1);
    trialEndIndsIvl=trialEndIndsIvl(trialEndIndsIvl~=0);
    trialEndIndsIvl = [trialEndIndsIvl;trialInds(end)]; %add last trial end, which will have been missed using diff method (as that depends on a jump from last ind of one trial to first ind of next)
    trialStartIndsIvl = (diff(trialInds)>1).*trialInds(2:end);
    trialStartIndsIvl = trialStartIndsIvl(trialStartIndsIvl~=0);
    trialStartIndsIvl = [trialInds(1);trialStartIndsIvl]; %add first trial start, which will have been missed using diff method (as that depends on a jump from last ind of one trial to first ind of next)
    if (trialStartIndsIvl(1) == 1 || trialEndIndsIvl(end) == length(trialState))
        disp("WARNING: a trial was detected at very edge of this interval. This likely means it occurred in both intervals and will have each part counted as separate trials. For this reason, it's preferable to do full import in one interval when possible");
    end
    trialStartIndsGlbl = trialStartIndsIvl + dpPerIvl*(ivl-1); %global index of trial start Ind
    trialEndIndsGlbl = trialEndIndsIvl + dpPerIvl*(ivl-1);

if isempty(trialStartIndsIvl)
    trialSeriesIvl = []; 
    disp("No trials detected in this interval")
    
else   
    %Get aversive stim onset, relief onset, bouts in trial
        indNextBoutToTry = 1;
        for trialInd = 1:length(trialStartIndsIvl)
            trialInds = trialStartIndsIvl(trialInd):trialEndIndsIvl(trialInd);
            %Get aversive and relief onset inds
            avStimState = impData(trialInds,chInds('stimVCh'));
            avStimStartInd = find(avStimState>0,1);
            if (~isempty(avStimStartInd))
                reliefStartInd = find(avStimState==0,1,'last');
                if (isempty(reliefStartInd) || reliefStartInd>avStimStartInd) % if last relief detected is from before aversive stim started then there was no relief obtained following behavior so should be nan
                    reliefStartInd = nan;
                end
            else
                avStimStartInd = nan;
                reliefStartInd = nan;
            end       
            reliefStartInds(trialInd) = reliefStartInd;
            avStimStartInds(trialInd) = avStimStartInd;


            %Get IDs of bouts in trial
            trialBoutInd = 1;
            trialBoutIDs=[];
            if strcmp(expType, 'onset') %in bout onset include any bouts that START during trial
                boutInTrialCriteria = "(boutSeriesIvl(indNextBoutToTry).onInd < trialEndIndsGlbl(trialInd))";
            else %otherwise include only bouts that finish during trial
                boutInTrialCriteria = "(boutSeriesIvl(indNextBoutToTry).offInd < trialEndIndsGlbl(trialInd))";
            end
            try
                while boutSeriesIvl(indNextBoutToTry).onInd < trialStartIndsGlbl(trialInd) %Get to first bout to START in trial
                %while boutSeriesIvl(indNextBoutToTry).offInd < trialStartIndsGlbl(trialInd) %Get to first bout to END in trial
                    indNextBoutToTry = indNextBoutToTry + 1;
                end
                while (eval(boutInTrialCriteria) && indNextBoutToTry<=length(boutSeriesIvl)) % while there is still a bout left to try and its onset and offset occur within bounds of trial
                    trialBoutIDs(trialBoutInd) = boutSeriesIvl(indNextBoutToTry).boutID; %bouts in current trial
                    indNextBoutToTry = indNextBoutToTry + 1;
                    trialBoutInd = trialBoutInd + 1;
                    if indNextBoutToTry>length(boutSeriesIvl)
                        disp('trial at edge of interval, so some bouts in it may be dropped')
                        break
                    end
                end
            catch
            end
            boutIDs{trialInd} = trialBoutIDs; %all bouts in trial

        end

    %Create series of Trial Objects
    trialSeriesIvl(length(trialStartIndsIvl),1) = TrialObj();
    for tInd = 1:length(trialSeriesIvl)
        trialSeriesIvl(tInd).startInd = trialStartIndsGlbl(tInd); %global index of trial start Ind
        trialSeriesIvl(tInd).endInd = trialEndIndsGlbl(tInd); %global index of trial start Ind
        trialSeriesIvl(tInd).avStimStartInd = avStimStartInds(tInd);
        trialSeriesIvl(tInd).reliefStartInd = reliefStartInds(tInd);
        trialSeriesIvl(tInd).boutIDs = boutIDs(tInd);

    end
end


end

