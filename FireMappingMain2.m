mapSize = 20;       %The length of one edge of the square state space.
start_display = 1000;  %The simulation step to begin displaying.  Choose a value > duration to never display.
showPaths = 1;      %show uav paths on map. turn off = 0, turn on = 1

duration = 1000;    %The number of time steps in the simulation.
simSpeed = 0;    %pause between simulation frames. smaller = faster

depth = 3;      %The depth to search to for path planning.
numAgents = 5;  %The number of agents in the state space.

spreadRate = 0.007; %The fire spread rate.  Larger numbers = faster spread.
burnOutRate = 0;    %The rate the fire burns out.  Stub.
fusionInterval = 20;    %The agents will fuse maps every fusionInterval time steps.

repulsiveForce = 2; %The repulsive force factor.
repulsiveForceRange = 5;    %The drop off range for the repulsive force.
fusionGamma = 3/10;     %The gamma parameter for belief fusion.
rewardAlpha = 0.5;      %The alpha weigthing parameter for the reward function.
%rewardBeta = 0.5;      %The beta weigthing parameter for long and mid
                        %   range palnning. Stub.

falsePosRate = 0.10;    %The percent of false measurements that register positive.
falseNegRate = 0.10;    %The percent of positive measurements that register false.
truePosRate = 1-falsePosRate;   %The percent of positive measurements that register positive.
trueNegRate = 1-falseNegRate;   %The percent of false measurements that register false.

communicationLaplacian = [2 -1 0 0 -1;
                          -1 2 -1 0 0;
                          0 -1 2 -1 0;
                          0 0 -1 2 -1; 
                          -1 0 0 -1 2];     %The Laplacian describing which agents can communicate.

centEstState = 0.5*ones(mapSize);       %The estimated state if all agents could communicate.
uavEstState = 0.5*ones(mapSize, mapSize, numAgents);    %The estimated state map for all agents.
trueState = zeros(mapSize);     %The actual state space (locations are on fire or not)

%Throw a match at a random spot on the map.
x = randi(mapSize); 
y = randi(mapSize);
trueState(y, x) = 1;

%Randomize where the agents start.
uavRows = randperm(mapSize,numAgents);
uavCols = randperm(mapSize,numAgents);
uavPaths = zeros(numAgents, depth);

%Initialize error data gathering metrics.
totalError = zeros(duration, 1);
totalErrorUAVs = zeros(duration, 1);
uavError = zeros(numAgents, 1);

%Create a digraph of connections between locations in state space.
pathGraph = initializeGraph(mapSize, centEstState);

%Set the color map for plotting uncertainty.
colorMap = get_colormap(200);

%Initialize an adjacency matric (graph) with edge weigths equal to the
%   distances between all locations in the state space.
distanceMap = getDistanceMap(mapSize);

%Initialize path data gathering metrics.
agentPaths = zeros(duration, numAgents, depth);
agentPositions = zeros(duration, numAgents, 2);

