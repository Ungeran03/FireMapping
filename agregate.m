function reward = agregate(G, currentVertex, depth, estState, agent, repulsiveForceCoeff, numAgents, mapSize, uavRows, uavCols, distanceMap, rewardAlpha)
    innerChildren = [];
    children = successors(G, currentVertex);
    
    %get all children from currentVertex to depth (eg if depth = 3, get
    %children + grand children + great-grand children
    for i=1:depth
        innerChildren = [innerChildren children];
        children = successors(G, children);
    end
    innerChildren = [innerChildren children];
    
    %trim out duplicate children (corners duplicate) 
    %**consider removal for weighting**
    children = unique(innerChildren);
    
    %sum reward for every child and divide by number of children in list to
    %get average reward for the diamond-shaped zone
    reward = 0;
    for i=1:length(children)
        uncertainty = estState(currentVertex);
        reward = reward + getReward(uncertainty, agent, currentVertex, repulsiveForceCoeff, numAgents, mapSize, uavRows, uavCols, distanceMap, rewardAlpha);
    end
    reward = reward/length(children);
end