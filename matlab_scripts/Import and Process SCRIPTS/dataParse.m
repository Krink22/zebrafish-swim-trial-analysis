function ivlStartPos = dataParse(fileInstance, minPerIvl, nDataChans, sampRate, bytesPerEntry)



    %zfDataParse
    %Define positions of sequential data intervals in a large data file (so
    %don't have to important all at once).

    %Get total size of file
    fseek(fileInstance, 0, 'eof');
    lastFilePos = ftell(fileInstance);

    %Prepare metadata matrix about number of intervals
    posPerIvl = minPerIvl*60*sampRate*nDataChans*bytesPerEntry;% number of positions in original data file for every interval
    ivlStartPos = 1:posPerIvl:lastFilePos-1;
    
    %Reset to beginning of file
    fseek(fileInstance, 0, 'bof');

end