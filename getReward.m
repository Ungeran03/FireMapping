function reward = getReward(uncertainty, agent, currentVertex, repulsiveForceCoeff, numAgents, mapSize, uavRows, uavCols, distanceMap, alpha)
%calculates reward for a position on the state space
    entropyFunc = @(x) -x .* log2(x) - (1 - x) .* log2(1 - x);
    reward = entropyFunc(uncertainty);
    distances = getDistances(agent, currentVertex, numAgents, mapSize, uavRows, uavCols, distanceMap);
    repulsiveForce = -sum(1./(nonzeros(distances).^repulsiveForceCoeff));
    z=find(distances == 0);
    if size(z)>1
        repulsiveForce = -10000;
    end
    reward = alpha*reward + (1-alpha)*repulsiveForce;
end