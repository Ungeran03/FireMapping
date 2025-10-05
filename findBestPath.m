function bestPath = findBestPath(pathGraph, currentVertex, depth, estState, agent, repulsiveForceCoeff, numAgents, mapSize, uavRows, uavCols, distanceMap, rewardAlpha)
%This function finds the best path available to the agent.  This
%   implementation uses naive depth-first-search.
%
%Inputs:
%   pathGraph = A digraph showing all of the connections between linear
%       indexed nodes.
%   currentVertex = The starting vertex of the agent.
%   depth = The number of steps in the path.
%   estState = The agents current estimated state map, a mapSize x mapSize
%       matrix.
%   agent = The agent's numerical identifier.  1 =< agent =< numAgents
%   repulsiveForceCoeff = The repulsive force factor between agents.
%   numAgents = The number of agents in the simulation.
%   mapSize = The length of one side of the square state space.
%   uavRows = The current row location of all UAVs in the state space.
%   uavCols =  The current column location of all UAVs in the state space.
%   distanceMap =  A mapSize^2 x mapSize^2 matrix with the distances
%       between all locations in grid square units (not meters).
%   rewardAlpha = The alpha weighting parameter for the reward function.
%
%Outputs:
%   bestPath = A vector of linear indexes representing the best path in
%       order of closest step to furthest step.

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
        rewards = currentReward;
        %beta tuning parameter?
        %rewards = currentReward + agregate(G, currentVertex, depth, estState, agent, repulsiveForceCoeff, numAgents, mapSize, uavRows, uavCols, distanceMap, rewardAlpha);
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