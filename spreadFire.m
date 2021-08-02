function outState = spreadFire(inState, spreadRate)
    outState = inState;
    sideLen = length(inState);
    [row, col] = find(inState);
    for i = 1:length(row)
        spread = rand(4,1);   %random for fire to spread in each direction
        if inState(row(i), col(i)) == -1; continue; end
        %spread up
        if (spread(1) <= spreadRate) && (row(i) > 1)
            outState(row(i)-1, col(i)) = 1; 
        end
        %spread down
        if (spread(2) <= spreadRate) && row(i) < sideLen
            outState(row(i)+1, col(i)) = 1; 
        end
        %spread left
        if (spread(3) <= spreadRate) && col(i) > 1
            outState(row(i), col(i)-1) = 1; 
        end
        %spread right
        if (spread(4) <= spreadRate) && col(i) < sideLen
            outState(row(i), col(i)+1) = 1; 
        end
    end
end