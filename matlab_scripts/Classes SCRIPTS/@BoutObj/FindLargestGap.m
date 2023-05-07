
function largestGap = FindLargestGap(obj)
%FindLargestGap finds the longest within a single bout period with motor below thresh
%   Detailed explanation goes here
    if ~isnan(obj.rawDataChs)
        boutStartInd = obj.onInd - obj.rawDataStartInd;
        boutTermInd = obj.offInd - obj.rawDataStartInd;
        motor = obj.rawDataChs(boutStartInd:boutTermInd,obj.chInds('motorCh2'));
        thresh = obj.rawDataChs(boutStartInd:boutTermInd,obj.chInds('threshCh2'));
        belowThresh=motor<thresh;
        streakCounter = 0;
        maxStreak = 0;
        for i = 1:length(belowThresh)
            if belowThresh(i) == 1
                streakCounter = streakCounter + 1;
                if streakCounter == 1
                    tempStreakStartInd = i;
                end
                if streakCounter>maxStreak
                    maxStreak = streakCounter;
                    streakEndInd = i;
                    streakStartInd=tempStreakStartInd;
                end
            else
                streakCounter = 0;
            end
        end
        largestGap = maxStreak;
        plotStreakSwitch = 0;
        if plotStreakSwitch == 1
            figure()
            plot(motor)
            hold on
            plot(thresh)
            plotVertLine(streakStartInd)
            plotVertLine(streakEndInd)
            title(streakEndInd-streakStartInd+1)
        end
    else
        largestGap = nan;
    end

end