function [ fileName ] = fileSelect(dataFolder)

%User Set
    %dataFolder= '/Volumes/ahrenslab/Karina/DATA';
    %dataFolder= '/Users/Karina/Dropbox/TempDocs';
    dataFolder= '/Users/karina/Dropbox';

%Select Folder
    cd(dataFolder)
    [fileName,pathName]=uigetfile(strcat(dataFolder,'/*.*'));
    fileName=strcat(pathName,fileName);