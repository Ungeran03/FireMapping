function distances = getDistances(agent, currentVertex, numAgents, mapSize, uavRows, uavCols, distanceMap)
%This function returns the distances from one agent to all of the other
%agents in the state space.
%
%Inputs:
%   agent = The active agent.  Included so the distance to this agent is
%       not calculated.
%   currentVertex = The location in the state space in linear coordinates
%       to find the distance to the agents from.
%   numAgents = The number of agents in the state space.
%   mapSize = The length of one side of the square state space.
%   uavRows = The row location of all UAVs in the state space.
%   uavCols = The column location of all UAVs in the state space.
%   distanceMap = An adjacency matrix with the distance between each
%       location.
%
%Outputs:
%   distances = The distances between current vertex and all other agents

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