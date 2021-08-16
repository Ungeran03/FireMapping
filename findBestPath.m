function bestPath = findBestPath(pathGraph, currentVertex, depth, estState, agent, repulsiveForceCoeff, numAgents, mapSize, uavRows, uavCols, distanceMap, rewardAlpha)
    [rewards, paths] = getPaths(pathGraph, currentVertex, depth, estState.', agent, repulsiveForceCoeff, numAgents, mapSize, uavRows, uavCols, distanceMap, rewardAlpha, depth);
    
    [path,bestPath] = max(rewards);
    bestPath = paths(bestPath,:);
end

function [rewards, paths] = getPaths(G, currentVertex, depth, estState, agent, repulsiveForceCoeff, numAgents, mapSize, uavRows, uavCols, distanceMap, rewardAlpha, topDepth)
    paths = [];
    rewards = [];
    children = successors(G, currentVertex);
    for i = 1:length(children)
        [childReward, childPaths] = getPathsHelper(G, children(i), depth, estState, agent, repulsiveForceCoeff, numAgents, mapSize, uavRows, uavCols, distanceMap, rewardAlpha, topDepth);
        paths = [paths; childPaths];
        rewards = [rewards; childReward];
    end
end

function [rewards, paths] = getPathsHelper(G, currentVertex, depth, estState, agent, repulsiveForceCoeff, numAgents, mapSize, uavRows, uavCols, distanceMap, rewardAlpha, topDepth)
%this function recursively performs a depth first search to get all paths
%from the source to the specified depth, including cycles
        uncertainty = estState(currentVertex);
        currentReward = getReward(uncertainty, agent, currentVertex, repulsiveForceCoeff, numAgents, mapSize, uavRows, uavCols, distanceMap, rewardAlpha);
        %currentReward = rand;
%if depth is zero, return current vertex
    if(depth == 1)
        paths = currentVertex;
        %rewards = currentReward;
        %beta tuning parameter?
        rewards = currentReward + agregate(G, currentVertex, depth, estState, agent, repulsiveForceCoeff, numAgents, mapSize, uavRows, uavCols, distanceMap, rewardAlpha);
        return;
    end
%otherwise, pre-concatenate the current vertex to every neighboring path
    %get neighboring subpaths that don't include current vertex,
    %recursively
    workingPath = [];
    workingReward = [];
    children = successors(G, currentVertex);
    for i = 1:length(children)
        [childReward, childPaths] = getPathsHelper(G, children(i), depth-1, estState, agent, repulsiveForceCoeff, numAgents, mapSize, uavRows, uavCols, distanceMap, rewardAlpha, topDepth);
        workingPath = [workingPath; childPaths];
        workingReward = [workingReward; childReward];
    end
    
    %pre-concatenation step
    paths = [];
    rewards = [];
    for i= 1:length(workingPath)
        paths = [paths; currentVertex workingPath(i,:)];
        rewards = [rewards; currentReward + workingReward(i)];
    end
    
    
end