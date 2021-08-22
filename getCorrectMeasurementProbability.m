function belief = getCorrectMeasurementProbability(priorProbability, measurement, falsePos, truePos, falseNeg, trueNeg)
%This function updates a belief based on the prior uncertainty of the
%   location as well as the known error rate of the measurement method.
%   This function is designed to be passed and return information about a
%   single location.
%
%Inputs: 
%   priorProbability = The prior belief at the location.
%   measurement = The measurement obtained for the location
%   falsePos = The rate of a 'false' measurement registering as 'true'.
%   truePos = The rate of a 'true' measurement registering as 'true'.
%   falseNeg = The rate of a 'true' measurement registering as 'false'.
%   trueNeg = The rate of a 'false' measurement registering as 'false'.
%
%Outputs: 
%   belief = The uncertainty of the location corrected for known false
%       measurement rates.

    priorProbComp = 1 - priorProbability;   %complement of prior belief
    if measurement == 1
        % measured value is either a true positive or false positive
        belief = (truePos * priorProbability) / ((falsePos * priorProbComp) + (truePos * priorProbability));
    else
        % measured value is either a false negative or true negative
        belief = (falseNeg * priorProbability) / ((trueNeg * priorProbComp) + (falseNeg * priorProbability));
    end
end