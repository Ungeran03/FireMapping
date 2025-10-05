function uavBeliefs = fuseMap(connectedAgents, uavBeliefs, gamma)
%This function fuses maps between connected agents.
%
%Inputs: 
%   connectedAgents = The communication Laplacian matrix.  (numAgent x
%       numAgent matrix)
%   uavBeliefs = The belief maps for all agents. (numAgents x mapSize x
%       mapSize matrix)
%   gamma = The belief fusion gamma parameter.
%
%Outputs:
%   uavBeliefs = The updated agent beliefs after fusion.

    %for each agent
    for agent = 1:size(connectedAgents, 2)
        
        %set var to agent's belief
        myEstState = uavBeliefs(:,:,agent);
        
        %slice laplacian to get only agents connected to this agent
        laplacianSlice = connectedAgents(agent,:);
        
        %for each agent in laplacian
        for connectedAgent = 1:length(laplacianSlice)
            connectedEstState = uavBeliefs(:,:,connectedAgent);
            %if agent is connected to this agent
            if laplacianSlice(connectedAgent) == -1
                %perform fusion
                myEstState = myEstState.*(connectedEstState./myEstState).^gamma;
            end
        end
        %save fused map
        uavBeliefs(:,:,agent) = myEstState;
    end
end