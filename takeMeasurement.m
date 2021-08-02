function [centEstState, uavEstState, measurement] = takeMeasurement(trueState, centEstState, uavEstState, robotLocRow, robotLocCol, ...
    falsePos, truePos, falseNeg, trueNeg)
    
    %take a measurement at current location
    measurement = trueState(robotLocRow, robotLocCol);
    %store measurement based on false positive/false negative rate
    if measurement == 1
        % The true state is positive, check if measured as false negative
        if rand() < falseNeg; measurement = 0; end
    else
        % The true state is negative, check if measured as false positive
        if rand() < falsePos; measurement = 1; end
    end
    
    %redefine to global variables!!!
    centEstState(robotLocRow, robotLocCol) = getCorrectMeasurementProbability(centEstState(robotLocRow, robotLocCol), measurement, falsePos, truePos, falseNeg, trueNeg);
    
    uavEstState(robotLocRow, robotLocCol) = getCorrectMeasurementProbability(uavEstState(robotLocRow, robotLocCol), measurement, falsePos, truePos, falseNeg, trueNeg);
    
end