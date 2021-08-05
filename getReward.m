function reward = getReward(uncertainty, agent, currentVertex, repulsiveForceCoeff, numAgents, mapSize, uavRows, uavCols, distanceMap)
%calculates reward for a position on the state space
    entropyFunc = @(x) -x .* log2(x) - (1 - x) .* log2(1 - x);
    reward = entropyFunc(uncertainty);
    distances = getDistances(agent, currentVertex, numAgents, mapSize, uavRows, uavCols, distanceMap);
    repulsiveForce = -sum(1./(nonzeros(distances).^repulsiveForceCoeff));
    reward = reward + repulsiveForce;
end

%consider giving each agent different alpha values
%add alpha parameter to reward function