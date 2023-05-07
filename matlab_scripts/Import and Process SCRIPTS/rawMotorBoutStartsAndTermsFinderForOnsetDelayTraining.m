function [boutStartIndsIvl, boutTermIndsIvl] = rawMotorBoutStartsAndTermsFinderForOnsetDelayTraining(rawMotor,rawThresh,boutAssessmentIndsIvl,dpsPerMillisec)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here


%Set params for searching for bout start and term
    maxLag=500; %max ms after bout offset that vr program could log info about bout
    preLogIgnoreZone = 10; % ms before logged bout details to not look for bout term in. This prevents edge cases where a new bout starts in narrow ivl after boutTerm criteria was met and ready for logging but before could be logged. Dont want to count this as part of bout in posthoc analysis.
    maxLagDps=maxLag*dpsPerMillisec;
    preLogIgnoreZoneDps = preLogIgnoreZone*dpsPerMillisec;
    maxGap = 50; % max ms gap within a bout
    maxGapDps = maxGap * dpsPerMillisec;
%Find exact Bout Start and End Inds    
    boutStartIndsIvl=nan(length(boutAssessmentIndsIvl),1);
    boutTermIndsIvl=nan(length(boutAssessmentIndsIvl),1);
    for boutInd = 1:length(boutAssessmentIndsIvl)
        skipBout = false;
        %Set bout search region
        boutTermRegionInds=(boutAssessmentIndsIvl(boutInd)-maxLagDps):boutAssessmentIndsIvl(boutInd)-preLogIgnoreZoneDps;
        %If bout is too close to edge of interval, don't detect
        if min(boutTermRegionInds)<1 || max(boutTermRegionInds)>length(rawMotor)
            skipBout = 1;
        else
        %Find bout terms ind
            boutTermRegionAboveThresh = (rawMotor(boutTermRegionInds)-rawThresh(boutTermRegionInds))>=0;
            boutTermIndsIvl(boutInd) = boutTermRegionInds(1) + find(boutTermRegionAboveThresh==1,1,'last') - 1;          
        %Find bout start ind
            boutStartInd_searcher = boutTermIndsIvl(boutInd);          
            preBoutMinDur = maxGapDps;
            subThreshDur=0;
            while subThreshDur<preBoutMinDur
                if boutStartInd_searcher == 0 %if bout start is too close to beginning of interval, skip
                    skipBout = true;
                    disp('bout skipped because too close to start or end of ivl')
                    break
                end
                if rawMotor(boutStartInd_searcher) >= rawThresh(boutStartInd_searcher)
                    subThreshDur=0;
                else
                    subThreshDur = subThreshDur+1;
                end
                boutStartInd_searcher = boutStartInd_searcher - 1;
            end
            boutStartIndsIvl(boutInd) = boutStartInd_searcher + subThreshDur + 1;
        end
        if skipBout == true
            boutStartIndsIvl(boutInd) = nan;
            boutTermIndsIvl(boutInd) = nan;
        end
        %Excise any bouts skipped due to being too close to edges
        boutStartIndsIvl = boutStartIndsIvl(~isnan(boutStartIndsIvl));
        boutTermIndsIvl = boutTermIndsIvl(~isnan(boutTermIndsIvl));
    end