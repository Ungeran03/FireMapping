function outState = spreadFire(inState, spreadRate)
%This function controls how the fire is spread in the simulation.  This
%   version finds all locations that are on fire and percolates the fire to
%   adjacent positions based on the spread rate.  The spread is binary, it
%   either spreads or it does not spread.
%
%Inputs: 
%   inState = The current true state of the state space.
%   spreadRate = The rate of fire percolation.
%   
%Outputs:
%   outState = The true state after the fire has been spread over one time
%       step.

    outState = inState;     %initialize
    sideLen = length(inState);  %the side length of the square state space
    [row, col] = find(inState); %all locations that are on fire initially
    for i = 1:length(row)
        spread = rand(4,1);   %generate a random number for each cardinal direction
        
        %Stub for 'burned out' locations.  These locations have state -1
        %   and are skipped for fire percolation.
        if inState(row(i), col(i)) == -1; continue; end
        
        %Check each direction's random spread value against spread rate.
        %   Spread to location iff random value is between 0 and spreadRate.
        
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