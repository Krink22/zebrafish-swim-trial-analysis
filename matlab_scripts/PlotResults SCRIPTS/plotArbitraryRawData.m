function impData = plotArbitraryRawData(startDpInd)
%NOTE: Can't currently specify an endDpInd (ie always goes to end of file)
%bc ivlImport() function is written to tile ivls through the end of file. Could
%edit it to allow it to stop at arbitrary point, but not worth it at the
%moment.

%0
clc
fclose('all');

%1 Set params
    dataFolder= 'E:\KarinaLocalStorage'; %'E:\KarinaLocalStorage';%
    nDataChans = 12;
    bytesPerEntry = 4; %this many positions in file for every resulting entry when imported into matlab. Found this empirically, though assume has to do with importing as "float"
    ivl = 1; %all data will be imported in one interval for this script, but in other scripts sometimes break into multiple intervals
    ivlBounds =(startDpInd-1) *nDataChans*bytesPerEntry + 1; % multiplying by  nDataChans*bytesPerEntr finds final file position index associated with that dp so this finds final file position of previous dp then add 1 to get to first filePos of desired dp

%2) Pick and open Data File    
    [fileInstance, fileName] = SelectAndOpenDataFile(dataFolder);

%3 Import data    
    impData = ivlImport(ivl, ivlBounds, fileInstance, nDataChans, bytesPerEntry); %Import interval of raw data
        
%4 Define channels in import
    chInds = chanInds(); %define channel indices 
    chNames = keys(chInds);
    chNums = values(chInds);
    for i = 1:length(chNames)
        disp(chNames{i} + " : " + chNums{i});
    end
    disp("you can now plot any of the above channels for the imported interval using commands like plot(impData(:,desiredChNum))");
    %disp("(When done with this data, use command dbcont to complete function)");
    %keyboard

    fclose('all');
end