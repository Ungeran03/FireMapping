runs = 5;
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

%first, tally how many times the agent stayed on path for 1, 2, or 3 steps.
stepsOnPath = zeros(1,depth);
for run = 1:runs
   for simStep = 1:duration
       for agent = 1:numAgents
           for pathStep = 1:depth
               if simStep + pathStep > duration; continue; end
               position = multiAgentPositions(run, simStep + pathStep, agent, :);
               if sub2ind([mapSize, mapSize], position(2), position(1)) == multiAgentPaths(run, simStep, agent, pathStep)
                   stepsOnPath(1, pathStep) = stepsOnPath(1, pathStep) + 1;
               end
           end
       end
   end
end
stepsOnPath;
stepProbs = 1:1:depth;
stepProbs = stepProbs.*(numAgents*runs);
stepProbs = ones(1, depth).*(duration*numAgents*runs) - stepProbs;
stepProbs = stepsOnPath./stepProbs



%next, tally the likelihood of moving to any individual postion in its
%range relative to its starting position