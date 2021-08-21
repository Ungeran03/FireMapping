runs = 100;
onFire = 0;

for run = 1:runs
    tic
    FireMappingMain2;
    time = toc;
    fprintf("time remaining: %f\n", (runs-run)*time);
    onFire = onFire + sum(sum(trueState));
end

avgOnFire=onFire/runs;
avgOnFire