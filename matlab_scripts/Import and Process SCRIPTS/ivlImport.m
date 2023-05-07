function [impData] = ivlImport(ivl, ivlStartPositions, fileInstance, nDataChans, bytesPerEntry)
%import an interval of data and format appropriately
% For other scripts that use this data, use the script "chanDefs" to
% initialize the appropriate channels names for each column of data.

%Determine interval parameters
if (length(ivlStartPositions)>1)
    dpsPerIvl = (ivlStartPositions(2) - ivlStartPositions(1))/(bytesPerEntry*nDataChans);
else
    dpsPerIvl = inf; %will read entire file
end
    impSize = [nDataChans,dpsPerIvl];


currentPos=ftell(fileInstance); %check thatinterval start position is next position after where file was left at end of last ivl.
if ivlStartPositions(ivl)-1 ~= currentPos
    disp ('note: Data was skipped between last interval imported and this interval. This is fine as long as intention was not to import back-to-back intervals');
end
fseek(fileInstance,ivlStartPositions(ivl)-1,'bof');

%Import data
impData=fread(fileInstance,impSize,'float');
impData=impData'; %each row is a new dp

end