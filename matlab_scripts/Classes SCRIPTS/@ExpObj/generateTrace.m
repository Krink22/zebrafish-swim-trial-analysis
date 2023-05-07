function generateTrace(exp,traceType,showPlot)
%GETTRACE Summary of this function goes here
%   Detailed explanation goes here

if traceType == "OL" || traceType == "CL" %These refer to CL and OL QUITTING EXPERIMENTS ONLY
    traceQuitRateOverTime(exp,showPlot) %generates trace and saves it to exp
else
    print("code not yet written to extract that trace type")
end


end

