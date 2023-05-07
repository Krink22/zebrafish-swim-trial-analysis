%Take plots from selected figures, crop to same length and plot on shared
%axis
clc
clearvars
figures = [8,10];
hardXLimit = 400; %Set to inf unless want to set some max x values to include (not max value, max number of values)
invertPlots = false;

%Check if number of plots to include matches number of figures open
figuresOpenH =  findobj('type','figure');
nFiguresOpen = length(figuresOpenH);
if length(figures) ~= nFiguresOpen
    msgbox("WARNING: (put mouse in command window and press any button to continue) figures included does not equal number of plots currently open. Adjust selection in code if want all figures included.");
    pause() 
end

 
xData = cell(length(figures));
yData = cell(length(figures));
shortestTraceLength = Inf;
for figureInd = 1:length(figures)
    figureID = figures(figureInd); %if figures selcted are not just 1:nFigures, need to convert between which figure in selected list and actual number id of figure
    figure(figureID)
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
    xDataVect = dataHs(dataHInd).XData;
    yDataVect = dataHs(dataHInd).YData;
    shortestTraceLength = min(shortestTraceLength,length(yDataVect));
    %Save X and Y data
    xData{figureInd} = xDataVect;
    yData{figureInd} = yDataVect;
    %Get title for key
    titleH=get(gca,'Title');
    figTitle=get(titleH,'String'); %t is now 'Sin(x)'
    if isempty(figTitle)
        key(figureInd) = strcat("plot ",num2str(figureID));
    else
        key(figureInd) = figTitle;
    end
end

%Crop all exps to same length
for figureInd = 1: length(figures)
    shortestTraceLength = min(shortestTraceLength,hardXLimit);
    xData{figureInd} = xData{figureInd}(1:shortestTraceLength);
    yData{figureInd} = yData{figureInd}(1:shortestTraceLength);
end

%Plot all on same figure
figure()
hold on
for figureInd = 1: length(figures)
    if invertPlots == true
        plot(xData{figureInd},1-yData{figureInd});
    else
        plot(xData{figureInd}, yData{figureInd});
    end
end
legend(key);
hold off

%Plot avg
if true
    myColor = 'g';
    yDataMat = cell2mat(yData);
    yAvg = mean(yDataMat,1);
    if invertPlots == true
        yAvg = 1-yAvg;
    end
    yStDev = std(yDataMat,1);
    ySEM = yStDev/sqrt(size(yDataMat,1));
    minus2SEM = yAvg - 2*ySEM;
    plus2SEM = yAvg + 2*ySEM;
    figure()
    hold on
    plot(xData{1},yAvg, [myColor]);
    plot(xData{1},minus2SEM, [myColor ':']);
    plot(xData{1},plus2SEM, [myColor ':']);
end