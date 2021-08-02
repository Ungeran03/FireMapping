function distanceMap = getDistanceMap(mapSize)
    %initiallize a mapSize^2 x mapSize^2 adjacency matrix with edge weights 
    %equal to the distance from one node to another.  The adjacency matrix
    %is undirected, so order of indexing does not matter. 
    
    %**ie to find the distance from node 1 to 5, index distanceMap(1,5) or 
    %distanceMap(5,1)
    
    size = mapSize^2;
    distanceMap = zeros(size, size);
    dimensions = [mapSize, mapSize];
    
    for row = 1:size
        [originRow, originCol] = ind2sub(dimensions, row);  %linear index to 2d index
        for col = 1:size
            [targetRow, targetCol] = ind2sub(dimensions, col);
            %euclidean distance
            distanceMap(row, col) = sqrt((originRow-targetRow)^2+(originCol-targetCol)^2);
            
            %taxicab distance
            %distanceMap(row, col) = abs(originRow-targetRow)+abs(originCol-targetCol);
            
        end
    end
end