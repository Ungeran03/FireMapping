%This script finds the average number of locations on fire over a set
%   number of runs for the specified duration.

runs = 100;         %the number of runs to average over
duration = 1000;    %comment out duration in FireMappingMain2.
onFire = 0;         %the current sum of locations that have been on fire over all simulations

for run = 1:runs
    tic
    FireMappingMain2;
    time = toc;
    fprintf("time remaining: %f\n", (runs-run)*time);
    onFire = onFire + sum(sum(trueState));  %running total of on-fire locations
end

avgOnFire=onFire/runs;      %get average number of locations on fire
%print average
avgOnFire