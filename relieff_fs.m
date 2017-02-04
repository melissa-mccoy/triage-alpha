function [ criterion ] = relieff_fs(trainX,trainY,testX,testY)
  
    %% FILTER: Relief
    % Choose K with grid search
%     stdWeights = []; meanWeights = []; xVals = [];
%     for K=5:5:100
%         [reliefRank, reliefWeights] = relieff(trainX,trainY,K,'method','classification');
%         stdWeights(end+1) = std(reliefWeights);
%         meanWeights(end+1) = mean(reliefWeights);
%         xVals(end+1) = K;
%     end
%     [minVal minIndex] = min(stdWeights);
%     bestK = xVals(minIndex);
    % Choose Features with positive weight
    [reliefRank, reliefWeights] = relieff(XMat,YMat,10,'method','classification','categoricalx','on');
%     bar(reliefWeights(reliefRank));
%     xlabel('Predictor Rank'); ylabel('Predictor Importance Weight');
%     title('ReliefF Weights');
    reliefFeatures = reliefRank(reliefWeights > 0);
    
    reliefX = 5:10:535;
    reliefErr = [];
    for w=5:10:535
        reliefErr(end+1) = transpose(crossval(@my_fun_lib,XMat(:,reliefRank(1:w)),YMat,'partition',tenfoldCVP))/tenfoldCVP.TestSize;
    end
    plot(reliefX, reliefErr,'o');
    xlabel('Number of Features'); ylabel('ReliefF MCE');
    title('ReliefF Feature Selection');
   
    %% Parameter Selection
%    bestcv = 0;
%     for c = 110:130
%       for g =  .001:.0005:.003
%         cmd = ['-v 3 -s 0 -t 2 -c ', num2str(c), ' -g ', num2str(g)];
%         cv = svmtrain(trainY, trainX(:,reliefFeatures), cmd);
%         if (cv >= bestcv),
%           bestcv = cv; bestc = c; bestg = g;
%         end
%         fprintf('%g %g %g (best c=%g, g=%g, rate=%g)\n', bestc, bestg, bestcv);
%       end
%     end
    bestc = 120;
    bestg = .002;
    
    %% Test Model
    model = svmtrain(trainY, trainX(:,reliefFeatures),['-s 0 -t 2 -c ' num2str(bestc) ' -g ' num2str(bestg)]);
    criterion = sum(svmpredict(testY, testX(:,reliefFeatures), model) ~= testY);

end
