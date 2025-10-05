%Additional Explanation
%This simulation collects information regarding path planning over several
%simulations including the probability agents visit locations relative to
%their starting point, the probability of planning a location relative to
%their starting point, and the probability an agent stays on path for each
%step along its path.

runs = 100; %the number of runs to collect data over

%Initialization is done to collect information on the parameters of the
%   simulation, such as the number of agents, depth, runtime, etc.
fprintf("Initializing workspace.\n");
tic;
FireMappingMain2;
runTime = toc;
runTime = runTime*runs;
multiAgentPaths = zeros(runs, duration, numAgents, depth);
multiAgentPositions = zeros(runs, duration, numAgents, 2);
fprintf("Inititalization complete. Begining data collection.\n");
fprintf("Estimated time to run: %.2f seconds\n", runTime);

tic
%collect data
for simStep = 1:runs
    FireMappingMain2;
    multiAgentPaths(simStep, :, :, :) = agentPaths;
    multiAgentPositions(simStep, :, :, :) = agentPositions;
    fprintf("Run %d of %d complete.\n", simStep, runs);
end
fprintf("Data Collection Complete.\n");
toc

%check information

%first, tally how many times the agent stayed on path for n steps.
stepsOnPath = zeros(1,depth);
pathProbs = zeros(runs, 1+depth*2, 1+depth*2);
stepProbs = zeros(runs, depth, 1+depth*2, 1+depth*2);
planProbs = zeros(runs, depth, 1+depth*2, 1+depth*2);
stepCount = zeros(1, depth);
for run = 1:runs
   for simStep = 1:duration
       for agent = 1:numAgents
           center = multiAgentPositions(run, simStep, agent, :);
           for pathStep = 1:depth
               if simStep + pathStep > duration; continue; end
               
               agentPosition = multiAgentPositions(run, simStep + pathStep, agent, :);
               rowDirectionalOffset = agentPosition(2)-center(2);
               colDirectionalOffset = agentPosition(1)-center(1);
               offsetCol = (depth+1)+ colDirectionalOffset;
               offsetRow = (depth+1)+ rowDirectionalOffset;
               pathProbs(run, offsetRow, offsetCol) = pathProbs(run, offsetRow, offsetCol) + 1;
               
               stepProbs(run, pathStep, offsetRow, offsetCol) = stepProbs(run, pathStep, offsetRow, offsetCol) + 1;
               

               [row, col] = ind2sub([mapSize, mapSize], multiAgentPaths(run, simStep, agent, pathStep));
               rowDirectionalOffset = row-center(2);
               colDirectionalOffset = col-center(1);
               offsetCol = (depth+1)+ colDirectionalOffset;
               offsetRow = (depth+1)+ rowDirectionalOffset;
               planProbs(run, pathStep, offsetRow, offsetCol) = planProbs(run, pathStep, offsetRow, offsetCol) + 1;

               if sub2ind([mapSize, mapSize], agentPosition(2), agentPosition(1)) == multiAgentPaths(run, simStep, agent, pathStep)
                   stepsOnPath(1, pathStep) = stepsOnPath(1, pathStep) + 1;
               end
           end
       end
   end
   for i=1:(1+depth*2)^2
       pathProbs(run, i) = pathProbs(run, i)/((duration-numAgents)*numAgents*depth);
   end
end
stepsOnPath;    %the total number of steps taken on path at each depth level
pathStepProbs = 1:1:depth;
pathStepProbs = pathStepProbs.*(numAgents*runs);
pathStepProbs = ones(1, depth).*(duration*numAgents*runs) - pathStepProbs;

%probaility the agents stayed on path for each step in the path
pathStepProbs = stepsOnPath./pathStepProbs

%probabilities for moving through a position
finalMap = zeros(1+depth*2, 1+depth*2);
for i=1:runs
    currentMap = reshape(pathProbs(i,:,:),1+depth*2,1+depth*2);
    finalMap = currentMap+finalMap;
end
finalMap = finalMap/runs;
fprintf("Probability of position relative to start along the entire path:\n");
finalMap

figDimRow = ceil(sqrt(1+depth));
figDimCol = floor(sqrt(1+depth));   %hack-y attempt to make heatmap size match depth (it's bad)
subplot(figDimRow, figDimCol, 1); heatmap(finalMap)
title("Probability of position in full path");

%probabilities for position after each step in path
%reduce matrix dimensions by 1
finalMap = zeros(depth, 1+depth*2, 1+depth*2);
for i=1:runs
    for j = 1:depth
        currentMap = reshape(stepProbs(i,j,:,:), 1, 1+depth*2, 1+depth*2);
        finalMap(j,:,:) = currentMap+finalMap(j,:,:);
    end
end

%probability for each position relative to start heatmap
for i=1:depth
    finalMap(i,:,:) = finalMap(i,:,:)/sum(sum(finalMap(i,:,:)));
    fprintf("Probability of position relative to start for step %d in path:\n", i);
    map = reshape(finalMap(i,:,:), 1+depth*2, 1+depth*2);
    subplot(figDimRow, figDimCol, 1+i); heatmap(map)
    title("Probabiliy of position at step "+i);
end

%probabilities for planned paths
figure
finalMap = zeros(depth, 1+depth*2, 1+depth*2);
for i=1:runs
    for j = 1:depth
        currentMap = reshape(planProbs(i,j,:,:), 1, 1+depth*2, 1+depth*2);
        finalMap(j,:,:) = currentMap+finalMap(j,:,:);
    end
end

%probability of planning each location heatmap
for i=1:depth
    finalMap(i,:,:) = finalMap(i,:,:)/sum(sum(finalMap(i,:,:)));
    map = reshape(finalMap(i,:,:), 1+depth*2, 1+depth*2);
    subplot(figDimRow, figDimCol, i); heatmap(map)
    title("Probabiliy of planning position at step "+i);
end
