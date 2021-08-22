function reward = getReward(uncertainty, agent, currentVertex, repulsiveForceCoeff, numAgents, mapSize, uavRows, uavCols, distanceMap, alpha)
%This function computes the reward for a location in the state space.
%
%Inputs:
%   uncertainty = The uncertainty at a single location in the state space.
%   agent = The agent for which the reward is being calculated.
%   currentVertex = The location in the state space for which the reward 
%       is being calculated.
%   repulsiveForceCoeff = The repulsive force factor between agents.
%   numAgents = The number of agents in the state space.
%   mapSize = The length of one side of the square state space.
%   uavRows = The current row location of all UAVs in the state space.
%   uavCols =  The current column location of all UAVs in the state space.
%   distanceMap =  A mapSize^2 x mapSize^2 matrix with the distances
%       between all locations in grid square units (not meters).
%   alpha = The alpha weighting parameter for the reward function.
%
%Outputs:
%   reward = The reward of the location in the state space.

    entropyFunc = @(x) -x .* log2(x) - (1 - x) .* log2(1 - x);  %entropy function
    reward = entropyFunc(uncertainty);
    
    distances = getDistances(agent, currentVertex, numAgents, mapSize, uavRows, uavCols, distanceMap);
    
    % calculate the total repulsive force at the location
    repulsiveForce = -sum(1./(nonzeros(distances).^repulsiveForceCoeff));
    
    %if another agent is occupying the location, set repulsive force to
    %   -10000
    z=find(distances == 0);
    if size(z)>1
        repulsiveForce = -10000;
    end
    reward = alpha*reward + (1-alpha)*repulsiveForce;
end