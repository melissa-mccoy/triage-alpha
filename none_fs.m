function [ criterion ] = none_fs(trainX,trainY,testX,testY)
    %% Parameter Selection
    bestcv = 0;
    for log2c = -1:10
      for log2g = -10:1
        cmd = ['-v 5 -c ', num2str(2^log2c), ' -g ', num2str(2^log2g)];
        cv = svmtrain(trainY, trainX, cmd);
        if (cv >= bestcv),
          bestcv = cv; bestc = 2^log2c; bestg = 2^log2g;
        end
        fprintf('%g %g %g (best c=%g, g=%g, rate=%g)\n', log2c, log2g, cv, bestc, bestg, bestcv);
      end
    end

  
    %% Test Model
    model = svmtrain(trainY, trainX,['-s 0 -t 2 -c ' num2str(bestc) ' -g ' num2str(bestg)]);
    criterion = sum(svmpredict(testY, testX, model) ~= testY);

end
