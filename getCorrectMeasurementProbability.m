function belief = getCorrectMeasurementProbability(priorProbability, measurement, falsePos, truePos, falseNeg, trueNeg)
    priorProbComp = 1 - priorProbability;
    if measurement == 1
        % measured value is either a true positive or false positive
        belief = (truePos * priorProbability) / ((falsePos * priorProbComp) + (truePos * priorProbability));
    else
        % measured value is either a false negative or true negative
        belief = (falseNeg * priorProbability) / ((trueNeg * priorProbComp) + (falseNeg * priorProbability));
    end
end