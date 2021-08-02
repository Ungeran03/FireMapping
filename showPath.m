function showPath(agent, depth, mapSize, paths)
%Shows path on map with smaller blue dots.  Can be turned off in top level
%file.
    path = zeros(depth, 2);
    for i = 1:depth
        [row, col] = ind2sub(mapSize, paths(agent, i));
        path(i, :) = [row, col];
    end
    for i = 1:depth
        text(path(i,1)-1.1,path(i,2)-0.4,2,'•', 'Color','blue', 'FontSize', 6);
    end
end