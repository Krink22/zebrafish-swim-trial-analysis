function [ fileInstance, fileName ] = SelectAndOpenDataFile( dataFolder )
%UNTITLED19 Summary of this function goes here
%   Detailed explanation goes here
        currentFolderPath = cd;
        cd(dataFolder)
        fileName = uigetfile('*');
        [fileInstance, msg]=fopen(fileName);
        disp(msg)
        cd(currentFolderPath)
end

