alphas = 1;
outerRuns = length(alphas);
innerRuns = 10;

multi_test_err = zeros(outerRuns, innerRuns,1);
multi_test_err_UAV = zeros(outerRuns, innerRuns,1);

for outerRun = 1:outerRuns
    tic
    for innerRun = 1:innerRuns
        rewardAlpha = alphas(outerRun);
        FireMappingMain2; 
        multi_test_err(outerRun,innerRun) = sum(totalError); %total_err
        multi_test_err_UAV(outerRun,innerRun) = sum(totalErrorUAVs); %total_err_UAV
    end
    
    runTime = toc;
    fprintf("Run %d of %d complete.\n", outerRun, outerRuns);
    fprintf("Estimated time remaining: %.2f seconds.\n",runTime*(outerRuns-outerRun));
end

avgErr = mean(multi_test_err,2);
avgErrUAV = mean(multi_test_err_UAV,2);

figure();
plot(alphas,avgErr);
title("Average Error with varied alpha parameter.");

figure();
plot(alphas,avgErrUAV);
title("Average UAV Error with varied alpha parameter.");