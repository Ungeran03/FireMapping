function showPath(agent, depth, mapSize, paths)
%This function show the paths on the simulation for each agent with a small
%   blue dot.  This function is toggled on/off in the main file using the
%   paramter 'showPaths'.
%
%Inputs:
%   agent = The agent who's path is being displayed.
%   depth = The length of the path.
%   mapSize = The length of one side of the square state space.
%   paths = The matrix of all agent paths for the current step (linear).
%
%Outputs: None

    path = zeros(depth, 2);     %Intitialize
    %For each step in the path, change the linear coordinates to 2D
    for i = 1:depth
        [row, col] = ind2sub(mapSize, paths(agent, i));
        path(i, :) = [row, col];
    end
    
    %For each step in the path, draw a marker on the active figure map.
    for i = 1:depth
        text(path(i,1)-1.1,path(i,2)-0.4,2,'•', 'Color','blue', 'FontSize', 6);
    end
end