%tic
%Main loop
for step = 1:duration
    %Spread the fire.
    trueState = spreadFire(trueState, spreadRate);  %spread the fire
    
    %update centralized estimated state based on where the fire is
    %   estimated to be.
    centEstState = updateEstState(centEstState, spreadRate);    
    
    %update the UAV's estimated states
    for i = 1:numAgents
        uavEstState(:,:,i) = updateEstState(uavEstState(:,:,i),spreadRate);
    end
    
    %for each agent
    for agent = 1:numAgents
        %take a measurement
        [centEstState, uavEstState(:,:,agent), measurement] = takeMeasurement(trueState, centEstState, uavEstState(:,:,agent), uavRows(agent), uavCols(agent), falsePosRate, truePosRate, falseNegRate, trueNegRate);
        %slice the laplacian
        connectedAgents = communicationLaplacian(agent,:);
        %communicate measurement to connected agents
        for otherAgent = 1:numAgents
            if(connectedAgents(otherAgent) == -1)
                uavEstState(uavRows(agent),uavCols(agent),otherAgent) = getCorrectMeasurementProbability(uavEstState(uavRows(agent),uavCols(agent),otherAgent), measurement, falsePosRate, truePosRate, falseNegRate, trueNegRate);
            end
        end
    end
    
    %If at fusion interval, perform fusion
    if(~mod(step,fusionInterval))
        uavEstState = fuseMap(communicationLaplacian, uavEstState, fusionGamma);
    end
    
    %Plan a path for each agent
    for agent = 1:numAgents
        %convert 2D agent coordinate to linear for use with pathGraph
        currentVertex = (uavRows(agent)-1)*mapSize + (uavCols(agent));
        uavPaths(agent,:) = findBestPath(pathGraph, currentVertex, depth, uavEstState(:,:,agent), agent, repulsiveForce, numAgents, mapSize, uavRows, uavCols, distanceMap, rewardAlpha);
    end
        
    %%%%%%%%%%%%Borrowed Code%%%%%%%%%%%%%%%%%%%%%%%
    % Only display maps after reaching timestep "start_display". 
    if (step >= start_display)
        % Display rhe true state of the environment with a custom colormap.
        surf_true = [trueState trueState(:,mapSize); trueState(mapSize,:) trueState(mapSize,mapSize)];
        colormap(colorMap);
        f2 = figure(2); 
        surf(0:mapSize,0:mapSize,surf_true); view(0,90); caxis([0 1]);
        title("True State of Environment");

        % Plot centEstState for each UAV on subplot respectively.
        % Create subplot to visualize individual UAV mapping. (MAX = 5 UAVs)
        colormap(colorMap);
        f1 = figure(1);
        f1.Position = [f2.Position(1)+f2.Position(3)+5, f2.Position(2), f2.Position(3), f2.Position(4)];
        for i = 1:numAgents + 1
            subplot(2,3,i);
            if i == 1
                surf_est = [centEstState centEstState(:,mapSize); centEstState(mapSize,:) centEstState(mapSize,mapSize)];
                surf(0:mapSize,0:mapSize,surf_est); view(0,90); caxis([0 1]);
                title("Centralized Est. State");
            else
                surf_est_UAV = [uavEstState(:,:,i-1) uavEstState(:,mapSize); uavEstState(mapSize,:,i-1) ...
                                uavEstState(mapSize,mapSize)];
                surf(0:mapSize,0:mapSize,surf_est_UAV); view(0,90); caxis([0 1]);
                title(['UAV ' num2str(i-1)]); 
                text(uavCols(i-1)-1.1,uavRows(i-1)-0.2,2,'•');
                if showPaths
                    showPath(i-1, depth, mapSize, uavPaths);
                end
            end 
        end
    
        % Illustrate robot on centEstState environment.
        subplot(2,3,1);
        hold on
        for t = 1:numAgents
            text(uavCols(t)-1.1,uavRows(t)-0.2,2,'•');
            if showPaths
                showPath(t, depth, mapSize, uavPaths);
            end
        end
        hold off
        pause(simSpeed);
    end
    %end borrowed code%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %path info gethering code
    for agent = 1:numAgents
        agentPaths(step, :, :) = uavPaths(:, :);
        agentPositions(step, :, :) = [uavRows(:), uavCols(:)];
    end
    
    %move each agent to the first position in their planned path
    for agent = 1:numAgents
        uavRows(agent) = ceil(uavPaths(agent, 1)/mapSize);
        uavCols(agent) = mod(uavPaths(agent, 1)-1, mapSize)+1;
    end
    
    %%%%%%%%%%%%Borrowed Code%%%%%%%%%%%%%%%%%%%%%%%
    % Calculate Squared Error for centralized mapping.
    true_state_2 = trueState;
    true_state_2(true_state_2 == -1) = 0;
    error = true_state_2 - centEstState;
    squared_err = error.^2;
    totalError(step) = sum(sum(squared_err));
    
    % Calculate Squared Error for each UAV's mapping.
    for i = 1:numAgents
        error_UAVs = true_state_2 - uavEstState(:,:,i);
        squared_err_UAV = error_UAVs.^2;
        uavError(i) = sum(sum(squared_err_UAV));
    end
    totalErrorUAVs(step) = sum(uavError) / numAgents;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
end

%fprintf('Simulation Complete! :)\n');
totalError = totalError/duration;
totalErrorUAVs = totalErrorUAVs/duration;
%toc