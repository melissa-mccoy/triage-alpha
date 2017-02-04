function [ criterion ] = minred_fs(trainX,trainY,testX,testY)

    %% FILTER+WRAPPER: Remove Most Correlated Features Until Reach Model Error Minimum
    featuresIdxSortbyC = zeros(1,size(trainX,2));
    tenfoldCVP = cvpartition(trainY,'KFold',10);
    trainXCorr = trainX; errVals = []; numFeaturesRemoved = [];
    for f=1:size(trainX,2)
        [~,idx] = max(mean(abs(corr(trainXCorr))));
        featuresIdxSortbyC(f) = idx;
        trainXCorr(:,idx) = [];
        if mod(f,4) == 0 
            numFeaturesRemoved(end+1) = f;
            errVals(end+1) = transpose(crossval(@my_fun_lib,trainXCorr,trainY,'partition',tenfoldCVP))/tenfoldCVP.TestSize;
        end
    end 
    plot(numFeaturesRemoved, errVals,'o');
    xlabel('Number of Removed Features');
    ylabel('Test MCE');
    title('Minimum Redundance Feature Selection');
    [minVal minIndex] = min(errVals); optFeaturesRemoved = numFeaturesRemoved(minIndex);
    minredFeatures = featuresIdxSortbyC(optFeaturesRemoved+1:end);
%     %% Parameter Selection
%     bestcv = 0;
%     for c = .01:1000
%       for g = .00001:.001:100
%         cmd = ['-v 3 -s 0 -t 2 -c ', num2str(c), ' -g ', num2str(g)];
%         cv = svmtrain(trainY, trainX(:,maxrelFeatures), cmd);
%         if (cv >= bestcv),
%           bestcv = cv; bestc = c; bestg = g;
%         end
%         fprintf('%g %g %g (best c=%g, g=%g, rate=%g)\n', bestc, bestg, bestcv);
%       end
%     end

    bestc = 120;
    bestg = .002;
    
    %% Test Model
    model = svmtrain(trainY, trainX(:,minredFeatures),['-s 0 -t 2 -c ' num2str(bestc) ' -g ' num2str(bestg)]);
    criterion = sum(svmpredict(testY, testX(:,minredFeatures), model) ~= testY);

end
