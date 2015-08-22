function [ criterion ] = my_fun_lib(trainX,trainY,testX,testY)

    % Chose c range base on http://www.gatsby.ucl.ac.uk/aistats/fullpapers/198.pdf
    % and http://www.csie.ntu.edu.tw/~cjlin/papers/guide/guide.pdf
%     bestcv = 0;
%     for log2c = -1:3
%       for log2g = -4:1
%         cmd = ['-v 5 -c ', num2str(2^log2c), ' -g ', num2str(2^log2g)];
%         cv = svmtrain(trainY, trainX, cmd);
%         if (cv >= bestcv),
%           bestcv = cv; bestc = 2^log2c; bestg = 2^log2g;
%         end
%         fprintf('%g %g %g (best c=%g, g=%g, rate=%g)\n', log2c, log2g, cv, bestc, bestg, bestcv);
%       end
%     end
    bestc = 1;
%     bestg = 0.0625;
%     neg_size = sum(trainY == 0);
%     pos_size = sum(trainY == 1);
    model = svmtrain(trainY, trainX,['-s 0 -t 0 -c ' num2str(bestc) ]);
    criterion = sum(svmpredict(testY, testX, model) ~= testY);
    
end

