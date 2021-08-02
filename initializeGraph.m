function graph = initializeGraph(mapSize, initialBelief)

    function targets = getTargets(source, n)
    %this function calculates out the target list for a square environment
    %   with side length > 2
        targets = [];
        move = source - n;  %move up
        if(move>0) targets = [targets move]; end  %moved past top of environment
        move = source + n;  %move down
        if(move <= n^2) targets = [targets move]; end  %moved past bottom of environment
        move = source - 1;  %move left
        if(mod(move,n)~=0) targets = [targets move]; end  %moved into rightmost col
        move = source + 1;  %move right
        if(mod(move,n)~=1) targets = [targets move]; end  %moved into leftmost col
    end

    sourceNodes = [];
    targetNodes = [];
    weights = [];
    for index = 1:mapSize^2
        targets = getTargets(index, mapSize);
        targetNodes = [targetNodes targets];
        for i = 1:length(targets)
            sourceNodes = [sourceNodes index];
            % this is where the edge weight can go.  just use the value at t
            row = ceil(targetNodes(length(sourceNodes))/mapSize);
            col = mod(targetNodes(length(sourceNodes))-1,mapSize)+1;
            weights = [weights initialBelief(row, col)];
        end
    end
    
    graph = digraph(sourceNodes,targetNodes,weights);
    return;
end