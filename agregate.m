function reward = agregate(G, currentVertex, depth, estState, agent, repulsiveForceCoeff, numAgents, mapSize, uavRows, uavCols, distanceMap, rewardAlpha)
%This function averages the value in a diamond shaped area around a
%   selected vertex.  This is used for mid-range planning.
    children = successors(G, currentVertex);
    innerChildren = [];
    
    %get all children from currentVertex to depth (eg if depth = 3, get
    %children + grand children + great-grand children
    for i=1:depth
        innerChildren = [innerChildren children'];
        nextGeneration = [];
        for j = 1:length(children)
            nextGeneration = [nextGeneration; successors(G, children(j))];
        end
        children = nextGeneration;
    end
    innerChildren = [innerChildren children'];
    
    %trim out duplicate children (corners duplicate) 
    %**consider removal for weighting** i.e. if the position shows up more
    %   time it become more valuable in the average.
    children = unique(innerChildren(innerChildren~=0));
    
    %sum reward for every child and divide by number of children in list to
    %get average reward for the diamond-shaped zone
    reward = 0;
    for i=1:length(children)
        uncertainty = estState(children(i));
        reward = reward + getReward(uncertainty, agent, children(i), repulsiveForceCoeff, numAgents, mapSize, uavRows, uavCols, distanceMap, rewardAlpha);
    end
    reward = reward/length(children); %reward as either sum or average.
end