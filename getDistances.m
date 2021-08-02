function distances = getDistances(agent, currentVertex, numAgents, mapSize, uavRows, uavCols, distanceMap)
    distances = zeros(1, numAgents);
    %get distance between currentVertex and each other agent
    for otherAgent = 1:numAgents
        if otherAgent == agent; continue; end
        %otherwise convert 2d index of otherAgent to linear and ref
        %DISTANCE_MAP
        otherAgentLinearIndex = sub2ind([mapSize, mapSize], uavRows(otherAgent), uavCols(otherAgent));
        distances(otherAgent) = distanceMap(currentVertex, otherAgentLinearIndex);
    end
end