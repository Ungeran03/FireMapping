mapSize = 20;
start_display = 10000;
showPaths = 0;      %show uav paths on map. turn off = 0

duration = 1000;
simSpeed = 0;    %pause between simulation frames. smaller = faster

depth = 3;
numAgents = 5;

spreadRate = 0.007;
burnOutRate = 0;
fusionInterval = 20;

repulsiveForce = 2;
repulsiveForceRange = 5;
fusionGamma = 3/10;

falsePosRate = 0.10;
falseNegRate = 0.10;
truePosRate = 1-falsePosRate;
trueNegRate = 1-falseNegRate;

communicationLaplacian = [2 -1 0 0 -1;
                          -1 2 -1 0 0;
                          0 -1 2 -1 0;
                          0 0 -1 2 -1; 
                          -1 0 0 -1 2];

centEstState = 0.5*ones(mapSize);
uavEstState = 0.5*ones(mapSize, mapSize, numAgents);
trueState = zeros(mapSize);

x = randi(mapSize);
y = randi(mapSize);
trueState(y, x) = 1;


uavRows = randperm(mapSize,numAgents);
uavCols = randperm(mapSize,numAgents);
uavPaths = zeros(numAgents, depth);

totalError = zeros(duration, 1);
totalErrorUAVs = zeros(duration, 1);
uavError = zeros(numAgents, 1);

pathGraph = initializeGraph(mapSize, centEstState);
colorMap = get_colormap(200);

distanceMap = getDistanceMap(mapSize);

tic
for step = 1:duration
    trueState = spreadFire(trueState, spreadRate);  %spread the fire
    
    %update centralized estimated state based on where the fire is estimated to be
    centEstState = updateEstState(centEstState, spreadRate);    
    
    %update the UAV's estimated states
    for i = 1:numAgents
        uavEstState(:,:,i) = updateEstState(uavEstState(:,:,i),spreadRate);
    end
    
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
    
    if(~mod(step,fusionInterval))
        uavEstState = fuseMap(communicationLaplacian, uavEstState, fusionGamma);
    end
    
    for agent = 1:numAgents
        currentVertex = (uavRows(agent)-1)*mapSize + (uavCols(agent));
        uavPaths(agent,:) = findBestPath(pathGraph, currentVertex, depth, uavEstState(:,:,agent), agent, repulsiveForce, numAgents, mapSize, uavRows, uavCols, distanceMap);
    end
        
    %%%%%%%%%%%%Borrowed Code%%%%%%%%%%%%%%%%%%%%%%%
    % Only display maps after reaching timestep "start_display". 
    if (step >= start_display)
        % Display rhe true state of the environment with a custom colormap.
        surf_true = [trueState trueState(:,mapSize); trueState(mapSize,:) trueState(mapSize,mapSize)];
        colormap(colorMap);
        figure(2); 
        surf(0:mapSize,0:mapSize,surf_true); view(0,90); caxis([0 1]);
        title("True State of Environment");

        % Plot centEstState for each UAV on subplot respectively.
        % Create subplot to visualize individual UAV mapping. (MAX = 5 UAVs)
        colormap(colorMap);
        figure(1);
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
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
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
        totalErrorUAVs = true_state_2 - uavEstState(:,:,i);
        squared_err_UAV = totalErrorUAVs.^2;
        uavError(i) = sum(sum(squared_err_UAV));
    end
    totalError(step) = sum(uavError) / numAgents;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
end

fprintf('Simulation Complete! :)\n');
%total_err = total_err/duration;
%total_err_UAV = total_err_UAVs/duration;
toc