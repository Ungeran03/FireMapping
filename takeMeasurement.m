function [centEstState, uavEstState, measurement] = takeMeasurement(trueState, centEstState, uavEstState, robotLocRow, robotLocCol, ...
    falsePos, truePos, falseNeg, trueNeg)
%This function controls how to agent takes a measurement from the sample
%   space.
%Inputs:
%   trueState = The map of the actual state space.
%   centEstState = The centralized estimated state.
%   uavEstState = The estimated state of one UAV.
%   robotLocRow = The row location of one UAV.
%   robotLocCol = The column location of one UAV.
%   falsePos = The rate of a 'false' measurement registering as 'true'.
%   truePos = The rate of a 'true' measurement registering as 'true'.
%   falseNeg = The rate of a 'true' measurement registering as 'false'.
%   trueNeg = The rate of a 'false' measurement registering as 'false'.
% 
%Outputs:
%   centEstState = The centralized estimated state updated to reflect the
%       measurement results.
%   uavEstState = The UAV estimated state updated to reflect the
%       measurement results.
%   measurement = The measurement the UAV registered.

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
    
    %update central estimated state uncertainty based on false pos/neg rate
    centEstState(robotLocRow, robotLocCol) = getCorrectMeasurementProbability(centEstState(robotLocRow, robotLocCol), measurement, falsePos, truePos, falseNeg, trueNeg);
    
    %update self estimated state uncertainty based of false pos/neg rate
    uavEstState(robotLocRow, robotLocCol) = getCorrectMeasurementProbability(uavEstState(robotLocRow, robotLocCol), measurement, falsePos, truePos, falseNeg, trueNeg);
    
end