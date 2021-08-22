function updatedState = updateEstState(state, spreadRate)
%This function updates an estimated state map with new belief about the
%   fire spread based on the current estimated state map.
%
%Inputs:
%   state = the current estimated state map
%   spreadRate = the rate of fire propogation
%
%Outputs:
%   updatedState = a copy of state that has been updated to reflect one step
%       of fire propogation

    numAdjacentLocs = 4;    %the number of locations that are considered adjacent to a square. 4 or 8
    sideLength = length(state);     %the length of a side of the square matrix
    sideLengthSquared = sideLength^2;   %the number of linear indexes in matrix
    updatedState = state;   %initialize output to input
    
    %parse through matrix by linear index.  effectively a "for each" loop
    for linearIndex = 1:sideLengthSquared
        neighbors = zeros(numAdjacentLocs, 1);
        if(mod(linearIndex, sideLength) == 1)   %up
            neighbors(1) = 0;
        else
            neighbors(1) = linearIndex-1;
        end
        if(mod(linearIndex, sideLength) == 0)   %down
            neighbors(2) = 0;
        else
            neighbors(2) = linearIndex+1;
        end
        neighbors(3) = linearIndex-sideLength;  %left
        neighbors(4) = linearIndex+sideLength;  %right
        %%the 8-direction calcs are currently deprecated%%
%         neighbors(5) = neighbors(3)-1;  %up left
%         neighbors(6) = neighbors(3)+1;  %down left
%         neighbors(7) = neighbors(4)-1;  %up right
%         neighbors(8) = neighbors(4)+1;  %down right
        
        neighborProbs = zeros(numAdjacentLocs, 1);
        %parse through all of the neighboring locations
        for index = 1:numAdjacentLocs
            %check to make sure linear coordinate is inside of matrix
            if neighbors(index) < 1 || neighbors(index) > sideLengthSquared
                neighborProbs(index) = 0;
                continue;
            end
            neighborProbs(index) = updatedState(neighbors(index));
        end
        updatedState(linearIndex) = (updatedState(linearIndex) + (sum(neighborProbs)*spreadRate)) / (1 + (nnz(neighborProbs)*spreadRate));
    end
end