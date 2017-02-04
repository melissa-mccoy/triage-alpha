function [ criterion ] = mrmr_fs(trainX,trainY,testX,testY)
    %% Feature Selection
    tenfoldCVP = cvpartition(trainY,'KFold',10);
    feaMID = mrmr_mid_d(int64(trainX),int64(trainY),250);
    xMIVals = []; midErrVals = [];
    for m=1:4:length(feaMID)
        xMIVals(end+1) = m;
        midErrVals(end+1) = transpose(crossval(@my_fun_lib,trainX(:,feaMID(1:m)),trainY,'partition',tenfoldCVP))/tenfoldCVP.TestSize;
    end
    
    [minVal minIndex] = min(midErrVals);
    midFeatures = feaMID(1:xMIVals(minIndex));

    %% Plot for later
%     tenfoldCVP = cvpartition(trainY,'KFold',10);
%     % MID
%     feaMID = mrmr_mid_d(int64(trainX),int64(trainY),500);
%     % MIQ
%     feaMIO = mrmr_miq_d(int64(trainX),int64(trainY),500);
%     xMIVals = []; midErrVals = []; mioErrVals = [];
%     for m=1:4:length(feaMID)
%         xMIVals(end+1) = m;
%         midErrVals(end+1) = transpose(crossval(@my_fun_lib,trainX(:,feaMID(1:m)),trainY,'partition',tenfoldCVP))/tenfoldCVP.TestSize;
%         mioErrVals(end+1) = transpose(crossval(@my_fun_lib,trainX(:,feaMIO(1:m)),trainY,'partition',tenfoldCVP))/tenfoldCVP.TestSize;
%     end
%     plot(xMIVals, midErrVals,'o',xMIVals,mioErrVals,'r^');
%     xlabel('Number of Features'); ylabel('MCE');
%     legend({'MCE for MID scheme' 'MCE for MIO scheme'},'location','NW');
%     title('mRMR Feature Selection');
      %% Parameter Selection
%    bestcv = 0;
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
    model = svmtrain(trainY, trainX(:,midFeatures),['-s 0 -t 2 -c ' num2str(bestc) ' -g ' num2str(bestg)]);
    criterion = sum(svmpredict(testY, testX(:,midFeatures), model) ~= testY);

end
