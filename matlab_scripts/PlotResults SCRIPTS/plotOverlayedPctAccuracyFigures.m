close all
clc

loadData = inputdlg("Data needs to be loaded? (enter y)");

if loadData == "y"  
    clearvars
    %SELECT DATA
    batch = [
    "20210919_01",...
    "20210919_02",...
    "20210921_01",...
    "20210921_02",...
    "20210922_01",...
    "20210923_01",...
    "20210923_02",...
    "20210930_01"...
    ];
    dicarded = [
        "20210920_01",... %b/c didn't qualify baseline, rolled over automatically at 8 BLs
        "20210920_02"... %b/c didn't leave running long enough. Stopped at less than 600 trials of training
        "20210924_01",... %b/c didn't leave running long enough. Stopped at less than 600 trials of training
        ];
    
    temp= ["20210617_02", "20210610_01"];
 
    exps = [batch];%[learned, noLearn]; % Can use hardCodedAnalysisGroupSelections.m to define groups of experiments 


    waitfor(msgbox("Set switches on a_BoutAnalysis_MasterScript for desired plots. Press Okay when ready to proceed."))


    %COLLECT DATA
    origDirec = cd;
    cd("E:\KarinaLocalStorage\MatlabSavedMaterial\matlab exps");
    nExps = length(exps);
    xData = cell(1,nExps);
    yData = cell(1,nExps);
    for expInd = 1:nExps
        try
            load(exps(expInd))
        catch
            waitfor(msgbox(strcat(exps(expInd), " has not yet been imported. Select to import in next step.")));
            experiment = "import";
        end

        a_BoutAnalysis_MasterScript(experiment)

        figH = gcf;
        dataHs = findobj(figH,'-property','YData'); %Find all data objects with a YData vector

        %Select the data object with the longest YData vector (in case there is
        %more than one)
        lenLongestDataVect = 0;
        dataHInd = 0;
        for i = 1: length(dataHs)
            if length(dataHs(i).YData)> lenLongestDataVect
                lenLongestDataVect = length(dataHs(i).YData);
                dataHInd = i;
            end
        end

        %Save X and Y data
        xData{expInd} = dataHs(i).XData;
        yData{expInd} = dataHs(i).YData;

        pause()
    end
    cd(origDirec)
end

%GET DATA STATISTICS
minExpTrials = 99999999;
ySum=yData{1};
for expInd = 1: nExps
    nTrials = length(yData{expInd});
    minExpTrials = min(nTrials, minExpTrials);
end

yUniformLength = zeros(nExps, minExpTrials);
for expInd = 1: nExps
    yUniformLength(expInd,:) = yData{expInd}(1:minExpTrials);
end

yAv = mean(yUniformLength,1);
ySEM= std(yUniformLength,1)./sqrt(size(yUniformLength,1));

%PLOTS

%Individual traces with 0 at training onset
close all
figure()
hold on
for expInd = 1:nExps
    plot(xData{expInd},yData{expInd})
end

%Individual traces with 0 at accuracy above X%
accThresh = .8;
maintainReq = 100;
crossByReqTT = 500; %Must have started above thresh streak by this training trial
learnedFigH = figure();
hold on
noLearnFigH = figure();
hold on
for expInd = 1:nExps
    qualifyingInd = 0;
    x = xData{expInd};
    y = yData{expInd};
    nBLdps = sum(x<1);
    crossByReqAT = nBLdps + crossByReqTT;
    %Check for streak
    for dpInd = 1:min(length(x),(crossByReqAT+maintainReq-1)) %whichever is shorter, max dps if qualified or length of actual file (since can be a clear failure to streak before max possible number of trials if had streaked)
        if y(dpInd)>= accThresh
            streak = streak+1;
        else
            streak = 0;
            lastSubthreshInd = dpInd;
        end
        if streak>=maintainReq
            disp("LEARNING CRITERIA MET")
            disp(exps(expInd));
            disp(streak)
            qualifyingInd = dpInd;
            break
        end
    end
    if qualifyingInd == 0
        disp("LEARNING CRITERA NOT MET FOR FILE:");
        if(length(x)<(crossByReqAT+maintainReq-1))
            disp("***!!!***--- WARNING: exp has fewer trials than cross by req + maintain req ---***!!!***")
        end
        disp(exps(expInd));
        learned = 0;
        %lastSubthreshInd = crossByReqAT; %If file hasnt crossed by crossByReq I don't always let it continue running since cant qualify so cut off all failed exps here for uniformity of presentation
        figure(noLearnFigH);
    else
        learned = 1;
        figure(learnedFigH);
    end
    %get y values for each part of trace
    blY = y(1:nBLdps);
    learningY = y(nBLdps+1:lastSubthreshInd);
    if learned == 1
        learnedY = y(lastSubthreshInd+1 : qualifyingInd);
    end
    %get x values for each part of trace
    blX = (-1*(nBLdps-1):0); %(1:nBLdps)-lastSubthreshInd; %%<-- this selection makes x-axis 0 when trace crosses accThresh
    learningX = (1:(lastSubthreshInd - nBLdps)); %croppedTrainingX = (nBLdps+1:qualifyingInd)-lastSubthreshInd;
    if learned == 1
        learnedX = ((lastSubthreshInd- nBLdps + 1):(qualifyingInd- nBLdps));
    end
    %Plot each part of trace
    colormap lines;
    cmap = colormap;
    plotColor = cmap(expInd,:);
    plot(blX,blY,':','color', plotColor);
    plot(learningX,learningY,':','color', plotColor);
    if learned == 1
        plot(learnedX,learnedY,'LineWidth', 1,'color', plotColor);
    end
    %Annotate Figure
    xline(0);
    yline(.2,'--');
    yline(.5);
    yline(.8,'--');
    ylim([-.1,1.1]);
    ylabel("Percent Accuracy");
    xlabel("Trial");
end

%Averaged traces
figure()
plot(yAv)
hold on
plot(yAv + ySEM, 'r')
plot(yAv - ySEM, 'r')
